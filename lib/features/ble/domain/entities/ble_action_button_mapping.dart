import 'package:equatable/equatable.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_action_button_type.dart';

/// Domain view of ACTION_BUTTON_UUID mapping (single / double tap).
class BleActionButtonMapping extends Equatable {
  const BleActionButtonMapping({required this.single, required this.doubleTap});

  final RingActionButtonType single;
  final RingActionButtonType doubleTap;

  @override
  List<Object?> get props => [single, doubleTap];
}
