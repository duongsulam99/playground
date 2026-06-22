import 'package:flutter/material.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_active_connection.dart';

class BleConnectedDevicesSection extends StatelessWidget {
  const BleConnectedDevicesSection({
    required this.savedDevices,
    required this.activeConnections,
    required this.onDisconnect,
    super.key,
  });

  final Map<String, BleDiscoveredDevice> savedDevices;
  final Map<String, BleActiveConnection> activeConnections;
  final ValueChanged<String> onDisconnect;

  @override
  Widget build(BuildContext context) {
    final activeEntries = activeConnections.values
        .where((connection) => connection.isActive)
        .toList();

    if (activeEntries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connected devices (${activeEntries.length})',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeEntries.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final connection = activeEntries[index];
            final device = savedDevices[connection.deviceId];

            return ListTile(
              leading: Icon(
                Icons.bluetooth_connected,
                color: connection.status.isConnected ? Colors.green : Colors.orange,
              ),
              title: Text(device?.displayName ?? connection.deviceId),
              subtitle: Text(
                '${connection.status.label}\n${connection.deviceId}',
              ),
              isThreeLine: true,
              trailing:
                  connection.status == BleConnectionStatus.connecting ||
                      connection.status == BleConnectionStatus.disconnecting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.link_off, color: Colors.red),
                      tooltip: 'Disconnect',
                      onPressed: () => onDisconnect(connection.deviceId),
                    ),
            );
          },
        ),
      ],
    );
  }
}
