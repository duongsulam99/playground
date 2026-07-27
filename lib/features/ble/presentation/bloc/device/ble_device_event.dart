part of 'ble_device_bloc.dart';

@freezed
sealed class BleDeviceEvent with _$BleDeviceEvent {
  const factory BleDeviceEvent.sessionStarted() = BleDeviceSessionStarted;

  const factory BleDeviceEvent.readInfoRequested() = BleDeviceReadInfoRequested;

  const factory BleDeviceEvent.startStream() = BleDeviceStartStream;

  const factory BleDeviceEvent.stopStream({@Default(true) bool stopHardware}) =
      BleDeviceStopStream;

  const factory BleDeviceEvent.listenData() = BleDeviceListenData;

  const factory BleDeviceEvent.batteryUpdated({
    required BleBatterySnapshot battery,
  }) = BleDeviceBatteryUpdated;

  const factory BleDeviceEvent.sessionEnded({
    @Default(true) bool stopHardware,
  }) = BleDeviceSessionEnded;
}
