part of 'ble_bloc.dart';

enum BleStatus { initial, loading, success, failure }

@freezed
abstract class BleState with _$BleState {
  const factory BleState({
    @Default(BleAdapterStatus.unknown) BleAdapterStatus adapterStatus,
    @Default(false) bool isScanning,
    @Default({}) Map<String, BleDiscoveredDevice> savedDevices,
    @Default({}) Map<String, BleActiveConnection> activeConnections,
    String? errorMessage,
    @Default(BleStatus.initial) BleStatus status,
    List<VulcanDeviceType>? scanFilterTypes,
  }) = _BleState;
}

extension BleStateX on BleState {
  bool get isAdapterReady => adapterStatus.isReady;

  bool get hasConnectedDevices => activeConnections.values.any(
    (connection) => connection.status.isConnected,
  );

  int get connectingCount => activeConnections.values
      .where((connection) => connection.status == BleConnectionStatus.connecting)
      .length;

  int get connectedCount => activeConnections.values
      .where((connection) => connection.status.isConnected)
      .length;

  int get activeDeviceCount => activeConnections.values
      .where((connection) => connection.isActive)
      .length;

  bool get isAtDeviceLimit => activeDeviceCount >= VulcanConstant.deviceLimit;

  bool canConnectDevice(String deviceId) {
    final existing = activeConnectionFor(deviceId);
    if (existing?.isActive == true) return true;
    return activeDeviceCount < VulcanConstant.deviceLimit;
  }

  BleActiveConnection? activeConnectionFor(String deviceId) =>
      activeConnections[deviceId];

  BleDiscoveredDevice? savedDeviceFor(String deviceId) =>
      savedDevices[deviceId];

  bool isDeviceConnected(String deviceId) =>
      activeConnectionFor(deviceId)?.status.isConnected ?? false;

  BleConnectionStatus connectionStatusFor(String deviceId) =>
      activeConnectionFor(deviceId)?.status ?? BleConnectionStatus.disconnected;
}
