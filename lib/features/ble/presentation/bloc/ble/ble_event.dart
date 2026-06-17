import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';

part 'ble_event.freezed.dart';

@freezed
sealed class BleEvent with _$BleEvent {
  const factory BleEvent.scanToggled() = BleScanToggled;

  const factory BleEvent.deviceSelected({
    required String deviceId,
  }) = BleDeviceSelected;

  const factory BleEvent.disconnectRequested() = BleDisconnectRequested;

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
