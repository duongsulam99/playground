import 'package:vulcan_mobile_playground/core/ble/enums/DFU/dfu_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import 'dfu_strategy.dart';
import 'esp32_ota_strategy.dart';
import 'nordic_mcumgr_strategy.dart';

class DfuStrategyFactory {
  DfuStrategyFactory({
    Esp32OtaStrategy? esp32OtaStrategy,
    NordicMcumgrStrategy? nordicMcumgrStrategy,
  }) : _esp32OtaStrategy = esp32OtaStrategy ?? const Esp32OtaStrategy(),
       _nordicMcumgrStrategy = nordicMcumgrStrategy ?? NordicMcumgrStrategy();

  final Esp32OtaStrategy _esp32OtaStrategy;
  final NordicMcumgrStrategy _nordicMcumgrStrategy;

  DfuStrategy resolve(DfuType type) {
    return switch (type) {
      DfuType.esp32Custom => _esp32OtaStrategy,
      DfuType.nordicDfu => _nordicMcumgrStrategy,
      DfuType.none => throw const FirmwareException(
        'Device does not support firmware update',
      ),
    };
  }
}
