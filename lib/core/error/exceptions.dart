class BleException implements Exception {
  const BleException(this.message);

  final String message;

  @override
  String toString() => 'BleException: $message';
}

class BleDeviceNotFoundException extends BleException {
  const BleDeviceNotFoundException([super.message = 'Device not found']);
}

class BleNotConnectedException extends BleException {
  const BleNotConnectedException([super.message = 'No device connected']);
}

class BleAdapterException extends BleException {
  const BleAdapterException(super.message);
}
