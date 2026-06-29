import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';

import '../models/ble_characteristics_profile.dart';
import '../models/ble_services_profile.dart';

/// Collects runtime [BluetoothCharacteristic] handles from discovered GATT services.
class BleGattCollector {
  const BleGattCollector._();

  static const logger = Logger(className: 'BleGattCollector');

  static Map<String, BluetoothCharacteristic> collect({
    required List<BluetoothService> services,
    required BleServicesProfile servicesProfile,
    required BleCharacteristicsProfile characteristicsProfile,
  }) {
    /// Convert Service Profile UUIDs to lowercase
    final serviceProfileUuids = servicesProfile.uuids
        .map((uuid) => uuid)
        .toSet();

    /// Create Characteristics LinkedMap
    final characteristics = <String, BluetoothCharacteristic>{};

    /// Loop through every available services in device
    for (final service in services) {
      /// Check if service UUID is in profile
      final serviceUuid = service.serviceUuid.toString();

      /// If not in profile, skip it
      if (!serviceProfileUuids.contains(serviceUuid)) {
        logger.debug('service', 'Service $serviceUuid not in profile');
        continue;
      }

      /// If in profile, loop through every characteristic
      for (final characteristic in service.characteristics) {
        /// Check if characteristic UUID is in profile
        final key = characteristicsProfile.keyFor(
          characteristic.uuid.toString(),
        );

        /// If characteristic UUID is not in profile, SKIP
        if (key == null || key.isEmpty) {
          logger.debug(
            'CHARACTERISTIC NOT FOUND',
            '${characteristic.uuid} not in profile and skipped',
          );
          continue;
        }

        logger.debug('FOUND', '[$key] for $serviceUuid');

        /// Add characteristic to map
        characteristics[key] = characteristic;
      }
    }

    return characteristics;
  }
}
