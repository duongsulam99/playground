import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';

part 'ble_state.freezed.dart';

enum BleStatus { initial, loading, success, failure }

@freezed
abstract class BleState with _$BleState {
  const factory BleState({
    @Default(BleAdapterStatus.unknown) BleAdapterStatus adapterStatus,
    @Default(false) bool isScanning,
    @Default(<BleDiscoveredDevice>[]) List<BleDiscoveredDevice> devices,
    @Default(BleConnectionStatus.disconnected)
    BleConnectionStatus connectionStatus,
    String? connectedDeviceId,
    String? errorMessage,
    @Default(BleStatus.initial) BleStatus status,
  }) = _BleState;
}

extension BleStateX on BleState {
  bool get isAdapterReady => adapterStatus.isReady;
}
