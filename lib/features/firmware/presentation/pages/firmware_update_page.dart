import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/firmware_update/firmware_update_bloc.dart';
import '../widgets/firmware_changelog_section.dart';
import '../widgets/firmware_check_status_banner.dart';
import '../widgets/firmware_version_card.dart';

class FirmwareUpdatePage extends StatelessWidget {
  const FirmwareUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FirmwareUpdateBloc, FirmwareUpdateState>(
      builder: (context, state) {
        final isUpdating = _isUpdating(state.updateStatus);

        return PopScope(
          canPop: !isUpdating,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop || !isUpdating) return;

            final shouldLeave = await _confirmCancelUpdate(context);
            if (shouldLeave == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('Firmware update')),
            body: switch (state.checkStatus) {
              FirmwareCheckStatus.initial ||
              FirmwareCheckStatus.loading => const _LoadingBody(),
              FirmwareCheckStatus.failure => _FailureBody(
                message:
                    state.errorMessage ?? 'Failed to check firmware update',
                onRetry: () => context.read<FirmwareUpdateBloc>().add(
                  const FirmwareUpdateEvent.retryRequested(),
                ),
              ),
              FirmwareCheckStatus.success => _SuccessBody(state: state),
            },
          ),
        );
      },
    );
  }

  bool _isUpdating(FirmwareUpdateStatus status) {
    return switch (status) {
      FirmwareUpdateStatus.downloading ||
      FirmwareUpdateStatus.unpacking ||
      FirmwareUpdateStatus.uploading ||
      FirmwareUpdateStatus.confirming => true,
      FirmwareUpdateStatus.idle ||
      FirmwareUpdateStatus.completed ||
      FirmwareUpdateStatus.failed => false,
    };
  }

  Future<bool?> _confirmCancelUpdate(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firmware update in progress'),
        content: const Text(
          'Leaving this screen will cancel the update. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Checking for updates…'),
        ],
      ),
    );
  }
}

class _FailureBody extends StatelessWidget {
  const _FailureBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.state});

  final FirmwareUpdateState state;

  @override
  Widget build(BuildContext context) {
    final checkResult = state.checkResult;
    if (checkResult == null) {
      return const Center(child: Text('No firmware information available.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          FirmwareVersionCard(
            currentVersion: state.currentVersion,
            checkResult: checkResult,
          ),
          const SizedBox(height: 16),
          FirmwareChangelogSection(
            changelog: checkResult.firmwareInfo.changelog,
          ),
          const SizedBox(height: 16),
          FirmwareCheckStatusBanner(checkResult: checkResult),
          const SizedBox(height: 16),
          _FirmwareUpdateProgressCard(state: state),
          if (state.updateStatus == FirmwareUpdateStatus.idle &&
              checkResult.updateAvailable) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.read<FirmwareUpdateBloc>().add(
                  FirmwareUpdateEvent.executeRequested(
                    firmwareInfo: checkResult.firmwareInfo,
                  ),
                ),
                icon: const Icon(Icons.system_update_alt),
                label: const Text('Update firmware'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FirmwareUpdateProgressCard extends StatelessWidget {
  const _FirmwareUpdateProgressCard({required this.state});

  final FirmwareUpdateState state;

  @override
  Widget build(BuildContext context) {
    if (state.updateStatus == FirmwareUpdateStatus.idle) {
      return const SizedBox.shrink();
    }

    final progress = state.dfuProgress;
    final percent = (progress?.percent ?? 0).clamp(0, 100).toDouble();
    final statusLabel = _statusLabel(state.updateStatus);
    final message = progress?.message ?? state.errorMessage;
    final isFailed = state.updateStatus == FirmwareUpdateStatus.failed;
    final isCompleted = state.updateStatus == FirmwareUpdateStatus.completed;
    final color = isFailed
        ? Colors.red
        : isCompleted
        ? Colors.green
        : Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              color: color,
            ),
            if (message != null && message.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(FirmwareUpdateStatus status) {
    return switch (status) {
      FirmwareUpdateStatus.idle => 'Ready',
      FirmwareUpdateStatus.downloading => 'Downloading firmware',
      FirmwareUpdateStatus.unpacking => 'Unpacking firmware',
      FirmwareUpdateStatus.uploading => 'Uploading firmware',
      FirmwareUpdateStatus.confirming => 'Confirming firmware',
      FirmwareUpdateStatus.completed => 'Firmware update completed',
      FirmwareUpdateStatus.failed => 'Firmware update failed',
    };
  }
}
