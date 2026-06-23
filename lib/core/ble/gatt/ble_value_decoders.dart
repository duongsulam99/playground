import 'dart:convert';

import 'package:flutter/foundation.dart';

class BleValueDecoders {
  const BleValueDecoders._();

  static String decodeUtf8(List<int> bytes) {
    if (bytes.isEmpty) return '';
    return utf8.decode(bytes, allowMalformed: true).trim();
  }

  static int decodeBatteryPercent(List<int> bytes) {
    if (bytes.isEmpty) return 0;
    return bytes[0];
  }

  static String decodeHardwareId(List<int> bytes) {
    var hardwareId = decodeUtf8(bytes);
    final slashIndex = hardwareId.indexOf('/');
    if (slashIndex > 0) {
      hardwareId = hardwareId.substring(0, slashIndex);
    }
    return hardwareId.trim();
  }

  List<double> decodeEMG3chPacket(List<int> data) {
    // x x x x | x x x x | x x x x | x x x x
    // channel_0, channel_1, channel_2, timestring
    // data is in Float32 format

    /// Check data length
    if (data.length != 16) return [];

    /// Convert to ByteData
    final byteData = ByteData.sublistView(Uint8List.fromList(data));

    // return [channel0, channel1, channel2, timestamp];
    return [
      byteData.getFloat32(0, Endian.little),
      byteData.getFloat32(4, Endian.little),
      byteData.getFloat32(8, Endian.little),
    ];
  }
}
