import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/ble/ble_bloc.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/ble/ble_event.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/ble/ble_state.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_adapter_banner.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_device_list.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/ble_scan_controls.dart';

class BlePage extends StatelessWidget {
  const BlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Lab'),
      ),
      body: BlocConsumer<BleBloc, BleState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.status == BleStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              BleAdapterBanner(adapterStatus: state.adapterStatus),
              const SizedBox(height: 16),
              BleScanControls(
                isScanning: state.isScanning,
                isEnabled: state.isAdapterReady &&
                    !state.connectionStatus.isConnected,
                onToggleScan: () {
                  context.read<BleBloc>().add(const BleEvent.scanToggled());
                },
              ),
              const SizedBox(height: 16),
              if (state.status == BleStatus.loading &&
                  state.connectionStatus == BleConnectionStatus.connecting)
                const Center(child: CircularProgressIndicator()),
              if (state.connectionStatus.isConnected) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.bluetooth_connected),
                    title: Text(
                      'Connected: ${state.connectedDeviceId ?? 'Unknown'}',
                    ),
                    subtitle: Text(state.connectionStatus.label),
                    trailing: FilledButton.tonal(
                      onPressed: () {
                        context
                            .read<BleBloc>()
                            .add(const BleEvent.disconnectRequested());
                      },
                      child: const Text('Disconnect'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
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
                  context
                      .read<BleBloc>()
                      .add(BleEvent.deviceSelected(deviceId: deviceId));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
