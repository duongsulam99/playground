import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import 'ble_device_bloc.dart';

typedef BleDeviceBlocFactory =
    BleDeviceBloc Function({
      required String deviceId,
      required VulcanDeviceType scannedType,
    });

/// Owns per-[deviceId] [BleDeviceBloc] instances for the app lifetime of a
/// connection. [BleManagerBloc] creates on connect and disposes on disconnect.
class BleDeviceBlocRegistry {
  BleDeviceBlocRegistry({required this._createBloc});

  final BleDeviceBlocFactory _createBloc;
  final Map<String, BleDeviceBloc> _blocs = {};

  BleDeviceBloc getOrCreate(
    String deviceId,
    VulcanDeviceType scannedType,
  ) {
    final existing = _blocs[deviceId];
    if (existing != null) return existing;

    final bloc = _createBloc(deviceId: deviceId, scannedType: scannedType);
    _blocs[deviceId] = bloc;
    return bloc;
  }

  BleDeviceBloc? get(String deviceId) => _blocs[deviceId];

  Iterable<BleDeviceBloc> get active => _blocs.values;

  Iterable<String> get deviceIds => _blocs.keys;

  bool contains(String deviceId) => _blocs.containsKey(deviceId);

  Future<void> dispose(String deviceId) async {
    final bloc = _blocs.remove(deviceId);
    if (bloc == null) return;
    await bloc.close();
  }

  Future<void> disposeAll() async {
    final blocs = _blocs.values.toList();
    _blocs.clear();
    for (final bloc in blocs) {
      await bloc.close();
    }
  }
}
