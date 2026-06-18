part of 'ble_bloc.dart';

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
