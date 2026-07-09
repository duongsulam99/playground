import 'dart:convert';

class BleValueEncoders {
  const BleValueEncoders._();

  static List<int> encodeUtf8(String value) {
    if (value.isEmpty) return <int>[];

    try {
      return utf8.encode(value);
    } catch (error) {
      return <int>[];
    }
  }
}
