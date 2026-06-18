import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message, {this.deviceId});

  final String message;
  final String? deviceId;

  @override
  List<Object?> get props => [message, deviceId];
}

class BleFailure extends Failure {
  const BleFailure(super.message, {super.deviceId});
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}
