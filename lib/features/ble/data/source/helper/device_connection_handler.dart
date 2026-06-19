import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_package_accumulator.dart';

class DeviceConnectionHandler {
  final String deviceId;
  final BluetoothDevice _bleDevice;

  // Các thành phần quản lý độc lập cho từng thiết bị
  final BlePacketAccumulator _accumulator = BlePacketAccumulator();
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription? _notificationSubscription;

  // StreamController để bắn dữ liệu SẠCH (đã gộp gói) lên Repository -> Domain
  final StreamController<List<int>> _cleanDataStreamController =
      StreamController<List<int>>.broadcast();
  Stream<List<int>> get cleanDataStream => _cleanDataStreamController.stream;

  // Command Queue xử lý tuần tự chống lỗi GATT BUSY
  Future<void> _queueLock = Future.value();
  int _currentMtu = 23; // Mặc định của chuẩn BLE Core Spec

  DeviceConnectionHandler({
    required this.deviceId,
    required BluetoothDevice device,
  }) : _bleDevice = device;

  /// HÀM KẾT NỐI (Vòng đời CONNECT)
  Future<void> connect() async {
    try {
      // 1. Thực hiện lệnh kết nối phần cứng với Timeout bảo vệ
      await _bleDevice
          .connect(license: License.nonprofit)
          .timeout(const Duration(seconds: 10));

      // 2. Thiết lập MTU Động ngay sau khi kết nối thành công
      await _setupMtuDiscovery();

      // 3. Lắng nghe trạng thái mất kết nối bất ngờ (Auto-cleanup)
      _monitorConnectionState();
    } catch (e) {
      debugPrint("Connect failed for device $deviceId: $e");
      rethrow;
    }
  }

  /// HÀM THIẾT LẬP LẮNG NGHE DỮ LIỆU (Vòng đời READ INFO / NOTIFY)
  Future<void> startListeningData(
    String serviceId,
    String characteristicId,
  ) async {
    await _enqueueOperation(() async {
      // 1. Kích hoạt tính năng Notify trên phần cứng (Gửi lệnh 0x2902 descriptor)
      // await _bleDevice.setNotifyValue(true);

      // 2. Đăng ký lắng nghe luồng byte thô bắn về
      // _notificationSubscription = _bleDevice.onValueReceived.listen((
      //   List<int> rawChunk,
      // ) {
      //   // 3. ĐƯA VÀO BỘ ĐỆM ĐỂ XỬ LÝ GỘP GÓI
      //   _accumulator.appendChunk(rawChunk, (completeFrame) {
      //     // Khi gộp đủ gói tin, bắn dữ liệu sạch ra Stream bên ngoài
      //     _cleanDataStreamController.add(completeFrame);
      //   });
      // });
    });
  }

  /// HÀM GHI DỮ LIỆU ĐỘNG (Xử lý Chunking dữ liệu gửi đi)
  Future<void> writeData(List<int> fullData) async {
    final int maxPayloadSize = _currentMtu - 3;

    // Chia nhỏ gói dữ liệu dựa trên MTU thực tế của thiết bị này
    for (int i = 0; i < fullData.length; i += maxPayloadSize) {
      // final chunk = fullData.sublist(
      //   i,
      //   i + maxPayloadSize > fullData.length
      //       ? fullData.length
      //       : i + maxPayloadSize,
      // );

      // Đẩy từng gói nhỏ vào hàng đợi tuần tự
      // await _enqueueOperation(() async {
      // await _bleDevice.writeCharacteristic(chunk);
      // });
    }
  }

  /// Cơ chế Cấu hình MTU Động cho từng thiết bị
  Future<void> _setupMtuDiscovery() async {
    if (Platform.isAndroid) {
      // Android bắt buộc phải request thủ công
      await _bleDevice.requestMtu(247).catchError((_) => 23);
    }

    // Đọc hoặc lắng nghe MTU thực tế sau thương lượng từ OS
    _currentMtu = await _bleDevice.mtu.first;
    debugPrint("Device $deviceId negotiated MTU: $_currentMtu");
  }

  /// Cơ chế đồng bộ hóa Command Queue tuần tự
  Future<T> _enqueueOperation<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _queueLock = _queueLock.then((_) async {
      try {
        final result = await operation().timeout(const Duration(seconds: 3));
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });
    return completer.future;
  }

  void _monitorConnectionState() {
    _connectionSubscription = _bleDevice.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        dispose(); // Giải phóng tài nguyên ngay lập tức khi mất kết nối
      }
    });
  }

  /// Giải phóng tài nguyên chống Memory Leak
  void dispose() {
    _connectionSubscription?.cancel();
    _notificationSubscription?.cancel();
    _accumulator.clear();
    _cleanDataStreamController.close();
    debugPrint("Resources cleaned up for device $deviceId");
  }
}
