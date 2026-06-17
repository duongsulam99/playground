import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';

class HiveManager {
  const HiveManager._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(HiveBoxes.settings);
  }

  static Box<dynamic> get settingsBox => Hive.box<dynamic>(HiveBoxes.settings);

  static Future<void> dispose() async {
    await Hive.close();
  }
}
