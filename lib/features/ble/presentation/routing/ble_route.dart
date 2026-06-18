import 'package:flutter/material.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/pages/ble_page.dart';

class BleRoute {
  static const String path = '/ble';

  static Route<void> route({List<VulcanDeviceType>? filterTypes}) {
    return MaterialPageRoute<void>(
      builder: (_) => BlePage(filterTypes: filterTypes),
    );
  }
}
