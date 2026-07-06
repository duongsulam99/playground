import 'dart:isolate';

import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../stream/emg_stream_decoder.dart';
import '../ble_action_messages.dart';
import 'ble_stream_decode_messages.dart';

@pragma('vm:entry-point')
void bleStreamDecodeWorkerMain(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(BleWorkerReady(receivePort.sendPort));

  const decoder = EmgStreamDecoder();

  receivePort.listen((message) {
    if (message is! BleStreamDecodeRequest) return;

    try {
      final result = decoder.decode(deviceId: '', rawBytes: message.rawBytes);

      mainSendPort.send(
        BleActionSuccess(
          requestId: message.requestId,
          result: result.voltages,
        ),
      );
    } on BleException catch (error) {
      mainSendPort.send(
        BleActionFailure(
          requestId: message.requestId,
          errorMessage: error.message,
        ),
      );
    } catch (error) {
      mainSendPort.send(
        BleActionFailure(
          requestId: message.requestId,
          errorMessage: error.toString(),
        ),
      );
    }
  });
}
