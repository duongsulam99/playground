import 'dart:typed_data';

import 'package:vulcan_mobile_playground/core/ble/enums/DFU/dfu_type.dart';

import '../../domain/entity/dfu_progress.dart';
import '../firmware_ble_transport.dart';

abstract class DfuStrategy {
  DfuType get type;

  Stream<DfuProgress> execute({
    required FirmwareBleTransport transport,
    required Uint8List firmwareBytes,
    required String deviceId,
  });
}
