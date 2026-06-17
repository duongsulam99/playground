import 'package:flutter_supper_app_core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_mobile_playground/common/di/init_dependencies.dart';
import 'package:vulcan_mobile_playground/common/screens/home_page.dart';
import 'package:vulcan_mobile_playground/l10n/locale/locale_controller.dart';
import 'package:vulcan_mobile_playground/l10n/localization/app_localizations.dart';

class _InMemoryLocaleRepository implements AbstractLocaleRepository {
  String? _languageCode;

  @override
  String? load() => _languageCode;

  @override
  Future<void> save(String languageCode) async {
    _languageCode = languageCode;
  }
}

void main() {
  setUp(() async {
    await serviceLocator.reset();
    final repository = _InMemoryLocaleRepository();
    serviceLocator.registerLazySingleton<AbstractLocaleRepository>(() => repository);
    serviceLocator.registerLazySingleton<AbstractLocaleController>(
      () => LocaleController(repository: repository),
    );
  });

  tearDown(() async {
    await serviceLocator.reset();
  });

  testWidgets('HomePage shows welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomePage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng đến Vulcan Playground'), findsOneWidget);
  });
}
