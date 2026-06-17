import 'package:flutter/material.dart';

class BleScanControls extends StatelessWidget {
  const BleScanControls({
    required this.isScanning,
    required this.isEnabled,
    required this.onToggleScan,
    super.key,
  });

  final bool isScanning;
  final bool isEnabled;
  final VoidCallback onToggleScan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: isEnabled ? onToggleScan : null,
            icon: Icon(isScanning ? Icons.stop : Icons.search),
            label: Text(isScanning ? 'Stop scan' : 'Start scan'),
          ),
        ),
        if (isScanning) ...[
          const SizedBox(width: 12),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }
}
