import 'package:equatable/equatable.dart';

enum DfuStatus {
  idle,
  downloading,
  unpacking,
  uploading,
  confirming,
  completed,
  failed,
}

class DfuProgress extends Equatable {
  const DfuProgress({
    required this.status,
    required this.percent,
    this.message,
  });

  final DfuStatus status;
  final double percent;
  final String? message;

  DfuProgress copyWith({DfuStatus? status, double? percent, String? message}) {
    return DfuProgress(
      status: status ?? this.status,
      percent: percent ?? this.percent,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, percent, message];
}
