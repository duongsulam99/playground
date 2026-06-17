import 'package:vulcan_mobile_playground/features/ble/data/model/ble_discovered_device_model.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_connection_status.dart';

abstract class BleRemoteDataSource {
  Stream<BleAdapterStatus> watchAdapterStatus();

  Stream<List<BleDiscoveredDeviceModel>> watchScanResults();

  Future<void> startScan();

  Future<void> stopScan();

  Future<BleConnectionStatus> connect(String deviceId);

  Future<void> disconnect();
}
