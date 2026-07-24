import 'package:flutter/material.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_active_connection.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_scan_snapshot.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/routing/ble_device_info_route.dart';

class HomeMyoBandInfoSection extends StatelessWidget {
  const HomeMyoBandInfoSection({
    required this.savedDevices,
    required this.activeConnections,
    super.key,
  });

  final BleScanSnapshot savedDevices;
  final Map<String, BleActiveConnection> activeConnections;

  @override
  Widget build(BuildContext context) {
    final myoBandConnections = activeConnections.values.where((connection) {
      if (!connection.status.isConnected) return false;

      final scannedType = _deviceTypeFor(connection.deviceId);
      if (scannedType?.isMyoBandFamily == true) return true;

      return connection.deviceInfo?.resolvedType.isMyoBandFamily == true;
    }).toList();

    if (myoBandConnections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'MyoBand info',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...myoBandConnections.map(
          (connection) => _MyoBandInfoCard(
            connection: connection,
            fallbackName: _displayNameFor(connection.deviceId),
            onTap: () => _openDeviceInfo(context, connection.deviceId),
          ),
        ),
      ],
    );
  }

  void _openDeviceInfo(BuildContext context, String deviceId) {
    Navigator.of(context).pushNamed(
      BleDeviceInfoRoute.path,
      arguments: deviceId,
    );
  }

  BleDiscoveredDevice? _deviceFor(String deviceId) => savedDevices[deviceId];

  VulcanDeviceType? _deviceTypeFor(String deviceId) {
    return _deviceFor(deviceId)?.deviceType;
  }

  String _displayNameFor(String deviceId) {
    return _deviceFor(deviceId)?.displayName ?? deviceId;
  }
}

class _MyoBandInfoCard extends StatelessWidget {
  const _MyoBandInfoCard({
    required this.connection,
    required this.fallbackName,
    required this.onTap,
  });

  final BleActiveConnection connection;
  final String fallbackName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final info = connection.deviceInfo;

    if (connection.isReadingInfo) {
      return Card(
        child: ListTile(
          leading: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text(fallbackName),
          subtitle: const Text('Reading device info...'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
    }

    if (connection.hasError && info == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.error_outline, color: Colors.red),
          title: Text(fallbackName),
          subtitle: Text(connection.errorMessage ?? 'Failed to read device info'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
    }

    if (info == null) {
      return const SizedBox.shrink();
    }

    final typeLabel = info.resolvedType.genName ?? info.resolvedType.name;
    final battery = connection.battery;
    final batteryLabel = battery == null
        ? 'Battery: —'
        : 'Battery: ${battery.percent}%${battery.isCharging ? ' ⚡' : ''}';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.sensors, color: Colors.deepPurple),
        title: Text(info.name.isEmpty ? fallbackName : info.name),
        subtitle: Text(
          'FW: ${info.firmwareVersion.isEmpty ? '-' : info.firmwareVersion}'
          ' · $batteryLabel\n'
          'Hardware: ${info.hardwareId.isEmpty ? '-' : info.hardwareId}'
          ' · Type: $typeLabel',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
