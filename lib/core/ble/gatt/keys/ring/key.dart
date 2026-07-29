import '../global_ble_key.dart';

final class BleRingKey {
  const BleRingKey._();

  static const String ota = GlobalBleKey.ota;
  static const String nameChar = GlobalBleKey.nameChar;
  static const String hardwareChar = GlobalBleKey.hardwareChar;
  static const String modeChar = 'MODE_CHAR_UUID';
  static const String vibrationChar = 'VIBRATION_CHAR_UUID';
  static const String actionButton = 'ACTION_BUTTON_UUID';
  static const String signal = GlobalBleKey.signal;
  static const String medical = 'MEDICAL_UUID';
  static const String threshold = 'THRESHOLD_UUID';
  static const String logic = GlobalBleKey.logic;
  static const String stateControl = GlobalBleKey.stateControl;
  static const String battery = GlobalBleKey.battery;
  static const String countControl = 'COUNT_CONTROL_UUID';
  static const String calibHistory = 'CALIB_HISTORY_UUID';
  static const String smpChar = 'SMP_CHAR_UUID';
  static const String setting = GlobalBleKey.setting;
}
