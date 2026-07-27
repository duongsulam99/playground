import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/ble_device_stream_snapshot.dart';
import '../../bloc/device/ble_device_bloc.dart';
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

  bool _listenWhen(BleDeviceState previous, BleDeviceState current) {
    final snapshotChanged = previous.streamSnapshot != current.streamSnapshot;
    final streamingChanged = previous.isStreaming != current.isStreaming;
    return snapshotChanged || streamingChanged;
  }

  void _onListener(BuildContext context, BleDeviceState state) {
    if (!state.isStreaming) {
      _resetBuffer();
      return;
    }

    final snapshot = state.streamSnapshot;
    if (snapshot is EmgStreamSnapshot) {
      _onSnapshot(snapshot);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BleDeviceBloc, BleDeviceState>(
      listenWhen: (previous, current) => _listenWhen(previous, current),
      listener: (context, state) => _onListener(context, state),
      child: BlocSelector<BleDeviceBloc, BleDeviceState, _ChartViewState>(
        selector: (state) => _ChartViewState.from(state),
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

  factory _ChartViewState.from(BleDeviceState state) {
    return _ChartViewState(
      isStreaming: state.isStreaming,
      supportsDataStream: state.supportsDataStream,
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
