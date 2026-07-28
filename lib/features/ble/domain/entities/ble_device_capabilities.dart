import 'package:equatable/equatable.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

/// Presentation-level capability flags for a connected BLE device.
///
/// Mirrors optional capabilities on [DeviceRemoteDS] (`info`, `ringSession`,
/// `streaming`) so UI / [BleDeviceBloc] can avoid unsupported use-case calls.
///
/// Keep in sync with:
/// - [VulcanDeviceTypeX.isMyoBandFamily]
/// - [BleDeviceDataSourceFactory]
class BleDeviceCapabilities extends Equatable {
  const BleDeviceCapabilities({
    required this.supportsDeviceInfo,
    required this.supportsBattery,
    required this.supportsActionButton,
    required this.supportsDecodedStream,
  });

  static const unsupported = BleDeviceCapabilities(
    supportsDeviceInfo: false,
    supportsBattery: false,
    supportsActionButton: false,
    supportsDecodedStream: false,
  );

  final bool supportsDeviceInfo;
  final bool supportsBattery;
  final bool supportsActionButton;
  final bool supportsDecodedStream;

  /// Resolves capabilities from scanned advertisement type and optional
  /// hardware-resolved type (after [readDeviceInfo]).
  factory BleDeviceCapabilities.fromDeviceTypes({
    required VulcanDeviceType scannedType,
    VulcanDeviceType? resolvedType,
  }) {
    final effective = _effectiveMyoBandFamily(scannedType, resolvedType);

    // TODO:[Add New Device] Step 2c: map non-MyoBand families (e.g. Hand)
    // to their own capability sets when those features land in presentation.
    if (effective) {
      return const BleDeviceCapabilities(
        supportsDeviceInfo: true,
        supportsBattery: true,
        supportsActionButton: true,
        supportsDecodedStream: true,
      );
    }

    return unsupported;
  }

  static bool _effectiveMyoBandFamily(
    VulcanDeviceType scannedType,
    VulcanDeviceType? resolvedType,
  ) {
    if (resolvedType != null && resolvedType != VulcanDeviceType.none) {
      return resolvedType.isMyoBandFamily;
    }
    return scannedType.isMyoBandFamily;
  }

  BleDeviceCapabilities copyWithResolved(VulcanDeviceType resolvedType) {
    return BleDeviceCapabilities.fromDeviceTypes(
      scannedType: resolvedType,
      resolvedType: resolvedType,
    );
  }

  @override
  List<Object?> get props => [
    supportsDeviceInfo,
    supportsBattery,
    supportsActionButton,
    supportsDecodedStream,
  ];
}
