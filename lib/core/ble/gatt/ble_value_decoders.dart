import 'package:flutter/foundation.dart';
import 'package:flutter_supper_app_core/core.dart';

class BleValueDecoders {
  const BleValueDecoders._();

  static final _logger = const Logger(className: 'BleValueDecoders');

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

    // _logger.debug('rawBytes', rawBytes);

    // Chuyển List<int> → Uint8List → ByteData
    final bytes = Uint8List.fromList(rawBytes);
    final Float32List floats = Float32List.view(
      bytes.buffer,
      bytes.offsetInBytes,
      8, // số float trong gói
    );

    _logger.debug('floats', floats);

    // Bắt đầu giải mã
    // 3 floats đầu là EMG: emg0, emg1, emg2
    final double emg0 = floats[0];
    final double emg1 = floats[1];
    final double emg2 = floats[2];

    // float 4 là: Magnitude Gyro
    final double magGyro = floats[3];

    // float 5 là: Pitch
    final double pitch = floats[4];

    // float 6 là: Roll
    final double roll = floats[5];

    // float 7 là: Yaw
    final double yaw = floats[6];

    // float 8 là: Timestamp
    final double timestamp = floats[7];

    return [emg0, emg1, emg2, magGyro, pitch, roll, yaw, timestamp];
  }
}
