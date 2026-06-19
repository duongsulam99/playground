import 'package:equatable/equatable.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';

import 'myo_band_device_info.dart';

class BleActiveConnection extends Equatable {
  const BleActiveConnection({
    required this.deviceId,
    required this.status,
    this.errorMessage,
    this.myoBandInfo,
    this.isReadingInfo = false,
  });

  final String deviceId;
  final BleConnectionStatus status;
  final String? errorMessage;
  final MyoBandDeviceInfo? myoBandInfo;
  final bool isReadingInfo;

  bool get isActive =>
      status == BleConnectionStatus.connecting ||
      status == BleConnectionStatus.connected ||
      status == BleConnectionStatus.disconnecting;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  @override
  List<Object?> get props => [
    deviceId,
    status,
    errorMessage,
    myoBandInfo,
    isReadingInfo,
  ];
}
