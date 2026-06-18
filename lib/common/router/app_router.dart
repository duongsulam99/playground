import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/routing/ble_route.dart';

import '../screens/error_page.dart';
import '../screens/home_page.dart';

class AppRouter extends SuperAppRoute {
  static const String home = '/';

  @override
  Route<dynamic>? resolveRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case BleRoute.path:
        final filterTypes = settings.arguments as List<VulcanDeviceType>?;
        return BleRoute.route(filterTypes: filterTypes);
      default:
        return null;
    }
  }

  @override
  Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => const ErrorPage());
  }
}
