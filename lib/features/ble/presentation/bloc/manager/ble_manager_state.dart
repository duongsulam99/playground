part of 'ble_manager_bloc.dart';

enum BleManagerStatus { initial, loading, success, failure }

@freezed
abstract class BleManagerState with _$BleManagerState {
  const factory BleManagerState({
    @Default(BleAdapterStatus.unknown) BleAdapterStatus adapterStatus,
    @Default(false) bool isScanning,
    @Default(BleScanSnapshot.empty) BleScanSnapshot savedDevices,
    @Default({}) Map<String, BleConnectionEntry> activeConnections,
    String? errorMessage,
    @Default(BleManagerStatus.initial) BleManagerStatus status,
    List<VulcanDeviceType>? scanFilterTypes,
  }) = _BleManagerState;
}

extension BleManagerStateX on BleManagerState {
  bool get isAdapterReady => adapterStatus.isReady;

  bool get hasConnectedDevices => activeConnections.values.any(
    (connection) => connection.status.isConnected,
  );

  int get connectingCount => activeConnections.values
      .where(
        (connection) => connection.status == BleConnectionStatus.connecting,
      )
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

  BleConnectionEntry? activeConnectionFor(String deviceId) {
    if (activeConnections[deviceId] == null) return null;
    return activeConnections[deviceId];
  }

  BleDiscoveredDevice? savedDeviceFor(String deviceId) {
    if (savedDevices[deviceId] == null) return null;
    return savedDevices[deviceId];
  }

  bool isDeviceConnected(String deviceId) {
    if (activeConnectionFor(deviceId) == null) return false;
    return activeConnectionFor(deviceId)!.status.isConnected;
  }

  BleConnectionStatus connectionStatusFor(String deviceId) {
    if (activeConnectionFor(deviceId) == null) BleConnectionStatus.disconnected;
    return activeConnectionFor(deviceId)!.status;
  }
}
