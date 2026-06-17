import 'package:flutter/material.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_adapter_status.dart';

class BleAdapterBanner extends StatelessWidget {
  const BleAdapterBanner({
    required this.adapterStatus,
    super.key,
  });

  final BleAdapterStatus adapterStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReady = adapterStatus.isReady;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReady ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReady ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: isReady ? Colors.green.shade700 : Colors.orange.shade800,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bluetooth: ${adapterStatus.label}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isReady)
                  Text(
                    'Turn on Bluetooth and grant permissions to continue.',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
