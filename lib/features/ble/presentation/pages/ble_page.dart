import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_adapter_banner.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_connected_devices_section.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_device_list.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_scan_controls.dart';

import '../bloc/manager/ble_manager_bloc.dart';

class BlePage extends StatefulWidget {
  const BlePage({super.key, this.filterTypes});

  final List<VulcanDeviceType>? filterTypes;

  @override
  State<BlePage> createState() => _BlePageState();
}

class _BlePageState extends State<BlePage> {
  BleManagerBloc? _managerBloc;

  @override
  void initState() {
    _bootstrapBlePage();
    super.initState();
  }

  @override
  void dispose() {
    _onPageClose();
    super.dispose();
  }

  void _bootstrapBlePage() {
    _managerBloc ??= context.read<BleManagerBloc>();
    _managerBloc?.add(
      BleManagerEvent.scanFilterUpdated(filterTypes: widget.filterTypes),
    );
  }

  void _onPageClose() {
    _managerBloc?.add(const BleManagerEvent.stopScan());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLE Lab')),
      body: BlocConsumer<BleManagerBloc, BleManagerState>(
        listener: (context, state) {
          if (state.errorMessage != null &&
              state.status == BleManagerStatus.failure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }

          for (final connection in state.activeConnections.values) {
            if (connection.hasError &&
                state.status == BleManagerStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Device ${connection.deviceId}: ${connection.errorMessage}',
                  ),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BleAdapterBanner(adapterStatus: state.adapterStatus),
                  const SizedBox(height: 16),
                  BleScanControls(
                    isScanning: state.isScanning,
                    isEnabled: state.isAdapterReady,
                    onToggleScan: () {
                      final bloc = context.read<BleManagerBloc>();
                      if (state.isScanning) {
                        bloc.add(const BleManagerEvent.stopScan());
                      } else {
                        bloc.add(const BleManagerEvent.startScan());
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  BleConnectedDevicesSection(
                    savedDevices: state.savedDevices,
                    activeConnections: state.activeConnections,
                    onDisconnect: (deviceId) {
                      context.read<BleManagerBloc>().add(
                        BleManagerEvent.disconnectRequested(deviceId: deviceId),
                      );
                    },
                  ),
                  if (state.hasConnectedDevices) const SizedBox(height: 16),
                  Text(
                    'Discovered devices (${state.savedDevices.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BleDeviceList(
                    savedDevices: state.savedDevices,
                    activeConnections: state.activeConnections,
                    canConnectDevice: state.canConnectDevice,
                    onDeviceSelected: (deviceId) {
                      context.read<BleManagerBloc>().add(
                        BleManagerEvent.connectRequested(deviceId: deviceId),
                      );
                    },
                    onDeviceDisconnect: (deviceId) {
                      context.read<BleManagerBloc>().add(
                        BleManagerEvent.disconnectRequested(deviceId: deviceId),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
