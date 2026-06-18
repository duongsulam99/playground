import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';

part 'ble_event.freezed.dart';

@freezed
sealed class BleEvent with _$BleEvent {
  const factory BleEvent.scanFilterUpdated({
    List<VulcanDeviceType>? filterTypes,
  }) = BleScanFilterUpdated;

  const factory BleEvent.startScan() = BleStartScan;

  const factory BleEvent.stopScan() = BleStopScan;

  const factory BleEvent.connectRequested({
    required String deviceId,
  }) = BleConnectRequested;

  const factory BleEvent.disconnectRequested({
    required String deviceId,
  }) = BleDisconnectRequested;

  const factory BleEvent.adapterStatusUpdated({
    required BleAdapterStatus status,
  }) = BleAdapterStatusUpdated;

  const factory BleEvent.scanResultsUpdated({
    required List<BleDiscoveredDevice> devices,
  }) = BleScanResultsUpdated;

  const factory BleEvent.streamFailed({
    required String message,
  }) = BleStreamFailed;
}
