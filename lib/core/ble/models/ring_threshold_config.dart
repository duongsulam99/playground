import 'package:equatable/equatable.dart';

/// Ring THRESHOLD_UUID payload (28-byte binary, little-endian).
/// Ported from legacy `ringThreshold.dart` — read/decode only for v1.
class RingThresholdConfig extends Equatable {
  const RingThresholdConfig({
    required this.threshold,
    required this.exThreshold,
    required this.handUp,
    this.handUpEn,
    required this.handDown,
    this.handDownEn,
    required this.move,
    this.moveEn,
    this.forceSync,
    required this.epochTime,
  });

  final List<int> threshold;
  final List<int> exThreshold;
  final int handUp;
  final bool? handUpEn;
  final int handDown;
  final bool? handDownEn;
  final double move;
  final bool? moveEn;
  final bool? forceSync;
  final int epochTime;

  @override
  List<Object?> get props => [
    threshold,
    exThreshold,
    handUp,
    handUpEn,
    handDown,
    handDownEn,
    move,
    moveEn,
    forceSync,
    epochTime,
  ];
}
