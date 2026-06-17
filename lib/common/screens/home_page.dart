import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/common/di/init_dependencies.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/routing/ble_route.dart';
import 'package:vulcan_mobile_playground/l10n/localization/l10n_extension.dart';

import '../../core/ble/device_type.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = serviceLocator<AbstractLocaleController>();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(context.l10n.homeWelcome),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => localeController.setLocale(const Locale('vi')),
              child: Text(context.l10n.languageVi),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => localeController.setLocale(const Locale('en')),
              child: Text(context.l10n.languageEn),
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pushNamed(BleRoute.path),
              child: const Text('BLE Lab'),
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(BleRoute.path, arguments: [VulcanDeviceType.myoLink]),
              child: const Text('BLE Lab (Only band, ... devices)'),
            ),
          ],
        ),
      ),
    );
  }
}
