import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

//TODO: [Optional] Return Hardware Id To Update Firmware
String resolveFirmwareHardwareId(VulcanDeviceType deviceType) {
  switch (deviceType) {
    default:
      return deviceType.hardwareId;
  }
}

bool isFirebaseStorageUrl(String url) {
  return url.contains('firebasestorage.googleapis.com') ||
      url.contains('appspot.com');
}
