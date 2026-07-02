import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/common/di/init_dependencies.dart';
import 'package:vulcan_mobile_playground/common/router/app_router.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/ble/ble_bloc.dart';
import 'package:vulcan_mobile_playground/l10n/localization/app_localizations.dart';
import 'package:vulcan_mobile_playground/theme/playground_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppRouter route = AppRouter();
  late final _localeController = serviceLocator<AbstractLocaleController>();

  @override
  Widget build(BuildContext context) {
    return Sizer(
      // OrientationBuilder and DeviceTypeBuilder
      // Trigger when device orientation or type changes
      builder: (context, orientation, deviceType) {
        return ListenableBuilder(
          listenable: _localeController,

          // Locale changes will rebuild of the GlobalMainApp
          // Trigger when locale changes
          builder: (context, _) {
            return BlocProvider.value(
              value: serviceLocator<BleBloc>(),
              child: GlobalMainApp(
                localeController: _localeController,
                route: route,
              ),
            );
          },
        );
      },
    );
  }
}

class GlobalMainApp extends StatelessWidget {
  const GlobalMainApp({
    super.key,
    required this.localeController,
    required this.route,
  });

  final AbstractLocaleController localeController;
  final AppRouter route;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vulcan Playground',
      debugShowCheckedModeBanner: false,
      locale: localeController.value,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: PlaygroundTheme.light,
      darkTheme: PlaygroundTheme.dark,
      themeMode: ThemeMode.light,
      initialRoute: AppRouter.home,
      onGenerateRoute: route.onGenerateRoute,
      onUnknownRoute: route.unknownRoute,
    );
  }
}
