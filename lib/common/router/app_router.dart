import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import '../../features/ble/presentation/routing/ble_device_info_route.dart';
import '../../features/ble/presentation/routing/ble_route.dart';
import '../../features/firmware/presentation/routing/firmware_update_args.dart';
import '../../features/firmware/presentation/routing/firmware_update_route.dart';
import '../screens/error_page.dart';
import '../screens/home_page.dart';

class AppRouter extends SuperAppRoute {
  /// Resolve the route based on the settings.
  @override
  Route<dynamic>? resolveRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomePage.path:
        return MaterialPageRoute(builder: (_) => const HomePage());

      /// Other routes
      case BleRoute.path:
        final filterTypes = settings.arguments as List<VulcanDeviceType>?;
        return BleRoute.route(filterTypes: filterTypes);
      case BleDeviceInfoRoute.path:
        final deviceId = settings.arguments as String;
        return BleDeviceInfoRoute.route(deviceId: deviceId);
      case FirmwareUpdateRoute.path:
        final args = settings.arguments as FirmwareUpdateArgs;
        return FirmwareUpdateRoute.route(args: args);

      /// Unknown route
      default:
        return null;
    }
  }

  /// Build the unknown route.
  @override
  Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => const ErrorPage());
  }
}
