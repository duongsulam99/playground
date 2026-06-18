enum BleConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

extension BleConnectionStatusX on BleConnectionStatus {
  bool get isConnected => this == BleConnectionStatus.connected;

  String get label {
    switch (this) {
      case BleConnectionStatus.disconnected:
        return 'Disconnected';
      case BleConnectionStatus.connecting:
        return 'Connecting';
      case BleConnectionStatus.connected:
        return 'Connected';
      case BleConnectionStatus.disconnecting:
        return 'Disconnecting';
    }
  }
}
