part of 'ble_bloc.dart';

@freezed
sealed class BleEvent with _$BleEvent {
  const factory BleEvent.scanFilterUpdated({
    List<VulcanDeviceType>? filterTypes,
  }) = BleScanFilterUpdated;

  const factory BleEvent.startScan() = BleStartScan;

  const factory BleEvent.stopScan() = BleStopScan;

  const factory BleEvent.connectRequested({required String deviceId}) =
      BleConnectRequested;

  const factory BleEvent.disconnectRequested({required String deviceId}) =
      BleDisconnectRequested;

  const factory BleEvent.startDeviceStream({required String deviceId}) =
      BleStartDeviceStream;

  const factory BleEvent.stopDeviceStream({required String deviceId}) =
      BleStopDeviceStream;

  const factory BleEvent.adapterStatusUpdated({
    required BleAdapterStatus status,
  }) = BleAdapterStatusUpdated;

  const factory BleEvent.scanResultsUpdated({
    required Map<String, BleDiscoveredDevice> savedDevices,
  }) = BleScanResultsUpdated;

  const factory BleEvent.deviceStreamUpdated({
    required String deviceId,
    required BleDeviceStreamSnapshot snapshot,
  }) = BleDeviceStreamUpdated;

  const factory BleEvent.connectionLost({required String deviceId}) =
      BleConnectionLost;

  const factory BleEvent.streamFailed({required String message}) =
      BleStreamFailed;
}
