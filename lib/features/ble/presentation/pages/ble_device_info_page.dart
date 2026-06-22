import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_active_connection.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_device_info.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_device_stream_snapshot.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_device_stream_panel.dart';

import '../bloc/ble/ble_bloc.dart';

class BleDeviceInfoPage extends StatelessWidget {
  const BleDeviceInfoPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device info')),
      body: BlocSelector<BleBloc, BleState, _DeviceInfoViewState>(
        selector: (state) => _DeviceInfoViewState.from(state, deviceId),
        builder: (context, viewState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!viewState.isConnected) ...[
                  const _DisconnectedBanner(),
                  const SizedBox(height: 16),
                ],
                _DeviceHeader(
                  displayName: viewState.displayName,
                  deviceId: deviceId,
                  connectionStatus: viewState.connectionStatus,
                ),
                const SizedBox(height: 16),
                _DeviceMetadataCard(
                  connection: viewState.connection,
                  displayName: viewState.displayName,
                ),
                const SizedBox(height: 16),
                BleDeviceStreamPanel(
                  connection: viewState.connection,
                  snapshot: viewState.streamSnapshot,
                  displayName: viewState.displayName,
                  supportsDataStream: viewState.supportsDataStream,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DeviceInfoViewState {
  const _DeviceInfoViewState({
    required this.displayName,
    required this.connectionStatus,
    required this.connection,
    required this.streamSnapshot,
    required this.supportsDataStream,
    required this.isConnected,
  });

  final String displayName;
  final BleConnectionStatus connectionStatus;
  final BleActiveConnection? connection;
  final BleDeviceStreamSnapshot? streamSnapshot;
  final bool supportsDataStream;
  final bool isConnected;

  factory _DeviceInfoViewState.from(BleState state, String deviceId) {
    final connection = state.activeConnectionFor(deviceId);
    final savedDevice = state.savedDeviceFor(deviceId);
    final displayName = savedDevice?.displayName ?? deviceId;
    final scannedType = savedDevice?.deviceType;
    final resolvedType = connection?.deviceInfo?.resolvedType;

    final supportsDataStream =
        scannedType?.isMyoBandFamily == true ||
        resolvedType?.isMyoBandFamily == true;

    return _DeviceInfoViewState(
      displayName: displayName,
      connectionStatus: state.connectionStatusFor(deviceId),
      connection: connection,
      streamSnapshot: state.streamSnapshotFor(deviceId),
      supportsDataStream: supportsDataStream,
      isConnected: connection?.status.isConnected ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _DeviceInfoViewState &&
        displayName == other.displayName &&
        connectionStatus == other.connectionStatus &&
        connection == other.connection &&
        streamSnapshot == other.streamSnapshot &&
        supportsDataStream == other.supportsDataStream &&
        isConnected == other.isConnected;
  }

  @override
  int get hashCode => Object.hash(
    displayName,
    connectionStatus,
    connection,
    streamSnapshot,
    supportsDataStream,
    isConnected,
  );
}

class _DisconnectedBanner extends StatelessWidget {
  const _DisconnectedBanner();

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: const Text('Device disconnected'),
      leading: const Icon(Icons.bluetooth_disabled, color: Colors.orange),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Back'),
        ),
      ],
    );
  }
}

class _DeviceHeader extends StatelessWidget {
  const _DeviceHeader({
    required this.displayName,
    required this.deviceId,
    required this.connectionStatus,
  });

  final String displayName;
  final String deviceId;
  final BleConnectionStatus connectionStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(deviceId, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          'Status: ${connectionStatus.label}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: connectionStatus == BleConnectionStatus.disconnected
                ? Colors.orange
                : connectionStatus.isConnected
                ? Colors.green
                : null,
            fontWeight: connectionStatus == BleConnectionStatus.disconnected
                ? FontWeight.bold
                : null,
          ),
        ),
      ],
    );
  }
}

class _DeviceMetadataCard extends StatelessWidget {
  const _DeviceMetadataCard({
    required this.connection,
    required this.displayName,
  });

  final BleActiveConnection? connection;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (connection == null) {
      return const Text('No active connection for this device.');
    }

    if (connection!.isReadingInfo) {
      return Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('Reading device info for $displayName…')),
        ],
      );
    }

    if (connection!.hasError && connection!.deviceInfo == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Failed to read device info'),
            ],
          ),
          const SizedBox(height: 8),
          Text(connection!.errorMessage ?? 'Unknown error'),
        ],
      );
    }

    final info = connection!.deviceInfo;
    if (info == null) {
      return const Text('Device info is not available for this device.');
    }

    return _MetadataBody(info: info, fallbackName: displayName);
  }
}

class _MetadataBody extends StatelessWidget {
  const _MetadataBody({
    required this.info,
    required this.fallbackName,
  });

  final BleDeviceInfo info;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    final typeLabel = info.resolvedType.genName ?? info.resolvedType.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device metadata',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.sensors, color: Colors.deepPurple),
          title: Text(info.name.isEmpty ? fallbackName : info.name),
          subtitle: Text(
            'FW: ${info.firmwareVersion.isEmpty ? '-' : info.firmwareVersion}'
            ' · Battery: ${info.batteryPercent}%\n'
            'Hardware: ${info.hardwareId.isEmpty ? '-' : info.hardwareId}'
            ' · Type: $typeLabel',
          ),
          isThreeLine: true,
        ),
      ],
    );
  }
}
