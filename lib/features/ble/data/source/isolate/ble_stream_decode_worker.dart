import 'dart:isolate';

import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../stream/emg_stream_decoder.dart';
import 'ble_stream_decode_messages.dart';

@pragma('vm:entry-point')
void bleStreamDecodeWorkerMain(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(BleStreamDecodeWorkerReady(receivePort.sendPort));

  const decoder = EmgStreamDecoder();

  receivePort.listen((message) {
    if (message is! BleStreamDecodeRequest) return;

    try {
      final snapshot = decoder.decode(
        deviceId: '',
        rawBytes: message.rawBytes,
      );

      mainSendPort.send(
        BleStreamDecodeSuccess(
          requestId: message.requestId,
          voltages: snapshot.voltages,
        ),
      );
    } on BleException catch (error) {
      mainSendPort.send(
        BleStreamDecodeFailure(
          requestId: message.requestId,
          errorMessage: error.message,
        ),
      );
    } catch (error) {
      mainSendPort.send(
        BleStreamDecodeFailure(
          requestId: message.requestId,
          errorMessage: error.toString(),
        ),
      );
    }
  });
}
