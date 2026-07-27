/// Strategy decode raw BLE notify bytes → domain-specific samples (e.g. EMG mV).
abstract class BleStreamDecoder {
  List<double> decode(List<int> rawBytes);
}
