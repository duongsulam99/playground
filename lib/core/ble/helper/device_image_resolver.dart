import 'package:vulcan_mobile_playground/common/gen/index.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

/// Resolves local asset paths for Vulcan devices (ported from va_client `getImageDevice`).
class DeviceImageResolver {
  static String? assetPathFor(VulcanDeviceType deviceType) {
    switch (deviceType) {
      case VulcanDeviceType.hand:
      case VulcanDeviceType.handOld:
        return Assets.images.devices.hand99.path;

      case VulcanDeviceType.coaxial:
        return Assets.images.devices.otherHand.zeusHand.path;

      case VulcanDeviceType.wrist:
        return Assets.images.devices.wrist.path;

      case VulcanDeviceType.elbow:
      case VulcanDeviceType.elbowAdapter:
        return Assets.images.devices.elbowadapter.path;

      case VulcanDeviceType.bleAdapter:
      case VulcanDeviceType.electrode:
        return Assets.images.devices.emgElectrode.path;

      case VulcanDeviceType.sensorBox:
        return Assets.images.devices.sensorbox.path;

      case VulcanDeviceType.ring:
      case VulcanDeviceType.ringNrf:
      case VulcanDeviceType.ringDev3ch:
      case VulcanDeviceType.ringDev6ch:
      case VulcanDeviceType.ringWrist:
        return Assets.images.devices.myoband.path;

      case VulcanDeviceType.ringMedical:
        return Assets.images.devices.myobandMedical.path;

      case VulcanDeviceType.myoLink:
        return Assets.images.devices.myolink.path;

      case VulcanDeviceType.otherHand:
        return Assets.images.devices.otherHand.zeusHand.path;

      case VulcanDeviceType.none:
        return null;
    }
  }
}
