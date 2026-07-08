import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vulcan_mobile_playground/common/di/init_dependencies.dart';

import '../bloc/firmware_update/firmware_update_bloc.dart';
import '../pages/firmware_update_page.dart';
import 'firmware_update_args.dart';

class FirmwareUpdateRoute {
  static const String path = '/firmware/update';

  static Route<void> route({required FirmwareUpdateArgs args}) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => serviceLocator<FirmwareUpdateBloc>()
          ..add(
            FirmwareUpdateEvent.started(
              deviceId: args.deviceId,
              deviceType: args.deviceType,
              currentVersion: args.currentFirmwareVersion,
            ),
          ),
        child: const FirmwareUpdatePage(),
      ),
    );
  }
}
