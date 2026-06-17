/// Contract for persisting the user's locale preference.
abstract class AbstractLocaleRepository {
  /// Returns the stored language code (e.g. `vi`, `en`), or `null` if unset.
  String? load();

  /// Persists [languageCode] for the next app launch.
  Future<void> save(String languageCode);
}
