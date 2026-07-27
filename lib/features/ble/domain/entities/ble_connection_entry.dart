import 'package:equatable/equatable.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';

/// Slim connection status owned by [BleManagerBloc].
///
/// Device metadata (info, battery, streaming) lives on [BleDeviceBloc].
class BleConnectionEntry extends Equatable {
  const BleConnectionEntry({
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

  BleConnectionEntry copyWith({
    BleConnectionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BleConnectionEntry(
      deviceId: deviceId,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [deviceId, status, errorMessage];
}
