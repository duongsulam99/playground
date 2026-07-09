import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_mobile_playground/core/ble/config/ble_stream_frame_config.dart';
import 'package:vulcan_mobile_playground/features/ble/data/source/helper/stream_temporal_buffer.dart';

void main() {
  const frameSize = BleStreamFrameConfig.emgFrameSizeBytes;
  const flushInterval = Duration(milliseconds: 50);

  Uint8List frame(int seed) => Uint8List.fromList(List.filled(frameSize, seed));

  test('flushes accumulated frames after flush interval', () async {
    final batches = <Uint8List>[];

    final buffer = StreamTemporalBuffer(onFlush: batches.add);

    buffer
      ..add(frame(1))
      ..add(frame(2));

    await Future<void>.delayed(
      flushInterval + const Duration(milliseconds: 10),
    );

    expect(batches, hasLength(1));
    expect(batches.first, hasLength(frameSize * 2));
    expect(batches.first[0], 1);
    expect(batches.first[frameSize], 2);

    buffer.dispose();
  });

  test('skips frames with invalid size', () async {
    final batches = <Uint8List>[];

    final buffer = StreamTemporalBuffer(onFlush: batches.add);

    buffer
      ..add(Uint8List(16))
      ..add(frame(7));

    await Future<void>.delayed(
      flushInterval + const Duration(milliseconds: 10),
    );

    expect(batches, hasLength(1));
    expect(batches.first, frame(7));

    buffer.dispose();
  });

  test('dispose does not flush pending frames', () async {
    final batches = <Uint8List>[];

    final buffer = StreamTemporalBuffer(onFlush: batches.add)..add(frame(9));

    buffer.dispose();

    await Future<void>.delayed(
      flushInterval + const Duration(milliseconds: 10),
    );

    expect(batches, isEmpty);
  });

  test('flushNow emits pending frames immediately', () {
    final batches = <Uint8List>[];

    final buffer = StreamTemporalBuffer(
      flushInterval: const Duration(seconds: 10),
      onFlush: batches.add,
    )..add(frame(4));

    buffer.flushNow();

    expect(batches, hasLength(1));
    expect(batches.first, frame(4));

    buffer.dispose();
  });
}
