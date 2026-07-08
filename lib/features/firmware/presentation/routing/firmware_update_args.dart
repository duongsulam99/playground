import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

class FirmwareUpdateArgs {
  const FirmwareUpdateArgs({
    required this.deviceId,
    required this.deviceType,
    required this.currentFirmwareVersion,
  });

  final String deviceId;
  final VulcanDeviceType deviceType;
  final String currentFirmwareVersion;
}
