import 'package:flutter/material.dart';

import '../../domain/entity/firmware_info.dart';

class FirmwareCheckStatusBanner extends StatelessWidget {
  const FirmwareCheckStatusBanner({
    required this.checkResult,
    super.key,
  });

  final FirmwareCheckResult checkResult;

  @override
  Widget build(BuildContext context) {
    final youtubeUrl = checkResult.firmwareInfo.changelog.youtubeUrl?.trim();
    if (youtubeUrl == null || youtubeUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.ondemand_video, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update guide',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    youtubeUrl,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
