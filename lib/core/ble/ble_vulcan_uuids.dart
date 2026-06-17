import 'package:vulcan_mobile_playground/core/ble/models/ble_characteristics_profile.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_services_profile.dart';

/// Source-of-truth typed BLE profiles for Vulcan devices (playground).
class BleVulcanProfiles {
  const BleVulcanProfiles._();

  static const handServices = HandBleServices(
    inforServiceUuid: '390950ed-51ff-445f-a6c6-f6a95a6a465f',
    controlServiceUuid: '7a59faa0-48b6-49db-80bc-2c94f0c6283b',
  );

  static const handCharacteristics = HandBleCharacteristics(
    otaUuid: '76095ead-54c4-4883-88a6-8297ba18211a',
    nameCharUuid: 'f2c513b7-6b51-4363-b6aa-1ef8bd08c56a',
    hardwareCharUuid: 'dc3c0fd6-c7e1-4f81-8e06-dbdbef8058bb',
    connectUuid: '8b8f9b38-9af4-11ee-b9d1-0242ac120002',
    settingUuid: 'a8302363-d1fa-4f07-80b6-47e47248bbf6',
    technicalUuid: '3a3a06ca-5235-4499-92c4-0f0c90c37915',
    addrUuid: '344aac91-da0e-4bd8-b4e6-913c7e8e63dc',
    angleUuid: 'e962a2e2-7645-4e6d-8fdc-b33b635c4450',
    controlUuid: '95fe21ab-c462-4b3c-a10a-c6713bcec972',
    batteryUuid: 'fd932c13-8aab-484d-b8b3-2e56591a7f9d',
  );

  static const elbowServices = ElbowBleServices(
    inforServiceUuid: 'cfb227d4-4fa1-11ee-be56-0242ac120002',
    controlServiceUuid: '546afe6a-6299-11ee-8c99-0242ac120002',
  );

  static const elbowCharacteristics = ElbowBleCharacteristics(
    otaUuid: '01621cb0-979a-4f74-8920-1c6ff6eb3e97',
    nameUuid: '216394f2-4f9b-11ee-be56-242ac1200022',
    hardwareUuid: '8745acee-241f-4ed2-883a-e29c27fea761',
    addrUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac1',
    controlUuid: '6bd4ff92-6299-8c99-7766-0242ac120002',
    speedUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac3',
    batteryUuid: 'e18abb38-4f9c-11ee-be56-0242ac120002',
    stateElbowUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac5',
    connectUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac6',
  );

  static const coaxialServices = CoaxialBleServices(
    inforServiceUuid: '9d9db9d1-cd4e-4a4c-a391-ab35f79b74ef',
    controlServiceUuid: 'd0232816-a375-46fa-a4a6-f062bdc1de2a',
    smpServiceUuid: '8D53DC1D-1DB7-4CD3-868B-8A527460AA84',
  );

  static const coaxialCharacteristics = CoaxialBleCharacteristics(
    otaUuid: 'fff8ba54-fa86-49cb-afea-20c370f8dccd',
    nameCharUuid: '90f4bc1d-6856-4528-b78a-a803b23adbbd',
    hardwareCharUuid: 'e0d32c17-5138-4903-a52a-405c51aa6619',
    connectUuid: '8a2fd88b-3e27-472e-ab00-69e96e7d0959',
    addrUuid: 'e8d2d449-bb77-4a2e-b179-35e195698e08',
    controlUuid: '95fe21ab-c462-4b3c-a10a-c6713bcec972',
    batteryUuid: '97e119d2-383c-4af0-80fd-b16b60611619',
  );

  static const wristServices = WristBleServices(
    inforServiceUuid: 'cfb227d4-4fa1-11ee-be56-0242ac120002',
    controlServiceUuid: '546afe6a-6299-11ee-8c99-0242ac120002',
    smpServiceUuid: '8D53DC1D-1DB7-4CD3-868B-8A527460AA84',
  );

  static const wristCharacteristics = WristBleCharacteristics(
    otaUuid: '01621cb0-979a-4f74-8920-1c6ff6eb3e97',
    nameUuid: '216394f2-4f9b-11ee-be56-242ac1200022',
    hardwareUuid: '8745acee-241f-4ed2-883a-e29c27fea761',
    addrUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac1',
    controlUuid: '6bd4ff92-6299-8c99-7766-0242ac120002',
    speedUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac3',
    batteryUuid: 'e18abb38-4f9c-11ee-be56-0242ac120002',
    stateWristUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac5',
    connectUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac6',
  );

  static const ringServices = RingBleServices(
    ringServiceUuid: 'db1df223-4020-4c5a-930c-1989ea04991f',
    sensorServiceUuid: 'efedd9eb-24a9-492a-b66a-ed8543ee096e',
    smpServiceUuid: '8d53dc1d-1db7-4cd3-868b-8a527460aa84',
  );

  static const ringCharacteristics = RingBleCharacteristics(
    otaUuid: '149f93ef-7481-4536-8f75-50b5b55ab058',
    nameCharUuid: '514bd5a1-1ef9-49c8-b569-127a84896d25',
    hardwareCharUuid: '4e1dd354-3a27-466f-bd2f-4a4b870a132a',
    modeCharUuid: 'b0b77c90-e567-42f4-b41f-37767d8c8465',
    actionButtonUuid: 'ded4b268-ef3c-4e08-ad24-169e3fbb4187',
    signalUuid: 'ebbb06e2-e254-4989-9555-a7fc9ca8f5c4',
    medicalUuid: '54a46f3b-4f3a-48ee-8dca-f42358b7483e',
    thresholdUuid: '39b2df5b-b7d4-48c6-afd2-e0095d4a999c',
    logicUuid: '363b46ab-0bc8-4b76-ad6f-2320302d1da5',
    stateControlUuid: '22e5bbd9-62d8-45eb-9ffd-4a2b88cd6c3a',
    batteryUuid: 'd23b3d36-e178-4528-af4d-7e8f9139aa20',
    countControlUuid: '9f340bf0-970e-4f02-8de5-a7b175abfdca',
    calibHistoryUuid: 'b55a506d-fc89-41ba-8d35-811a90bbe346',
    smpCharUuid: 'da2e7828-fbce-4e01-ae9e-261174997c48',
    settingUuid: '54a46f3b-4f3a-48ee-8dca-f42358b7483f',
  );

  static const sensorBoxServices = SensorBoxBleServices(
    sensorBoxServiceUuid: 'ffee1404-bbaa-9988-7766-554433221100',
    inforServiceUuid: '1800',
  );

  static const sensorBoxCharacteristics = SensorBoxBleCharacteristics(
    nameCharUuid: '2a00',
    stateControlUuid: 'ffee1999-bbaa-9988-7766-554433221100',
    batteryUuid: 'ffee2806-bbaa-9988-7766-554433221100',
  );

  static const bleAdapterServices = BleAdapterBleServices(
    inforServiceUuid: 'cfb227d4-4fa1-11ee-be56-0242ac120002',
    controlServiceUuid: '546afe6a-6299-11ee-8c99-0242ac120002',
  );

  static const bleAdapterCharacteristics = BleAdapterBleCharacteristics(
    otaUuid: '01621cb0-979a-4f74-8920-1c6ff6eb3e97',
    nameCharUuid: '216394f2-4f9b-11ee-be56-242ac1200022',
    hardwareCharUuid: '8745acee-241f-4ed2-883a-e29c27fea761',
    signalUuid: '1e738148-4f9c-11ee-be56-0242ac120002',
    stateControlUuid: '6bd4ff92-6299-8c99-7766-0242ac120002',
    logicUuid: 'bbacc8a2-4f9c-11ee-be56-0242ac120002',
    batteryUuid: 'e18abb38-4f9c-11ee-be56-0242ac120002',
  );
}

/// Backward-compatible alias while migrating call sites.
typedef BleVulcanUuids = BleVulcanProfiles;
