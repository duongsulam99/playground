import 'package:flutter/foundation.dart';
import 'package:flutter_supper_app_core/core.dart';

import '../models/ring_threshold_config.dart';

extension ListIntExtension on List<int> {
  Uint8List toUint8List() {
    if (this is Uint8List) {
      return this as Uint8List;
    }

    return Uint8List.fromList(this);
  }
}

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
    final bytes = rawBytes.toUint8List();
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

  static RingThresholdConfig? decodeRingThreshold(List<int> rawBytes) {
    if (rawBytes.isEmpty) return null;

    final bytes = rawBytes.toUint8List();

    _logger.debug('bytes', bytes);

    final bd = ByteData.sublistView(bytes);
    final len = bytes.lengthInBytes;

    final thresholds = List<int>.filled(4, 0);
    for (var i = 0; i < 4; i++) {
      final offset = i * 2;
      if (bytes.length >= offset + 2) {
        thresholds[i] = bd.getUint16(offset, Endian.little);
      }
    }

    _logger.debug('thresholds', thresholds);

    final exThresholds = List<int>.filled(4, 0);
    for (var i = 0; i < 4; i++) {
      final offset = 8 + i * 2;
      if (bytes.length >= offset + 2) {
        exThresholds[i] = bd.getUint16(offset, Endian.little);
      }
    }

    _logger.debug('exThresholds', exThresholds);

    final handUp = len >= 17 ? bd.getInt8(16) : 0;
    final handUpEn = handUp != 0;

    _logger.debug('handUp', handUp);
    _logger.debug('handUpEn', handUpEn);

    final handDown = len >= 18 ? bd.getInt8(17) : 0;
    final handDownEn = handDown != 0;

    _logger.debug('handDown', handDown);
    _logger.debug('handDownEn', handDownEn);

    final move = len >= 22 ? bd.getFloat32(18, Endian.little) : 0.0;
    final moveEn = move != 0.0;

    _logger.debug('move', move);
    _logger.debug('moveEn', moveEn);

    final epochTime = len >= 26 ? bd.getUint32(22, Endian.little) : 0;
    _logger.debug('epochTime', epochTime);

    return RingThresholdConfig(
      threshold: thresholds,
      exThreshold: exThresholds,
      handUp: handUp,
      handUpEn: handUpEn,
      handDown: handDown,
      handDownEn: handDownEn,
      move: move,
      moveEn: moveEn,
      epochTime: epochTime,
    );
  }
}
