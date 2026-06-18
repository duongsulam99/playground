import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_adapter_banner.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_connected_devices_section.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_device_list.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_scan_controls.dart';

import '../bloc/ble/ble_bloc.dart';

class BlePage extends StatefulWidget {
  const BlePage({super.key, this.filterTypes});

  final List<VulcanDeviceType>? filterTypes;

  @override
  State<BlePage> createState() => _BlePageState();
}

class _BlePageState extends State<BlePage> {
  BleBloc? _bleBloc;

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
    _bleBloc ??= context.read<BleBloc>();
    _bleBloc?.add(BleEvent.scanFilterUpdated(filterTypes: widget.filterTypes));
  }

  void _onPageClose() {
    _bleBloc?.add(const BleEvent.stopScan());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLE Lab')),
      body: BlocConsumer<BleBloc, BleState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.status == BleStatus.failure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }

          for (final entry in state.deviceErrors.entries) {
            if (entry.value.isNotEmpty && state.status == BleStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Device ${entry.key}: ${entry.value}')),
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
                      final bloc = context.read<BleBloc>();
                      if (state.isScanning) {
                        bloc.add(const BleEvent.stopScan());
                      } else {
                        bloc.add(const BleEvent.startScan());
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  BleConnectedDevicesSection(
                    devices: state.devices,
                    deviceConnections: state.deviceConnections,
                    onDisconnect: (deviceId) {
                      context.read<BleBloc>().add(
                        BleEvent.disconnectRequested(deviceId: deviceId),
                      );
                    },
                  ),
                  if (state.hasConnectedDevices) const SizedBox(height: 16),
                  Text(
                    'Discovered devices (${state.devices.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BleDeviceList(
                    devices: state.devices,
                    deviceConnections: state.deviceConnections,
                    onDeviceSelected: (deviceId) {
                      context.read<BleBloc>().add(
                        BleEvent.connectRequested(deviceId: deviceId),
                      );
                    },
                    onDeviceDisconnect: (deviceId) {
                      context.read<BleBloc>().add(
                        BleEvent.disconnectRequested(deviceId: deviceId),
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
