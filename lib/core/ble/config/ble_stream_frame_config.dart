abstract final class BleStreamFrameConfig {
  /// Size of a single EMG frame in bytes
  static const int emgFrameSizeBytes = 32;

  /// Number of floats in a single EMG frame
  static const int floatsPerFrame = 8;

  /// Capacity of the temporal buffer in bytes; used to determine when to flush.
  /// Holds frames for [defaultBatchInterval] before flushing.
  static const defaultBatchInterval = Duration(milliseconds: 50);
}
