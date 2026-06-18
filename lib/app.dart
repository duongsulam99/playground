import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/common/di/init_dependencies.dart';
import 'package:vulcan_mobile_playground/common/router/app_router.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/ble/ble_bloc.dart';
import 'package:vulcan_mobile_playground/l10n/localization/app_localizations.dart';

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
      builder: (context, orientation, deviceType) {
        return ListenableBuilder(
          listenable: _localeController,
          builder: (context, _) {
            return BlocProvider.value(
              value: serviceLocator<BleBloc>(),
              child: MaterialApp(
                title: 'Vulcan Playground',
                debugShowCheckedModeBanner: false,
                locale: _localeController.value,
                localizationsDelegates:
                    AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: ThemeData(
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  useMaterial3: true,
                ),
                initialRoute: AppRouter.home,
                onGenerateRoute: route.onGenerateRoute,
                onUnknownRoute: route.unknownRoute,
              ),
            );
          },
        );
      },
    );
  }
}
