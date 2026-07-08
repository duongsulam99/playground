import 'package:flutter/material.dart';

import '../../domain/entity/firmware_info.dart';

class FirmwareVersionCard extends StatelessWidget {
  const FirmwareVersionCard({
    required this.currentVersion,
    required this.checkResult,
    super.key,
  });

  final String currentVersion;
  final FirmwareCheckResult checkResult;

  @override
  Widget build(BuildContext context) {
    final latestVersion = checkResult.firmwareInfo.versionName;
    final updateAvailable = checkResult.updateAvailable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firmware versions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _VersionRow(
              label: 'Current version',
              value: _formatVersion(currentVersion),
              valueColor: Colors.blue,
            ),
            const Divider(height: 24),
            _VersionRow(
              label: 'Latest version',
              value: _formatVersion(latestVersion),
              valueColor: Colors.orange,
            ),
            const SizedBox(height: 16),
            _StatusBadge(updateAvailable: updateAvailable),
          ],
        ),
      ),
    );
  }

  String _formatVersion(String version) {
    final trimmed = version.trim();
    if (trimmed.isEmpty) return '-';
    return trimmed.startsWith('v') ? trimmed : 'v$trimmed';
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.updateAvailable});

  final bool updateAvailable;

  @override
  Widget build(BuildContext context) {
    final color = updateAvailable ? Colors.orange : Colors.green;
    final label = updateAvailable ? 'Update available' : 'Up to date';
    final icon = updateAvailable ? Icons.system_update : Icons.check_circle;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
