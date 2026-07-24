import '../device/ring/index.dart';
import 'capabilities/connection.dart';
import 'capabilities/firmware_transport.dart';
import 'capabilities/gatt_access.dart';
import 'capabilities/info_source.dart';
import 'capabilities/data_streaming.dart';

/// Contract for a single BLE device instance (typically after connect).
///
/// Mandatory capabilities: connection, GATT, firmware OTA.
/// Optional capabilities ([streaming], [info], [ringSession]) are exposed as
/// nullable getters — `null` means the device type does not support that feature.
abstract interface class BleDeviceRemoteDataSource
    implements Connection, GattAccess, FirmwareTransport {
  /// `null` when the device does not support notify stream.
  DataStreaming? get streaming;

  /// `null` when the device does not support structured device info.
  InfoSource? get info;

  /// `null` when the device is not a MyoBand/Ring session device.
  BleRingDeviceSession? get ringSession;
}
