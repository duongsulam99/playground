/// Notify stream capability (EMG / signal). Optional per device type.
abstract interface class BleDeviceStreaming {
  /// Raw byte stream after notify is enabled.
  Stream<List<int>> get notifyDataStream;

  /// Called before disconnect to stop streaming on the device.
  Future<void> Function()? get onNotifyStopListening;

  Future<void> startDeviceStream();

  Future<void> stopDeviceStream();
}
