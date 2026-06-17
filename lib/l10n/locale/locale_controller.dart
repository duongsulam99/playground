import 'package:flutter_supper_app_core/core.dart';

class LocaleController extends AbstractLocaleController {
  LocaleController({required AbstractLocaleRepository repository})
      : _repository = repository,
        super(_resolveInitial(repository));

  final AbstractLocaleRepository _repository;

  static Locale _resolveInitial(AbstractLocaleRepository repository) {
    final stored = repository.load();
    if (stored == null) return AbstractLocaleController.fallback;
    return AbstractLocaleController.supportedLocales.firstWhere(
      (locale) => locale.languageCode == stored,
      orElse: () => AbstractLocaleController.fallback,
    );
  }

  @override
  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == value.languageCode) return;
    final isSupported = AbstractLocaleController.supportedLocales.any(
      (item) => item.languageCode == locale.languageCode,
    );
    if (!isSupported) return;
    await _repository.save(locale.languageCode);
    value = locale;
  }
}
