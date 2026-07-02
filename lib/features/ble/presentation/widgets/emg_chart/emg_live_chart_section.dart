import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import '../../../domain/entities/ble_device_stream_snapshot.dart';
import '../../bloc/ble/ble_bloc.dart';
import 'emg_data_buffer.dart';
import 'emg_live_chart_widget.dart';

const emgSignalCeiling = 1000;

class EmgLiveChartSection extends StatefulWidget {
  const EmgLiveChartSection({
    required this.deviceId,
    required this.emgLower,
    required this.emgUpper,
    super.key,
  });

  final String deviceId;
  final int emgLower;
  final int emgUpper;

  @override
  State<EmgLiveChartSection> createState() => _EmgLiveChartSectionState();
}

class _EmgLiveChartSectionState extends State<EmgLiveChartSection> {
  late final EMGDataBuffer _buffer;

  @override
  void initState() {
    super.initState();
    _buffer = EMGDataBuffer();
    _buffer.startUiFlush();
  }

  @override
  void dispose() {
    _buffer.dispose();
    super.dispose();
  }

  void _onSnapshot(EmgStreamSnapshot snapshot) {
    _buffer.push(computeTotalEmg(snapshot));
  }

  double computeTotalEmg(EmgStreamSnapshot snapshot) {
    final voltages = snapshot.voltages;
    final channelSum =
        (voltages.elementAtOrNull(0) ?? 0) +
        (voltages.elementAtOrNull(1) ?? 0) +
        (voltages.elementAtOrNull(2) ?? 0);

    return max(0, min(channelSum, emgSignalCeiling)).toDouble();
  }

  void _resetBuffer() {
    _buffer.stopProcessing();
    _buffer.startUiFlush();
  }

  bool _listenWhen(BleState previous, BleState current) {
    final deviceId = widget.deviceId;
    final snapshotChanged =
        previous.streamSnapshotFor(deviceId) !=
        current.streamSnapshotFor(deviceId);
    final streamingChanged =
        previous.isDeviceStreaming(deviceId) !=
        current.isDeviceStreaming(deviceId);
    return snapshotChanged || streamingChanged;
  }

  void _onListener(BuildContext context, BleState state) {
    if (!state.isDeviceStreaming(widget.deviceId)) {
      _resetBuffer();
      return;
    }

    final snapshot = state.streamSnapshotFor(widget.deviceId);
    if (snapshot is EmgStreamSnapshot) {
      _onSnapshot(snapshot);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BleBloc, BleState>(
      listenWhen: (previous, current) => _listenWhen(previous, current),
      listener: (context, state) => _onListener(context, state),
      child: BlocSelector<BleBloc, BleState, _ChartViewState>(
        selector: (state) => _ChartViewState.from(state, widget.deviceId),
        builder: (context, viewState) => EmgLiveChartWidget(
          buffer: _buffer,
          isStreaming: viewState.isStreaming,
          supportsDataStream: viewState.supportsDataStream,
          emgLower: widget.emgLower,
          emgUpper: widget.emgUpper,
        ),
      ),
    );
  }
}

class _ChartViewState {
  const _ChartViewState({
    required this.isStreaming,
    required this.supportsDataStream,
  });

  final bool isStreaming;
  final bool supportsDataStream;

  factory _ChartViewState.from(BleState state, String deviceId) {
    final scannedType = state.savedDeviceFor(deviceId)?.deviceType;
    final resolvedType = state
        .activeConnectionFor(deviceId)
        ?.deviceInfo
        ?.resolvedType;

    return _ChartViewState(
      isStreaming: state.isDeviceStreaming(deviceId),
      supportsDataStream:
          scannedType?.isMyoBandFamily == true ||
          resolvedType?.isMyoBandFamily == true,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _ChartViewState &&
        isStreaming == other.isStreaming &&
        supportsDataStream == other.supportsDataStream;
  }

  @override
  int get hashCode => Object.hash(isStreaming, supportsDataStream);
}
