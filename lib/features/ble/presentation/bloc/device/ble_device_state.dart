part of 'ble_device_bloc.dart';

enum BleDeviceStatus { initial, loading, success, failure }

@freezed
abstract class BleDeviceState with _$BleDeviceState {
  const factory BleDeviceState({
    required String deviceId,
    required VulcanDeviceType scannedType,
    required BleDeviceCapabilities capabilities,
    VulcanDeviceType? resolvedType,
    BleDeviceInfo? deviceInfo,
    BleBatterySnapshot? battery,
    @Default(false) bool isReadingInfo,
    @Default(false) bool isStreaming,
    BleDeviceStreamSnapshot? streamSnapshot,
    String? errorMessage,
    @Default(BleDeviceStatus.initial) BleDeviceStatus status,
  }) = _BleDeviceState;
}

extension BleDeviceStateX on BleDeviceState {
  VulcanDeviceType get type {
    if (resolvedType != null) return resolvedType!;
    if (deviceInfo?.resolvedType != null) return deviceInfo!.resolvedType;
    return scannedType;
  }

  bool get supportsDataStream => capabilities.supportsDecodedStream;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
}
