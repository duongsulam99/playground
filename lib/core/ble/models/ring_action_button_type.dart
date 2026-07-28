import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

/// Physical action-button mapping on MyoBand/Ring (ACTION_BUTTON_UUID).
enum RingActionButtonType {
  none(0, 'None'),
  logic(1, 'Logic'),
  speed(2, 'Speed'),
  force(3, 'Force'),
  controlGrip(4, 'Control Grip'),
  vibrate(5, 'Vibrate');

  const RingActionButtonType(this.bleIndex, this.title);

  final int bleIndex;
  final String title;

  static RingActionButtonType fromBleIndex(int index) {
    return switch (index) {
      1 => RingActionButtonType.logic,
      2 => RingActionButtonType.speed,
      3 => RingActionButtonType.force,
      4 => RingActionButtonType.controlGrip,
      5 => RingActionButtonType.vibrate,
      _ => RingActionButtonType.none,
    };
  }

  /// Actions offered in configuration UI (parity va_client ActionButtonPickerPage).
  static List<RingActionButtonType> availableForDevice(VulcanDeviceType type) {
    if (type == VulcanDeviceType.wrist) {
      return const [
        RingActionButtonType.none,
        RingActionButtonType.logic,
        RingActionButtonType.speed,
        RingActionButtonType.force,
        RingActionButtonType.controlGrip,
      ];
    }

    return const [
      RingActionButtonType.none,
      RingActionButtonType.logic,
      RingActionButtonType.speed,
      RingActionButtonType.force,
    ];
  }
}
