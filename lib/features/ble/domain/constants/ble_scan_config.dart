import 'package:vulcan_mobile_playground/core/ble/ble_adv_uuids.dart';

class BleScanConfig {
  const BleScanConfig._();

  /// Only keep devices that advertise as connectable.
  /// Note: flutter_blue_plus has no native connectable scan filter;
  /// this is applied when processing scan results.
  static const bool connectableOnly = true;

  /// All Vulcan advertisement UUIDs (delegates to [BleAdvUuids]).
  static List<String> get advUUIDs => BleAdvUuids.allAdvUuids;
}
