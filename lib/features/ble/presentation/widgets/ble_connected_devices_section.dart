import 'package:flutter/material.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';

class BleConnectedDevicesSection extends StatelessWidget {
  const BleConnectedDevicesSection({
    required this.devices,
    required this.deviceConnections,
    required this.onDisconnect,
    super.key,
  });

  final List<BleDiscoveredDevice> devices;
  final Map<String, BleConnectionStatus> deviceConnections;
  final ValueChanged<String> onDisconnect;

  @override
  Widget build(BuildContext context) {
    final connectedEntries = deviceConnections.entries
        .where(
          (entry) =>
              entry.value.isConnected ||
              entry.value == BleConnectionStatus.connecting ||
              entry.value == BleConnectionStatus.disconnecting,
        )
        .toList();

    if (connectedEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connected devices (${connectedEntries.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: connectedEntries.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final entry = connectedEntries[index];
            final deviceId = entry.key;
            final status = entry.value;
            final device = devices.cast<BleDiscoveredDevice?>().firstWhere(
              (d) => d?.id == deviceId,
              orElse: () => null,
            );

            return ListTile(
              leading: Icon(
                Icons.bluetooth_connected,
                color: status.isConnected ? Colors.green : Colors.orange,
              ),
              title: Text(device?.displayName ?? deviceId),
              subtitle: Text('${status.label}\n$deviceId'),
              isThreeLine: true,
              trailing: status == BleConnectionStatus.connecting ||
                      status == BleConnectionStatus.disconnecting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.link_off, color: Colors.red),
                      tooltip: 'Disconnect',
                      onPressed: () => onDisconnect(deviceId),
                    ),
            );
          },
        ),
      ],
    );
  }
}
