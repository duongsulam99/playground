import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

/// Resolves local asset paths for Vulcan devices (ported from va_client `getImageDevice`).
class BleDeviceImageResolver {
  const BleDeviceImageResolver._();

  static const _hand = 'assets/images/devices/hand99.png';
  static const _coaxialDefault =
      'assets/images/devices/otherHand/zeusHand.png';
  static const _wrist = 'assets/images/devices/wrist.png';
  static const _elbow = 'assets/images/devices/elbowadapter.png';
  static const _emgElectrode = 'assets/images/devices/emgElectrode.png';
  static const _sensorBox = 'assets/images/devices/sensorbox.png';
  static const _myoband = 'assets/images/devices/myoband.png';
  static const _myobandMedical = 'assets/images/devices/myoband_medical.png';
  static const _myolink = 'assets/images/devices/myolink.png';

  static String? assetPathFor(VulcanDeviceType deviceType) {
    switch (deviceType) {
      case VulcanDeviceType.hand:
      case VulcanDeviceType.handOld:
        return _hand;

      case VulcanDeviceType.coaxial:
        return _coaxialDefault;

      case VulcanDeviceType.wrist:
        return _wrist;

      case VulcanDeviceType.elbow:
      case VulcanDeviceType.elbowAdapter:
        return _elbow;

      case VulcanDeviceType.bleAdapter:
      case VulcanDeviceType.electrode:
        return _emgElectrode;

      case VulcanDeviceType.sensorBox:
        return _sensorBox;

      case VulcanDeviceType.ring:
      case VulcanDeviceType.ringNrf:
      case VulcanDeviceType.ringDev3ch:
      case VulcanDeviceType.ringDev6ch:
      case VulcanDeviceType.ringWrist:
        return _myoband;

      case VulcanDeviceType.ringMedical:
        return _myobandMedical;

      case VulcanDeviceType.myoLink:
        return _myolink;

      case VulcanDeviceType.otherHand:
        return _coaxialDefault;

      case VulcanDeviceType.none:
        return null;
    }
  }
}
