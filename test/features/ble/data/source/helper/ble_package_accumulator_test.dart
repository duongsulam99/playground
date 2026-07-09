import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_mobile_playground/features/ble/data/source/helper/package_accumulator.dart';

void main() {
  group('BlePacketAccumulator', () {
    test('reassembles a single framed packet from one chunk', () {
      final accumulator = BlePacketAccumulator();
      final frames = <List<int>>[];

      accumulator.appendChunk([0, 3, 1, 2, 3], frames.add);

      expect(frames, [
        [1, 2, 3],
      ]);
    });

    test('reassembles a packet split across multiple chunks', () {
      final accumulator = BlePacketAccumulator();
      final frames = <List<int>>[];

      accumulator.appendChunk([0, 2], frames.add);
      accumulator.appendChunk([9, 8], frames.add);

      expect(frames, [
        [9, 8],
      ]);
    });

    test('reassembles multiple back-to-back frames in one buffer', () {
      final accumulator = BlePacketAccumulator();
      final frames = <List<int>>[];

      accumulator.appendChunk([
        0, 1, 0xAA,
        0, 2, 0xBB, 0xCC,
      ], frames.add);

      expect(frames, [
        [0xAA],
        [0xBB, 0xCC],
      ]);
    });

    test('clear resets partial state', () {
      final accumulator = BlePacketAccumulator();
      final frames = <List<int>>[];

      accumulator.appendChunk([0, 5], frames.add);
      accumulator.clear();
      accumulator.appendChunk([0, 1, 0xFF], frames.add);

      expect(frames, [
        [0xFF],
      ]);
    });
  });
}
