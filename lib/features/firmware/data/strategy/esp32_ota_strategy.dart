import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/DFU/dfu_type.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_encoders.dart';

import '../../domain/entity/dfu_progress.dart';
import '../firmware_ble_transport.dart';
import 'dfu_strategy.dart';

class Esp32OtaStrategy implements DfuStrategy {
  const Esp32OtaStrategy();

  static const int _maxPacketPayload = 512;
  static const int _ackTimeoutSeconds = 2;
  static const String _startOtaCommand = 'START_OTA';
  static const String _endOtaCommand = 'END_OTA';

  @override
  DfuType get type => DfuType.esp32Custom;

  @override
  Stream<DfuProgress> execute({
    required FirmwareBleTransport transport,
    required Uint8List firmwareBytes,
    required String deviceId,
  }) async* {
    final context = _Esp32OtaContext(
      transport: transport,
      firmwareBytes: firmwareBytes,
      deviceId: deviceId,
    );

    try {
      yield const DfuProgress(
        status: DfuStatus.uploading,
        percent: 0,
        message: 'Preparing OTA',
      );

      await _prepareSession(context);
      final bytePacket = _computePacketSize(transport, deviceId);
      await _sendStartCommand(context);
      yield* _uploadFirmwareChunks(context, bytePacket);
      await _finalizeSession(context);

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
      await _cleanup(context);
    }
  }

  void _handleNotifyAck(_Esp32OtaContext context, List<int> value) {
    context.packetCounterReceived = _fromBytesToInt(value);
    if (context.packetCounter == context.packetCounterReceived) {
      context.waitTransmissionCompleted = false;
    }
    context.retryTimer?.cancel();
  }

  int _computePacketSize(FirmwareBleTransport transport, String deviceId) {
    final mtu = transport.getCurrentMtu(deviceId);
    return min(_maxPacketPayload, max(mtu - 3, 1));
  }

  Future<void> _prepareSession(_Esp32OtaContext context) async {
    await context.transport.startFirmwareUpdate(context.deviceId, true);
    context.notifySubscription = context.transport
        .watchFirmwareUpdate(context.deviceId)
        .listen((value) => _handleNotifyAck(context, value));
  }

  Future<void> _sendStartCommand(_Esp32OtaContext context) async {
    await context.transport.writeOta(
      context.deviceId,
      BleValueEncoders.encodeUtf8(_startOtaCommand),
    );
    await Future<void>.delayed(const Duration(seconds: 2));
  }

  Future<void> _transmitChunk(
    _Esp32OtaContext context,
    Uint8List chunk,
  ) async {
    context.waitTransmissionCompleted = true;
    await context.transport.writeOta(context.deviceId, chunk);

    if (context.waitTransmissionCompleted) {
      context.retryTimer = Timer(
        const Duration(seconds: _ackTimeoutSeconds),
        () => context.transport.writeOta(context.deviceId, chunk),
      );
    }

    while (context.waitTransmissionCompleted) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  Stream<DfuProgress> _uploadFirmwareChunks(
    _Esp32OtaContext context,
    int bytePacket,
  ) async* {
    final firmwareBytes = context.firmwareBytes;

    for (var index = 0; index < firmwareBytes.length; index += bytePacket) {
      context.packetCounter++;
      final end = min(index + bytePacket, firmwareBytes.length);
      final chunk = firmwareBytes.sublist(index, end);

      await _transmitChunk(context, chunk);

      yield DfuProgress(
        status: DfuStatus.uploading,
        percent: index * 100 / firmwareBytes.length,
        message: 'Uploading firmware',
      );
    }
  }

  Future<void> _sendEndCommand(_Esp32OtaContext context) async {
    await context.transport.writeOta(
      context.deviceId,
      BleValueEncoders.encodeUtf8(_endOtaCommand),
    );
  }

  Future<void> _finalizeSession(_Esp32OtaContext context) async {
    await _sendEndCommand(context);
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  Future<void> _cleanup(_Esp32OtaContext context) async {
    context.retryTimer?.cancel();
    await context.notifySubscription?.cancel();
    try {
      await _sendEndCommand(context);
    } catch (_) {}
    await context.transport.startFirmwareUpdate(context.deviceId, false);
  }

  int _fromBytesToInt(List<int> data) {
    if (data.length == 1) return data[0];
    final buffer = Int8List(2)
      ..[1] = data[1]
      ..[0] = data[0];
    return buffer.buffer.asInt16List()[0];
  }
}

class _Esp32OtaContext {
  _Esp32OtaContext({
    required this.transport,
    required this.firmwareBytes,
    required this.deviceId,
  });

  final FirmwareBleTransport transport;
  final Uint8List firmwareBytes;
  final String deviceId;

  var packetCounter = 0;
  var packetCounterReceived = 0;
  var waitTransmissionCompleted = false;
  StreamSubscription<List<int>>? notifySubscription;
  Timer? retryTimer;
}
