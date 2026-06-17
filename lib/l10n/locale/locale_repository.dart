import 'package:flutter_supper_app_core/core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vulcan_mobile_playground/common/local/hive_boxes.dart';

class LocaleRepository implements AbstractLocaleRepository {
  LocaleRepository({Box<dynamic>? settingsBox})
      : _settingsBox = settingsBox ?? Hive.box<dynamic>(HiveBoxes.settings);

  final Box<dynamic> _settingsBox;

  @override
  String? load() {
    final stored = _settingsBox.get(HiveKeys.locale);
    if (stored is! String || stored.isEmpty) return null;
    return stored;
  }

  @override
  Future<void> save(String languageCode) async {
    await _settingsBox.put(HiveKeys.locale, languageCode);
  }
}
