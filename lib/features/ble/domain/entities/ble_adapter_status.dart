enum BleAdapterStatus {
  unknown,
  unavailable,
  unauthorized,
  turningOn,
  on,
  turningOff,
  off,
}

extension BleAdapterStatusX on BleAdapterStatus {
  bool get isReady => this == BleAdapterStatus.on;

  String get label {
    switch (this) {
      case BleAdapterStatus.unknown:
        return 'Unknown';
      case BleAdapterStatus.unavailable:
        return 'Unavailable';
      case BleAdapterStatus.unauthorized:
        return 'Unauthorized';
      case BleAdapterStatus.turningOn:
        return 'Turning on';
      case BleAdapterStatus.on:
        return 'On';
      case BleAdapterStatus.turningOff:
        return 'Turning off';
      case BleAdapterStatus.off:
        return 'Off';
    }
  }
}
