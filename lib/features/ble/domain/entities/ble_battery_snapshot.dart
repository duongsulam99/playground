import 'package:equatable/equatable.dart';

/// Snapshot pin realtime từ BATTERY_UUID notify.
class BleBatterySnapshot extends Equatable {
  const BleBatterySnapshot({
    required this.percent,
    required this.isCharging,
  });

  final int percent;
  final bool isCharging;

  @override
  List<Object?> get props => [percent, isCharging];
}
