import 'package:flutter/material.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_active_connection.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_scan_snapshot.dart';

class BleDeviceList extends StatelessWidget {
  const BleDeviceList({
    required this.savedDevices,
    required this.activeConnections,
    required this.canConnectDevice,
    required this.onDeviceSelected,
    required this.onDeviceDisconnect,
    super.key,
  });

  final BleScanSnapshot savedDevices;
  final Map<String, BleActiveConnection> activeConnections;
  final bool Function(String deviceId) canConnectDevice;
  final ValueChanged<String> onDeviceSelected;
  final ValueChanged<String> onDeviceDisconnect;

  @override
  Widget build(BuildContext context) {
    if (savedDevices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No devices found. Start scanning to discover BLE devices.',
          ),
        ),
      );
    }

    final devices = savedDevices.devices.toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final device = devices[index];
        final connection = activeConnections[device.id];
        final connectionStatus =
            connection?.status ?? BleConnectionStatus.disconnected;
        final canConnect = canConnectDevice(device.id);

        return ListTile(
          leading: _buildLeading(device),
          title: Text(device.displayName),
          subtitle: Text(
            '${device.id}\nRSSI: ${device.rssi} dBm\n'
            'Status: ${connectionStatus.label}'
            '${connection?.hasError == true ? '\nError: ${connection!.errorMessage}' : ''}',
          ),
          isThreeLine: true,
          trailing: _buildTrailing(device, connectionStatus, canConnect),
          onTap: () => _handleTap(device, connectionStatus, canConnect),
        );
      },
    );
  }

  Widget _buildLeading(BleDiscoveredDevice device) {
    final assetPath = device.imageAssetPath;
    if (assetPath == null) {
      return const Icon(Icons.bluetooth);
    }

    return Image.asset(
      assetPath,
      width: 40,
      height: 40,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Icon(Icons.bluetooth),
    );
  }

  Widget _buildTrailing(
    BleDiscoveredDevice device,
    BleConnectionStatus connectionStatus,
    bool canConnect,
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

    if (device.isConnectable && canConnect) {
      return const Icon(Icons.link);
    }

    return const Icon(Icons.link_off, color: Colors.grey);
  }

  void _handleTap(
    BleDiscoveredDevice device,
    BleConnectionStatus connectionStatus,
    bool canConnect,
  ) {
    if (connectionStatus == BleConnectionStatus.connecting ||
        connectionStatus == BleConnectionStatus.disconnecting) {
      return;
    }

    if (connectionStatus.isConnected) {
      onDeviceDisconnect(device.id);
      return;
    }

    if (device.isConnectable && canConnect) {
      onDeviceSelected(device.id);
    }
  }
}
