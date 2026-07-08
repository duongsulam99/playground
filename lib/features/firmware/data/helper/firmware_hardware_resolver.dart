import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

String resolveFirmwareHardwareId(VulcanDeviceType deviceType) {
  if (deviceType == VulcanDeviceType.ring) {
    return 'EMGA0001';
  }
  return deviceType.hardwareId;
}

bool isFirebaseStorageUrl(String url) {
  return url.contains('firebasestorage.googleapis.com') ||
      url.contains('appspot.com');
}
