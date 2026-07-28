/// Push-to-open / push-to-close logic (LOGIC_UUID on MyoBand/Ring).
enum RingLogicControl {
  defaultOpen(1),
  defaultClose(2);

  const RingLogicControl(this.bleValue);

  final int bleValue;

  static RingLogicControl fromBleValue(int value) {
    if (value == 2) return RingLogicControl.defaultClose;
    return RingLogicControl.defaultOpen;
  }

  bool get isDefaultOpen => this == RingLogicControl.defaultOpen;

  bool get isDefaultClose => this == RingLogicControl.defaultClose;
}
