import 'package:equatable/equatable.dart';

import 'ring_action_button_type.dart';

/// ACTION_BUTTON_UUID mapping: single tap + double tap.
class RingActionButtonMapping extends Equatable {
  const RingActionButtonMapping({
    required this.single,
    required this.doubleTap,
  });

  static const none = RingActionButtonMapping(
    single: RingActionButtonType.none,
    doubleTap: RingActionButtonType.none,
  );

  final RingActionButtonType single;
  final RingActionButtonType doubleTap;

  RingActionButtonMapping copyWith({
    RingActionButtonType? single,
    RingActionButtonType? doubleTap,
  }) {
    return RingActionButtonMapping(
      single: single ?? this.single,
      doubleTap: doubleTap ?? this.doubleTap,
    );
  }

  @override
  List<Object?> get props => [single, doubleTap];
}
