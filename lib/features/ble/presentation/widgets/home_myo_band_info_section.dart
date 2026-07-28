import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_action_button_mapping.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_battery_snapshot.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_connection_entry.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_device_info.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_scan_snapshot.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/device/ble_device_bloc.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/device/ble_device_bloc_registry.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_action_button_mapping_label.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/routing/ble_device_info_route.dart';

class HomeMyoBandInfoSection extends StatelessWidget {
  const HomeMyoBandInfoSection({
    required this.savedDevices,
    required this.activeConnections,
    required this.deviceRegistry,
    super.key,
  });

  final BleScanSnapshot savedDevices;
  final Map<String, BleConnectionEntry> activeConnections;
  final BleDeviceBlocRegistry deviceRegistry;

  @override
  Widget build(BuildContext context) {
    final myoBandConnections = activeConnections.values.where((connection) {
      if (!connection.status.isConnected) return false;

      final deviceBloc = deviceRegistry.get(connection.deviceId);
      if (deviceBloc != null &&
          deviceBloc.state.capabilities.supportsDeviceInfo) {
        return true;
      }

      final scannedType = _deviceTypeFor(connection.deviceId);
      return scannedType?.isMyoBandFamily == true;
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...myoBandConnections.map((connection) {
          final deviceBloc = deviceRegistry.get(connection.deviceId);
          if (deviceBloc == null) return const SizedBox.shrink();

          return BlocProvider.value(
            value: deviceBloc,
            child: _MyoBandInfoCard(
              fallbackName: _displayNameFor(connection.deviceId),
              onTap: () => _openDeviceInfo(context, connection.deviceId),
            ),
          );
        }),
      ],
    );
  }

  void _openDeviceInfo(BuildContext context, String deviceId) {
    Navigator.of(
      context,
    ).pushNamed(BleDeviceInfoRoute.path, arguments: deviceId);
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
  const _MyoBandInfoCard({required this.fallbackName, required this.onTap});

  final String fallbackName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleDeviceBloc, BleDeviceState>(
      builder: (context, state) {
        if (state.isReadingInfo) {
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

        if (state.hasError && state.deviceInfo == null) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: Colors.red),
              title: Text(fallbackName),
              subtitle: Text(
                state.errorMessage ?? 'Failed to read device info',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: onTap,
            ),
          );
        }

        final info = state.deviceInfo;
        if (info == null) {
          return const SizedBox.shrink();
        }

        return _MyoBandInfoBody(
          info: info,
          battery: state.battery,
          actionButtonMapping: state.actionButtonMapping,
          showActionButton: state.capabilities.supportsActionButton,
          fallbackName: fallbackName,
          onTap: onTap,
        );
      },
    );
  }
}

class _MyoBandInfoBody extends StatelessWidget {
  const _MyoBandInfoBody({
    required this.info,
    required this.battery,
    required this.actionButtonMapping,
    required this.showActionButton,
    required this.fallbackName,
    required this.onTap,
  });

  final BleDeviceInfo info;
  final BleBatterySnapshot? battery;
  final BleActionButtonMapping? actionButtonMapping;
  final bool showActionButton;
  final String fallbackName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typeLabel = info.resolvedType.genName ?? info.resolvedType.name;
    final batteryLabel = battery == null
        ? 'Battery: —'
        : 'Battery: ${battery!.percent}%${battery!.isCharging ? ' ⚡' : ''}';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.sensors, color: Colors.deepPurple),
        title: Text(info.name.isEmpty ? fallbackName : info.name),
        subtitle: BlocBuilder<BleDeviceBloc, BleDeviceState>(
          buildWhen: (p, c) =>
              p.battery != c.battery ||
              p.actionButtonMapping != c.actionButtonMapping,
          builder: (context, state) => Text(
            'FW: ${info.firmwareVersion.isEmpty ? '-' : info.firmwareVersion}'
            ' · $batteryLabel\n'
            'Hardware: ${info.hardwareId.isEmpty ? '-' : info.hardwareId}'
            ' · Type: $typeLabel'
            '${showActionButton ? '\n${formatActionButtonMappingLabel(actionButtonMapping)}' : ''}',
          ),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
