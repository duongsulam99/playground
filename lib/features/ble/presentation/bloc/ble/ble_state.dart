part of 'ble_bloc.dart';

enum BleStatus { initial, loading, success, failure }

@freezed
abstract class BleState with _$BleState {
  const factory BleState({
    @Default(BleAdapterStatus.unknown) BleAdapterStatus adapterStatus,
    @Default(false) bool isScanning,
    @Default(<BleDiscoveredDevice>[]) List<BleDiscoveredDevice> savedDevices,
    @Default(<BleActiveConnection>[]) List<BleActiveConnection> activeConnections,
    @Default(1) int deviceLimit,
    String? errorMessage,
    @Default(BleStatus.initial) BleStatus status,
    List<VulcanDeviceType>? scanFilterTypes,
  }) = _BleState;
}

extension BleStateX on BleState {
  bool get isAdapterReady => adapterStatus.isReady;

  bool get hasConnectedDevices =>
      activeConnections.any((connection) => connection.status.isConnected);

  int get connectingCount => activeConnections
      .where((connection) => connection.status == BleConnectionStatus.connecting)
      .length;

  int get connectedCount => activeConnections
      .where((connection) => connection.status.isConnected)
      .length;

  int get activeDeviceCount =>
      activeConnections.where((connection) => connection.isActive).length;

  bool get isAtDeviceLimit => activeDeviceCount >= deviceLimit;

  bool canConnectDevice(String deviceId) {
    final existing = activeConnectionFor(deviceId);
    if (existing?.isActive == true) return true;
    return activeDeviceCount < deviceLimit;
  }

  BleActiveConnection? activeConnectionFor(String deviceId) {
    for (final connection in activeConnections) {
      if (connection.deviceId == deviceId) return connection;
    }
    return null;
  }

  bool isDeviceConnected(String deviceId) =>
      activeConnectionFor(deviceId)?.status.isConnected ?? false;

  BleConnectionStatus connectionStatusFor(String deviceId) =>
      activeConnectionFor(deviceId)?.status ?? BleConnectionStatus.disconnected;
}
