import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_action_button_mapping.dart';

/// Display label for ACTION_BUTTON_UUID mapping on device info screens.
String formatActionButtonMappingLabel(BleActionButtonMapping? mapping) {
  if (mapping == null) return 'Action buttons: —';
  return 'Action: Single tap — ${mapping.single.title}'
      ' · Double tap — ${mapping.doubleTap.title}';
}
