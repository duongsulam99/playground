import 'dart:convert';

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
}
