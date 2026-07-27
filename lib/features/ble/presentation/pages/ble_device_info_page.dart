import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/DFU/dfu_type.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_threshold_config.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_battery_snapshot.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_device_info.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/device/ble_device_bloc.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/device/ble_device_bloc_registry.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/manager/ble_manager_bloc.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/emg_chart/emg_live_chart_section.dart';
import 'package:vulcan_mobile_playground/features/firmware/presentation/routing/firmware_update_args.dart';
import 'package:vulcan_mobile_playground/features/firmware/presentation/routing/firmware_update_route.dart';

class BleDeviceInfoPage extends StatefulWidget {
  const BleDeviceInfoPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  State<BleDeviceInfoPage> createState() => _BleDeviceInfoPageState();
}

class _BleDeviceInfoPageState extends State<BleDeviceInfoPage> {
  BleDeviceBloc? _deviceBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startStreamIfNeeded());
  }

  @override
  void dispose() {
    final bloc = _deviceBloc;
    if (bloc != null && !bloc.isClosed) {
      bloc.add(const BleDeviceEvent.stopStream());
    }
    super.dispose();
  }

  void _startStreamIfNeeded() {
    final registry = context.read<BleDeviceBlocRegistry>();
    _deviceBloc = registry.get(widget.deviceId);
    if (_deviceBloc == null) return;

    final state = _deviceBloc!.state;
    if (state.supportsDataStream) {
      _deviceBloc!.add(const BleDeviceEvent.startStream());
    }
  }

  @override
  Widget build(BuildContext context) {
    final registry = context.read<BleDeviceBlocRegistry>();
    final deviceBloc = registry.get(widget.deviceId);

    if (deviceBloc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Device info')),
        body: const Center(child: Text('Device session is not active.')),
      );
    }

    return BlocProvider.value(
      value: deviceBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Device info')),
        body: BlocBuilder<BleManagerBloc, BleManagerState>(
          buildWhen: (previous, current) =>
              previous.connectionStatusFor(widget.deviceId) !=
                  current.connectionStatusFor(widget.deviceId) ||
              previous.savedDeviceFor(widget.deviceId) !=
                  current.savedDeviceFor(widget.deviceId),
          builder: (context, managerState) {
            return BlocSelector<
              BleDeviceBloc,
              BleDeviceState,
              _DeviceInfoViewState
            >(
              selector: (deviceState) => _DeviceInfoViewState.from(
                managerState: managerState,
                deviceState: deviceState,
                deviceId: widget.deviceId,
              ),
              builder: (context, viewState) {
                final threshold =
                    viewState.deviceInfo?.thresholdConfig?.threshold;
                final emgLower = threshold?.elementAtOrNull(1) ?? 30;
                final emgUpper = threshold?.elementAtOrNull(2) ?? 50;

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
                        deviceId: widget.deviceId,
                        connectionStatus: viewState.connectionStatus,
                      ),
                      const SizedBox(height: 16),
                      _DeviceMetadataCard(
                        displayName: viewState.displayName,
                        isConnected: viewState.isConnected,
                      ),
                      const SizedBox(height: 16),
                      EmgLiveChartSection(
                        deviceId: widget.deviceId,
                        emgLower: emgLower,
                        emgUpper: emgUpper,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DeviceInfoViewState {
  const _DeviceInfoViewState({
    required this.displayName,
    required this.connectionStatus,
    required this.deviceInfo,
    required this.supportsDataStream,
    required this.isConnected,
    required this.isStreaming,
  });

  final String displayName;
  final BleConnectionStatus connectionStatus;
  final BleDeviceInfo? deviceInfo;
  final bool supportsDataStream;
  final bool isConnected;
  final bool isStreaming;

  factory _DeviceInfoViewState.from({
    required BleManagerState managerState,
    required BleDeviceState deviceState,
    required String deviceId,
  }) {
    final savedDevice = managerState.savedDeviceFor(deviceId);
    final displayName = savedDevice?.displayName ?? deviceId;

    return _DeviceInfoViewState(
      displayName: displayName,
      connectionStatus: managerState.connectionStatusFor(deviceId),
      deviceInfo: deviceState.deviceInfo,
      supportsDataStream: deviceState.supportsDataStream,
      isConnected: managerState.isDeviceConnected(deviceId),
      isStreaming: deviceState.isStreaming,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _DeviceInfoViewState &&
        displayName == other.displayName &&
        connectionStatus == other.connectionStatus &&
        deviceInfo == other.deviceInfo &&
        supportsDataStream == other.supportsDataStream &&
        isConnected == other.isConnected &&
        isStreaming == other.isStreaming;
  }

  @override
  int get hashCode => Object.hash(
    displayName,
    connectionStatus,
    deviceInfo,
    supportsDataStream,
    isConnected,
    isStreaming,
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
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
    required this.displayName,
    required this.isConnected,
  });

  final String displayName;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: BlocBuilder<BleDeviceBloc, BleDeviceState>(
          builder: (context, deviceState) =>
              _buildContent(context, deviceState),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BleDeviceState deviceState) {
    if (deviceState.isReadingInfo) {
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

    if (deviceState.hasError && deviceState.deviceInfo == null) {
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
          Text(deviceState.errorMessage ?? 'Unknown error'),
        ],
      );
    }

    final info = deviceState.deviceInfo;
    if (info == null) {
      return const Text('Device info is not available for this device.');
    }

    return _MetadataBody(
      info: info,
      battery: deviceState.battery,
      fallbackName: displayName,
      deviceId: deviceState.deviceId,
      isConnected: isConnected,
    );
  }
}

class _MetadataBody extends StatelessWidget {
  const _MetadataBody({
    required this.info,
    required this.battery,
    required this.fallbackName,
    required this.deviceId,
    required this.isConnected,
  });

  final BleDeviceInfo info;
  final BleBatterySnapshot? battery;
  final String fallbackName;
  final String deviceId;
  final bool isConnected;

  String get _batteryLabel {
    if (battery == null) return 'Battery: —';
    final charging = battery!.isCharging ? ' ⚡' : '';
    return 'Battery: ${battery!.percent}%$charging';
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = info.resolvedType.genName ?? info.resolvedType.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device metadata',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListTile(
          isThreeLine: true,
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.sensors, color: Colors.deepPurple),
          title: Text(info.name.isEmpty ? fallbackName : info.name),
          subtitle: Text(
            'FW: ${info.firmwareVersion.isEmpty ? '-' : info.firmwareVersion}'
            ' · $_batteryLabel\n'
            'Hardware: ${info.hardwareId.isEmpty ? '-' : info.hardwareId}'
            ' · Type: $typeLabel',
          ),
        ),
        if (info.thresholdConfig != null) ...[
          const SizedBox(height: 8),
          _ThresholdSummary(config: info.thresholdConfig!),
        ],
        if (isConnected && info.resolvedType.dfuType != DfuType.none) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  FirmwareUpdateRoute.path,
                  arguments: FirmwareUpdateArgs(
                    deviceId: deviceId,
                    deviceType: info.resolvedType,
                    currentFirmwareVersion: info.firmwareVersion,
                  ),
                );
              },
              icon: const Icon(Icons.system_update),
              label: const Text('Check firmware update'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ThresholdSummary extends StatelessWidget {
  const _ThresholdSummary({required this.config});

  final RingThresholdConfig config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Threshold config',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Hand up: ${config.handUp}° · Hand down: ${config.handDown}°\n'
          'Move: ${config.move.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
