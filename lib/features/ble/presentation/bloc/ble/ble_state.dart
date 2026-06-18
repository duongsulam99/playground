import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';

part 'ble_state.freezed.dart';

enum BleStatus { initial, loading, success, failure }

@freezed
abstract class BleState with _$BleState {
  const factory BleState({
    @Default(BleAdapterStatus.unknown) BleAdapterStatus adapterStatus,
    @Default(false) bool isScanning,
    @Default(<BleDiscoveredDevice>[]) List<BleDiscoveredDevice> devices,
    @Default(<String, BleConnectionStatus>{})
    Map<String, BleConnectionStatus> deviceConnections,
    @Default(<String, String>{}) Map<String, String> deviceErrors,
    String? errorMessage,
    @Default(BleStatus.initial) BleStatus status,
    List<VulcanDeviceType>? scanFilterTypes,
  }) = _BleState;
}

extension BleStateX on BleState {
  bool get isAdapterReady => adapterStatus.isReady;

  bool get hasConnectedDevices =>
      deviceConnections.values.any((status) => status.isConnected);

  bool isDeviceConnected(String deviceId) =>
      deviceConnections[deviceId]?.isConnected ?? false;

  BleConnectionStatus connectionStatusFor(String deviceId) =>
      deviceConnections[deviceId] ?? BleConnectionStatus.disconnected;
}
