import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleScanConfig {
  const BleScanConfig._();

  /// List of advertised service UUIDs to filter on.
  static const String advUUIDHand =       "390950ed-51ff-445f-a6c6-f6a95a6a465f";
  static const String advUUIDElbow =      "546afe6a-6299-11ee-8c99-0242ac120002";
  static const String advUUIDCoaxial =    "d0232816-a375-46fa-a4a6-f062bdc1de2a";
  static const String advUUIDRing =       "db1df223-4020-4c5a-930c-1989ea04991f";
  static const String advUUIDSensorbox =  "ffee1404-bbaa-9988-7766-554433221100";
  static const String advUUIDBleadapter = "546afe6a-6299-11ee-8c99-0242ac120002";


  /// List of advertised service UUIDs to filter on. ( Vulcan device advertisement UUIDs )
  static const List<String> advUUIDs = <String>[
    advUUIDHand,
    advUUIDElbow,
    advUUIDCoaxial,
    advUUIDRing,
    advUUIDSensorbox,
    advUUIDBleadapter
  ];

  static List<Guid> advUUIDsGuid = List.generate(advUUIDs.length, (i) => Guid(advUUIDs[i]));


  /// Only keep devices that advertise as connectable.
  /// Note: flutter_blue_plus has no native connectable scan filter;
  /// this is applied when processing scan results.
  static const bool connectableOnly = true;
}
