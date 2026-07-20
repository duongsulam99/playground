/// Notify stream capability (EMG / signal). Optional per device type.
abstract interface class BleDeviceStreaming {
  /// Raw byte stream after notify is enabled.
  Stream<List<int>> get notifyDataStream;

  Future<void> startDeviceStream();

  Future<void> stopDeviceStream();
}
