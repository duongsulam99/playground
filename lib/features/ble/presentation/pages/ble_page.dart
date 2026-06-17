import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vulcan_mobile_playground/core/ble/device_type.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/ble/ble_bloc.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/ble/ble_event.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/ble/ble_state.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_adapter_banner.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_device_list.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_scan_controls.dart';

class BlePage extends StatelessWidget {
  const BlePage({super.key, this.filterTypes});

  final List<VulcanDeviceType>? filterTypes;

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
                    isEnabled:
                        state.isAdapterReady &&
                        !state.connectionStatus.isConnected,
                    onToggleScan: () {
                      context.read<BleBloc>().add(const BleEvent.scanToggled());
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Discovered devices (${state.devices.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BleDeviceList(
                    devices: state.devices,
                    onDeviceSelected: (deviceId) {
                      context.read<BleBloc>().add(
                        BleDeviceSelected(deviceId: deviceId),
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
