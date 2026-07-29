import '../global_ble_key.dart';

final class BleHandKey {
  const BleHandKey._();

  static const String ota = GlobalBleKey.ota;
  static const String nameChar = GlobalBleKey.nameChar;
  static const String hardwareChar = GlobalBleKey.hardwareChar;
  static const String connect = 'CONNECT_UUID';
  static const String setting = GlobalBleKey.setting;
  static const String technical = 'TECHNICAL_UUID';
  static const String addr = 'ADDR_UUID';
  static const String angle = 'ANGLE_UUID';
  static const String control = 'CONTROL_UUID';
  static const String battery = GlobalBleKey.battery;
}
