import 'package:flutter/material.dart';

import '../pages/ble_device_info_page.dart';

class BleDeviceInfoRoute {
  static const String path = '/ble/device-info';

  static Route<void> route({required String deviceId}) {
    return MaterialPageRoute<void>(
      builder: (_) => BleDeviceInfoPage(deviceId: deviceId),
    );
  }
}
