import 'capabilities/ble_device_connection.dart';
import 'capabilities/ble_device_firmware_transport.dart';
import 'capabilities/ble_device_gatt_access.dart';
import 'capabilities/ble_device_info_source.dart';
import 'capabilities/ble_device_streaming.dart';

/// Contract for a single BLE device instance (typically after connect).
///
/// Mandatory capabilities: connection, GATT, firmware OTA.
/// Optional capabilities ([streaming], [info]) are exposed as nullable getters
/// — `null` means the device type does not support that feature.
abstract interface class BleDeviceRemoteDataSource
    implements
        BleDeviceConnection,
        BleDeviceGattAccess,
        BleDeviceFirmwareTransport {
  /// `null` when the device does not support notify stream.
  BleDeviceStreaming? get streaming;

  /// `null` when the device does not support structured device info.
  BleDeviceInfoSource? get info;
}
