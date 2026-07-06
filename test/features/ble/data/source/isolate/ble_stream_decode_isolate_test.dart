import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_mobile_playground/core/ble/config/ble_stream_frame_config.dart';
import 'package:vulcan_mobile_playground/features/ble/data/model/ble_device_stream_snapshot_model.dart';
import 'package:vulcan_mobile_playground/features/ble/data/source/isolate/stream_decode/ble_stream_decode_isolate.dart';

void main() {
  final batchWait = BleStreamFrameConfig.defaultBatchInterval +
      const Duration(milliseconds: 20);

  Uint8List frame(double value) {
    final bytes = Uint8List(BleStreamFrameConfig.emgFrameSizeBytes);
    Float32List.view(bytes.buffer)[0] = value;
    return bytes;
  }

  test('BleStreamDecodeIsolate decodes batched EMG bytes into one snapshot', () async {
    final isolate = await BleStreamDecodeIsolate.create();
    addTearDown(isolate.dispose);

    final controller = StreamController<List<int>>();
    final snapshots = <EmgStreamSnapshotModel>[];

    final subscription = isolate
        .decodeStream(
          source: controller.stream,
          deviceId: 'device-1',
        )
        .listen((snapshot) {
          snapshots.add(snapshot as EmgStreamSnapshotModel);
        });

    controller.add(frame(1.5));
    await Future<void>.delayed(batchWait);

    await controller.close();
    await subscription.cancel();

    expect(snapshots, hasLength(1));
    expect(snapshots.first.deviceId, 'device-1');
    expect(snapshots.first.voltages.take(3), [1.5, 0.0, 0.0]);
  });

  test('BleStreamDecodeIsolate batches multiple frames into one snapshot', () async {
    final isolate = await BleStreamDecodeIsolate.create();
    addTearDown(isolate.dispose);

    final controller = StreamController<List<int>>();
    final snapshots = <EmgStreamSnapshotModel>[];

    final subscription = isolate
        .decodeStream(
          source: controller.stream,
          deviceId: 'device-1',
        )
        .listen((snapshot) {
          snapshots.add(snapshot as EmgStreamSnapshotModel);
        });

    controller
      ..add(frame(1.0))
      ..add(frame(2.0))
      ..add(frame(3.0));

    await Future<void>.delayed(batchWait);

    await controller.close();
    await subscription.cancel();

    expect(snapshots, hasLength(1));
    expect(snapshots.first.voltages.first, 1.0);
    expect(snapshots.first.rawBytes, hasLength(BleStreamFrameConfig.emgFrameSizeBytes * 3));
  });

  test('BleStreamDecodeIsolate drops oldest pending batch while decode is in flight', () async {
    final isolate = await BleStreamDecodeIsolate.create();
    addTearDown(isolate.dispose);

    final controller = StreamController<List<int>>();
    final snapshots = <EmgStreamSnapshotModel>[];

    final subscription = isolate
        .decodeStream(
          source: controller.stream,
          deviceId: 'device-1',
        )
        .listen((snapshot) {
          snapshots.add(snapshot as EmgStreamSnapshotModel);
        });

    controller.add(frame(1.0));
    await Future<void>.delayed(batchWait);

    controller
      ..add(frame(2.0))
      ..add(frame(3.0));
    await Future<void>.delayed(batchWait);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    await controller.close();
    await subscription.cancel();

    expect(snapshots, hasLength(2));
    expect(snapshots[0].voltages.first, 1.0);
    expect(snapshots[1].voltages.first, 2.0);
  });
}
