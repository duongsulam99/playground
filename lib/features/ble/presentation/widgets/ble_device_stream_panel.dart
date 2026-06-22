import 'package:flutter/material.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_active_connection.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_device_stream_snapshot.dart';

class BleDeviceStreamPanel extends StatelessWidget {
  const BleDeviceStreamPanel({
    required this.connection,
    required this.snapshot,
    required this.displayName,
    required this.supportsDataStream,
    super.key,
  });

  final BleActiveConnection? connection;
  final BleDeviceStreamSnapshot? snapshot;
  final String displayName;
  final bool supportsDataStream;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device data stream',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildBody(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (snapshot != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Frames: ${snapshot!.frameCount}'),
          Text('Total bytes: ${snapshot!.totalBytes}'),
          Text('FPS: ${snapshot!.framesPerSecond}'),
          Text('Last frame: ${snapshot!.lastFrameLength} bytes'),
          const SizedBox(height: 4),
          Text(
            snapshot!.hexPreview,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ],
      );
    }

    if (connection?.status.isConnected != true) {
      return Text(
        'Device disconnected',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey,
        ),
      );
    }

    if (supportsDataStream) {
      return const Text('Waiting for data…');
    }

    return Text(
      'No data stream',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey,
      ),
    );
  }
}
