part of 'ble_manager_bloc.dart';

@freezed
sealed class BleManagerEvent with _$BleManagerEvent {
  const factory BleManagerEvent.scanFilterUpdated({
    List<VulcanDeviceType>? filterTypes,
  }) = BleManagerScanFilterUpdated;

  const factory BleManagerEvent.startScan() = BleManagerStartScan;

  const factory BleManagerEvent.stopScan() = BleManagerStopScan;

  const factory BleManagerEvent.connectRequested({required String deviceId}) =
      BleManagerConnectRequested;

  const factory BleManagerEvent.disconnectRequested({
    required String deviceId,
  }) = BleManagerDisconnectRequested;

  const factory BleManagerEvent.adapterStatusUpdated({
    required BleAdapterStatus status,
  }) = BleManagerAdapterStatusUpdated;

  const factory BleManagerEvent.scanResultsUpdated({
    required BleScanSnapshot savedDevices,
  }) = BleManagerScanResultsUpdated;

  const factory BleManagerEvent.connectionLost({required String deviceId}) =
      BleManagerConnectionLost;

  const factory BleManagerEvent.streamFailed({required String message}) =
      BleManagerStreamFailed;
}
