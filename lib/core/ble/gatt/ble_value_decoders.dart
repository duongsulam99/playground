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

  /// Trả về 3 kênh voltage. Tham khảo logic legacy:
  /// ringCalibEMG.dart (Float32List.view, floats[0..2] = emg0/emg1/emg2)
  static List<double> decodeEmgVoltages(List<int> rawBytes) {
    if (rawBytes.length < 32) return [];

    // Chuyển List<int> → Uint8List → ByteData
    final bytes = Uint8List.fromList(rawBytes);
    final Float32List floats = Float32List.view(
      bytes.buffer,
      bytes.offsetInBytes,
      8, // số float trong gói
    );

    // Bắt đầu giải mã
    final double emg0 = floats[0];
    final double emg1 = floats[1];
    final double emg2 = floats[2];

    return [emg0, emg1, emg2];
  }
}
