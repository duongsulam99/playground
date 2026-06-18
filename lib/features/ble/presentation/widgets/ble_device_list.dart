import 'package:flutter/material.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';

class BleDeviceList extends StatelessWidget {
  const BleDeviceList({
    required this.devices,
    required this.deviceConnections,
    required this.onDeviceSelected,
    required this.onDeviceDisconnect,
    super.key,
  });

  final List<BleDiscoveredDevice> devices;
  final Map<String, BleConnectionStatus> deviceConnections;
  final ValueChanged<String> onDeviceSelected;
  final ValueChanged<String> onDeviceDisconnect;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No devices found. Start scanning to discover BLE devices.',
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final device = devices[index];
        final connectionStatus =
            deviceConnections[device.id] ?? BleConnectionStatus.disconnected;

        return ListTile(
          leading: const Icon(Icons.bluetooth),
          title: Text(device.displayName),
          subtitle: Text(
            '${device.id}\nRSSI: ${device.rssi} dBm\n'
            'Status: ${connectionStatus.label}',
          ),
          isThreeLine: true,
          trailing: _buildTrailing(device, connectionStatus),
          onTap: () => _handleTap(device, connectionStatus),
        );
      },
    );
  }

  Widget _buildTrailing(
    BleDiscoveredDevice device,
    BleConnectionStatus connectionStatus,
  ) {
    if (connectionStatus == BleConnectionStatus.connecting ||
        connectionStatus == BleConnectionStatus.disconnecting) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (connectionStatus.isConnected) {
      return IconButton(
        icon: const Icon(Icons.link_off, color: Colors.red),
        tooltip: 'Disconnect',
        onPressed: () => onDeviceDisconnect(device.id),
      );
    }

    if (device.isConnectable) {
      return const Icon(Icons.link);
    }

    return const Icon(Icons.link_off, color: Colors.grey);
  }

  void _handleTap(
    BleDiscoveredDevice device,
    BleConnectionStatus connectionStatus,
  ) {
    if (connectionStatus == BleConnectionStatus.connecting ||
        connectionStatus == BleConnectionStatus.disconnecting) {
      return;
    }

    if (connectionStatus.isConnected) {
      onDeviceDisconnect(device.id);
      return;
    }

    if (device.isConnectable) {
      onDeviceSelected(device.id);
    }
  }
}
