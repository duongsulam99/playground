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
    return Scaffold(
      appBar: AppBar(title: const Text('Firmware update')),
      body: BlocBuilder<FirmwareUpdateBloc, FirmwareUpdateState>(
        builder: (context, state) {
          return switch (state.checkStatus) {
            FirmwareCheckStatus.initial || FirmwareCheckStatus.loading =>
              const _LoadingBody(),
            FirmwareCheckStatus.failure => _FailureBody(
              message: state.errorMessage ?? 'Failed to check firmware update',
              onRetry: () => context.read<FirmwareUpdateBloc>().add(
                const FirmwareUpdateEvent.retryRequested(),
              ),
            ),
            FirmwareCheckStatus.success => _SuccessBody(state: state),
          };
        },
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
          FirmwareChangelogSection(changelog: checkResult.firmwareInfo.changelog),
          const SizedBox(height: 16),
          FirmwareCheckStatusBanner(checkResult: checkResult),
        ],
      ),
    );
  }
}
