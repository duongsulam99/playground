abstract final class BleStreamFrameConfig {
  /// Size of a single EMG frame in bytes
  static const int emgFrameSizeBytes = 32;

  /// Number of floats in a single EMG frame
  static const int floatsPerFrame = 8;

  /// Capacity of the temporal buffer in bytes; used to determine when to flush.
  /// Holds frames for [defaultBatchInterval] before flushing.
  ///
  /// Ở duration <30 milliseconds, 1 frame = 32 bytes thì tỷ lệ drop frame là 0 ~ 1
  ///
  /// Ở duration >20 milliseconds thì tỷ lệ drop frame là 1 ~ 10 ( khi start )
  static const defaultBatchInterval = Duration(milliseconds: 30);
}
