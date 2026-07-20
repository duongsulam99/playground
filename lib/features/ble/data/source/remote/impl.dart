import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/ble_vulcan_profiles.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';

import '../../model/ble_device_info_model.dart';
import '../../model/ble_device_stream_snapshot_model.dart';
import '../../model/ble_discovered_device_model.dart';
import '../isolate/decode/decode_worker.dart';
import '../isolate/scan/scan_advertisement_mapper.dart';
import '../isolate/scan/scan_parse_worker.dart';
import 'device_factory.dart';
import 'abstract/ble_device_remote_data_source.dart';
import 'abstract/ble_remote_data_source.dart';

/// Orchestrator BLE: scan, connect, và delegate xuống từng [BleDeviceRemoteDataSource].
///
/// Dùng [FlutterBluePlus](https://pub.dev/packages/flutter_blue_plus) làm stack native.
class BleRemoteDataSourceImpl implements BleRemoteDataSource {
  BleRemoteDataSourceImpl({
    required this._deviceFactory,
    required this._decodeIsolate,
    required this._scanParseWorker,
  });

  final BleDeviceDataSourceFactory _deviceFactory;
  final StreamDecodeWorker _decodeIsolate;
  final ScanParseWorker _scanParseWorker;

  /// Instance đã connect — key là `deviceId` (remoteId string).
  final Map<String, BleDeviceRemoteDataSource> _connectedDevices = {};

  /// Snapshot metadata scan mới nhất từ worker — dùng lúc connect.
  Map<String, BleDiscoveredDeviceModel> _latestDiscoveredDevices = {};

  /// Handle native [BluetoothDevice] — cần để gọi `connect()` sau scan.
  final Map<String, BluetoothDevice> _bluetoothDevices = {};

  final _logger = const Logger(className: 'BleRemoteDataSourceImpl');

  @override
  Stream<BleAdapterStatus> watchAdapterStatus() {
    return FlutterBluePlus.adapterState.map(_mapAdapterState);
  }

  @override
  Stream<Map<String, BleDiscoveredDeviceModel>> watchScanResults() {
    return FlutterBluePlus.scanResults.asyncMap(_handleScanResults);
  }

  Future<Map<String, BleDiscoveredDeviceModel>> _handleScanResults(
    List<ScanResult> results,
  ) async {
    if (results.isEmpty) return _latestDiscoveredDevices;

    for (final result in results) {
      final id = result.device.remoteId.str;
      _bluetoothDevices[id] = result.device;
    }

    final dtos = results
        .map(ScanAdvertisementMapper.fromScanResult)
        .toList(growable: false);

    _latestDiscoveredDevices = await _scanParseWorker.processBatch(dtos);
    return _latestDiscoveredDevices;
  }

  @override
  Future<void> startScan({List<VulcanDeviceType>? filterTypes}) async {
    await _checkAdapterState();
    if (FlutterBluePlus.isScanningNow) return;

    _latestDiscoveredDevices = {};
    _bluetoothDevices.clear();
    await _scanParseWorker.clearCache();

    final guids = _getScanGuids(filterTypes);
    await _configScan(guids);
  }

  @override
  Future<void> stopScan() async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
  }

  @override
  Future<BleConnectionStatus> connect(String deviceId) async {
    final existing = _connectedDevices[deviceId];
    if (existing != null) return BleConnectionStatus.connected;

    final discovered = _latestDiscoveredDevices[deviceId];
    final bluetoothDevice = _resolveBluetoothDevice(deviceId);
    final deviceType = discovered?.deviceType ?? VulcanDeviceType.none;

    if (deviceType == VulcanDeviceType.none) {
      throw BleException(
        'Unknown device type for $deviceId',
        deviceId: deviceId,
      );
    }

    // Scan và connect đồng thời dễ fail trên một số platform.
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    final deviceSource = _deviceFactory.create(
      bluetoothDevice,
      deviceType: deviceType,
    );

    try {
      final status = await deviceSource.connect();
      _connectedDevices[deviceId] = deviceSource;
      _logger.debug(
        'connect',
        'Device $deviceId added to connected devices map',
      );
      return status;
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException('Failed to connect: $e', deviceId: deviceId);
    }
  }

  @override
  Stream<BleDeviceStreamSnapshotModel>? watchDeviceData(String deviceId) {
    final deviceSource = findDeviceConnected(deviceId);

    final raw = deviceSource.streaming?.notifyDataStream;
    if (raw == null) return null;

    // Decode EMG chạy trên isolate để không block main thread.
    return _decodeIsolate.decodeStream(source: raw, deviceId: deviceId);
  }

  @override
  Stream<BleConnectionStatus>? watchConnectionStatus(String deviceId) {
    final deviceSource = findDeviceConnected(deviceId);

    return deviceSource.watchConnectionStatus().map((status) {
      // Dọn cache khi mất kết nối (kể cả disconnect ngoài app).
      if (status == BleConnectionStatus.disconnected) {
        _connectedDevices.remove(deviceId);
      }
      return status;
    });
  }

  @override
  Future<BleDeviceInfoModel> readDeviceInfo(String deviceId) async {
    final deviceSource = findDeviceConnected(deviceId);
    final info = deviceSource.info;
    if (info == null) {
      throw BleException(
        'Device info is not supported for ${deviceSource.deviceType.name}',
        deviceId: deviceId,
      );
    }

    try {
      return await info.readDeviceInfo();
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException('Failed to read device info: $e', deviceId: deviceId);
    }
  }

  @override
  Future<void> disconnect(String deviceId) async {
    final deviceSource = findDeviceConnected(deviceId);

    // Xóa trước để các lệnh khác không còn thấy device là connected.
    _connectedDevices.remove(deviceId);

    try {
      await deviceSource.disconnect();
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException('Failed to disconnect: $e', deviceId: deviceId);
    }
  }

  @override
  Future<void> startDeviceStream(String deviceId) async {
    final deviceSource = findDeviceConnected(deviceId);
    final streaming = deviceSource.streaming;
    if (streaming == null) {
      throw BleException(
        'Device stream is not supported for ${deviceSource.deviceType.name}',
        deviceId: deviceId,
      );
    }

    try {
      await streaming.startDeviceStream();
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException(
        'Failed to start device stream: $e',
        deviceId: deviceId,
      );
    }
  }

  @override
  Future<void> stopDeviceStream(String deviceId) async {
    final deviceSource = findDeviceConnected(deviceId);
    final streaming = deviceSource.streaming;
    if (streaming == null) return;

    try {
      await streaming.stopDeviceStream();
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException(
        'Failed to stop device stream: $e',
        deviceId: deviceId,
      );
    }
  }

  /// Public để [BleFirmwareTransportAdapter] truy cập GATT/OTA trực tiếp.
  BleDeviceRemoteDataSource findDeviceConnected(String deviceId) {
    final deviceSource = _connectedDevices[deviceId];

    if (deviceSource == null) {
      throw BleNotConnectedException(
        'Device $deviceId is not connected',
        deviceId: deviceId,
      );
    }

    return deviceSource;
  }

  /// Ưu tiên handle từ scan cache; fallback `fromId` khi device đã từng connect.
  BluetoothDevice _resolveBluetoothDevice(String deviceId) {
    final cached = _bluetoothDevices[deviceId];
    if (cached != null) return cached;

    if (_connectedDevices.containsKey(deviceId)) {
      return BluetoothDevice.fromId(deviceId);
    }

    throw BleDeviceNotFoundException(
      'Device $deviceId not found in scan cache',
      deviceId: deviceId,
    );
  }

  /// Wrapper quanh [FlutterBluePlus.startScan] với default phù hợp Vulcan.
  Future<void> _configScan(
    List<Guid> guids, {
    Duration? timeout,
    Duration removeIfGone = const Duration(seconds: 10),
    bool continuousUpdates = true,
    int continuousDivisor = 10,
  }) {
    return FlutterBluePlus.startScan(
      timeout: timeout,
      removeIfGone: removeIfGone,
      continuousUpdates: continuousUpdates,
      continuousDivisor: continuousDivisor,
      withServices: guids,
    );
  }

  Future<void> _checkAdapterState() async {
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (_mapAdapterState(adapterState) != BleAdapterStatus.on) {
      throw const BleAdapterException('Bluetooth adapter is not ready');
    }
  }

  List<Guid> _getScanGuids(List<VulcanDeviceType>? filterTypes) {
    if (filterTypes == null) return BleVulcanProfiles.allVulcanScanGuids();
    return BleVulcanProfiles.scanGuidsForDeviceTypes(filterTypes);
  }

  BleAdapterStatus _mapAdapterState(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.unavailable:
        return BleAdapterStatus.unavailable;
      case BluetoothAdapterState.unauthorized:
        return BleAdapterStatus.unauthorized;
      case BluetoothAdapterState.turningOn:
        return BleAdapterStatus.turningOn;
      case BluetoothAdapterState.on:
        return BleAdapterStatus.on;
      case BluetoothAdapterState.turningOff:
        return BleAdapterStatus.turningOff;
      case BluetoothAdapterState.off:
        return BleAdapterStatus.off;
      default:
        return BleAdapterStatus.unknown;
    }
  }
}
