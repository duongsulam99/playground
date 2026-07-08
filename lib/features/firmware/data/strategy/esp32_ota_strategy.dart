import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:vulcan_mobile_playground/core/ble/enums/DFU/dfu_type.dart';

import '../../domain/entity/dfu_progress.dart';
import '../firmware_ble_transport.dart';
import 'dfu_strategy.dart';

class Esp32OtaStrategy implements DfuStrategy {
  const Esp32OtaStrategy();

  static const int _defaultPacketSize = 515;
  static const int _maxPacketPayload = 512;
  static const int _ackTimeoutSeconds = 2;

  @override
  DfuType get type => DfuType.esp32Custom;

  @override
  Stream<DfuProgress> execute({
    required FirmwareBleTransport transport,
    required Uint8List firmwareBytes,
    required String deviceId,
  }) async* {
    var packetCounter = 0;
    var packetCounterReceived = 0;
    var waitTransmissionCompleted = false;
    StreamSubscription<List<int>>? notifySubscription;
    Timer? retryTimer;

    try {
      yield const DfuProgress(
        status: DfuStatus.uploading,
        percent: 0,
        message: 'Preparing OTA',
      );

      await transport.setOtaNotifyEnabled(deviceId, true);
      notifySubscription = transport.watchOtaNotifications(deviceId).listen(
        (value) {
          packetCounterReceived = _fromBytesToInt(value);
          if (packetCounter == packetCounterReceived) {
            waitTransmissionCompleted = false;
          }
          retryTimer?.cancel();
        },
      );

      final mtu = await transport.requestMtu(deviceId, _defaultPacketSize);
      final bytePacket = min(_maxPacketPayload, mtu - 3);

      await transport.writeOta(deviceId, utf8.encode('START_OTA'));
      await Future<void>.delayed(const Duration(seconds: 2));

      for (var index = 0; index < firmwareBytes.length; index += bytePacket) {
        packetCounter++;
        final end = min(index + bytePacket, firmwareBytes.length);
        final chunk = firmwareBytes.sublist(index, end);
        waitTransmissionCompleted = true;

        await transport.writeOta(deviceId, chunk);

        if (waitTransmissionCompleted) {
          retryTimer = Timer(const Duration(seconds: _ackTimeoutSeconds), () {
            transport.writeOta(deviceId, chunk);
          });
        }

        while (waitTransmissionCompleted) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }

        yield DfuProgress(
          status: DfuStatus.uploading,
          percent: index * 100 / firmwareBytes.length,
          message: 'Uploading firmware',
        );
      }

      await transport.writeOta(deviceId, utf8.encode('END_OTA'));
      await Future<void>.delayed(const Duration(seconds: 1));

      yield const DfuProgress(
        status: DfuStatus.completed,
        percent: 100,
        message: 'Firmware update completed',
      );
    } catch (error) {
      yield DfuProgress(
        status: DfuStatus.failed,
        percent: 0,
        message: error.toString(),
      );
    } finally {
      retryTimer?.cancel();
      await notifySubscription?.cancel();
      try {
        await transport.writeOta(deviceId, utf8.encode('END_OTA'));
      } catch (_) {}
      await transport.setOtaNotifyEnabled(deviceId, false);
    }
  }

  int _fromBytesToInt(List<int> data) {
    if (data.length == 1) return data[0];
    final buffer = Int8List(2)
      ..[1] = data[1]
      ..[0] = data[0];
    return buffer.buffer.asInt16List()[0];
  }
}
