import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/ble/ble_bloc.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/pages/ble_page.dart';

class BleRoute {
  static const String path = '/ble';

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => GetIt.I<BleBloc>(),
        child: const BlePage(),
      ),
    );
  }
}
