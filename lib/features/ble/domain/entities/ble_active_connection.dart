import 'package:equatable/equatable.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';

class BleActiveConnection extends Equatable {
  const BleActiveConnection({
    required this.deviceId,
    required this.status,
    this.errorMessage,
  });

  final String deviceId;
  final BleConnectionStatus status;
  final String? errorMessage;

  bool get isActive =>
      status == BleConnectionStatus.connecting ||
      status == BleConnectionStatus.connected ||
      status == BleConnectionStatus.disconnecting;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  @override
  List<Object?> get props => [deviceId, status, errorMessage];
}
