class BleException implements Exception {
  const BleException(this.message, {this.deviceId});

  final String message;
  final String? deviceId;

  @override
  String toString() => 'BleException: $message';
}

class BleDeviceNotFoundException extends BleException {
  const BleDeviceNotFoundException(super.message, {super.deviceId});
}

class BleNotConnectedException extends BleException {
  const BleNotConnectedException(super.message, {super.deviceId});
}

class BleAdapterException extends BleException {
  const BleAdapterException(super.message);
}

class BleCharacteristicNotFoundException extends BleException {
  const BleCharacteristicNotFoundException(super.message, {super.deviceId});
}

class FirmwareException implements Exception {
  const FirmwareException(this.message);

  final String message;

  @override
  String toString() => 'FirmwareException: $message';
}
