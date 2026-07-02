import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_mobile_playground/features/ble/data/model/ble_device_stream_snapshot_model.dart';
import 'package:vulcan_mobile_playground/features/ble/data/source/isolate/ble_stream_decode_isolate.dart';

void main() {
  test('BleStreamDecodeIsolate decodes EMG bytes and assembles snapshot', () async {
    final isolate = await BleStreamDecodeIsolate.create();
    addTearDown(isolate.dispose);

    final rawBytes = Uint8List(32);
    final floats = Float32List.view(rawBytes.buffer);
    floats[0] = 1.5;
    floats[1] = 2.5;
    floats[2] = 3.5;

    final snapshots = await isolate
        .decodeStream(
          source: Stream<List<int>>.value(rawBytes),
          deviceId: 'device-1',
        )
        .map((snapshot) => snapshot as EmgStreamSnapshotModel)
        .toList();

    expect(snapshots, hasLength(1));
    expect(snapshots.first.deviceId, 'device-1');
    expect(snapshots.first.voltages.take(3), [1.5, 2.5, 3.5]);
    expect(snapshots.first.rawBytes, rawBytes);
  });

  test('BleStreamDecodeIsolate drops oldest frame while decode is in flight', () async {
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

    Uint8List frame(double value) {
      final bytes = Uint8List(32);
      Float32List.view(bytes.buffer)[0] = value;
      return bytes;
    }

    controller
      ..add(frame(1))
      ..add(frame(2))
      ..add(frame(3));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await controller.close();
    await subscription.cancel();

    expect(snapshots, isNotEmpty);
    expect(snapshots.last.voltages.first, 3);
  });
}
