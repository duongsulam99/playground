import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/ble/ble_adv_uuids.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_characteristics_profile.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_device_profile.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_services_profile.dart';


/// Base class định nghĩa các Profile GATT cho các thiết bị BLE Vulcan
/// 
/// Đây là các UUID được sử dụng trong family vulcan devices ( ring, hand, ... )
/// 
/// Chỉ ghi chú — không thay đổi giá trị UUID.
class BleVulcanProfiles {
  // ---------------------------------------------------------------------------
  // Hand (Vulcan Hand 9.9 / 9.7) — nguồn: handProcess.dart
  // ---------------------------------------------------------------------------

  static const _handServices = HandBleServices(
    // HAND_INFOR_SERVICE — metadata thiết bị (tên, firmware, hardware ID, pin)
    inforServiceUuid: '390950ed-51ff-445f-a6c6-f6a95a6a465f',
    // HAND_CONTROL_SERVICE — điều khiển tay, góc, cài đặt sensor
    controlServiceUuid: '7a59faa0-48b6-49db-80bc-2c94f0c6283b',
  );

  static const _handCharacteristics = HandBleCharacteristics(
    // OTA_UUID — Read | UTF-8 string | phiên bản firmware
    otaUuid: '76095ead-54c4-4883-88a6-8297ba18211a',
    // NAME_CHAR_UUID — Read/Write | UTF-8 string | tên hiển thị thiết bị
    nameCharUuid: 'f2c513b7-6b51-4363-b6aa-1ef8bd08c56a',
    // HARDWARE_CHAR_UUID — Read/Write | UTF-8 "140499"+HW ID | nhận diện loại tay (9.9 vs 9.7)
    hardwareCharUuid: 'dc3c0fd6-c7e1-4f81-8e06-dbdbef8058bb',
    // CONNECT_UUID — Read/Notify | 1 byte (1=connected) | trạng thái sensor ngoài
    connectUuid: '8b8f9b38-9af4-11ee-b9d1-0242ac120002',
    // SETTING_UUID — Read/Write/Notify | JSON UTF-8 | cài đặt nâng cao (FW ≥1.2): addr sensor, grip-lock, rotation error, max torque
    settingUuid: 'a8302363-d1fa-4f07-80b6-47e47248bbf6',
    // TECHNICAL_UUID — Read/Write | — | diagnostic/technical (dùng ở handTechnical.dart, không trong handProcess)
    technicalUuid: '3a3a06ca-5235-4499-92c4-0f0c90c37915',
    // ADDR_UUID — Read/Write | UTF-8 sensor ID / MAC hex | gán sensor legacy (FW <1.2)
    addrUuid: '344aac91-da0e-4bd8-b4e6-913c7e8e63dc',
    // ANGLE_UUID — Read/Write/Notify* | [angle,min,max,speed], speed 1–3 | giới hạn góc và tốc độ (*notify có code nhưng chưa bật on connect)
    angleUuid: 'e962a2e2-7645-4e6d-8fdc-b33b635c4450',
    // CONTROL_UUID — Write | 1 byte | lệnh điều khiển trung tâm (FW ≥1.55)
    controlUuid: '95fe21ab-c462-4b3c-a10a-c6713bcec972',
    // BATTERY_UUID — Read/Notify | 1 byte 0–100% | mức pin
    batteryUuid: 'fd932c13-8aab-484d-b8b3-2e56591a7f9d',
  );

  static const hand = BleDeviceProfile(
    advUuid: BleAdvUuids.advUUIDHand,
    services: _handServices,
    characteristics: _handCharacteristics,
  );

  // ---------------------------------------------------------------------------
  // Elbow — nguồn: elbowProcess.dart
  // ---------------------------------------------------------------------------

  static const _elbowServices = ElbowBleServices(
    // ELBOW_INFOR_SERVICE — metadata thiết bị
    inforServiceUuid: 'cfb227d4-4fa1-11ee-be56-0242ac120002',
    // ELBOW_CONTROL_SERVICE — điều khiển + sensor binding
    controlServiceUuid: '546afe6a-6299-11ee-8c99-0242ac120002',
  );

  static const _elbowCharacteristics = ElbowBleCharacteristics(
    // OTA_UUID — Read | UTF-8 string | phiên bản firmware
    otaUuid: '01621cb0-979a-4f74-8920-1c6ff6eb3e97',
    // NAME_UUID — Read/Write | UTF-8 string | tên hiển thị
    nameUuid: '216394f2-4f9b-11ee-be56-242ac1200022',
    // HARDWARE_UUID — Read/Write | UTF-8 "140499"+HW ID | nhận diện loại khuỷu
    hardwareUuid: '8745acee-241f-4ed2-883a-e29c27fea761',
    // ADDR_UUID — Read/Write | UTF-8 "prefix@MAC" | gán/đọc sensor đã ghép
    addrUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac1',
    // CONTROL_UUID — Write | 1 byte | lệnh điều khiển trung tâm (FW ≥1.55)
    controlUuid: '6bd4ff92-6299-8c99-7766-0242ac120002',
    // SPEED_UUID — Read/Write | byte hoặc UTF-8 string | tốc độ chuyển động
    speedUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac3',
    // BATTERY_UUID — Read/Notify | 1 byte 0–100% | mức pin
    batteryUuid: 'e18abb38-4f9c-11ee-be56-0242ac120002',
    // STATE_ELBOW_UUID — định nghĩa trong legacy nhưng chưa dùng trong elbowProcess.dart
    stateElbowUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac5',
    // CONNECT_UUID — Read/Notify | 1 byte (1=connected) | trạng thái sensor ngoài
    connectUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac6',
  );

  static const elbow = BleDeviceProfile(
    advUuid: BleAdvUuids.advUUIDElbow,
    services: _elbowServices,
    characteristics: _elbowCharacteristics,
  );

  // ---------------------------------------------------------------------------
  // Coaxial (Partner Hand BLE) — nguồn: coaxialProcess.dart
  // ---------------------------------------------------------------------------

  static const _coaxialServices = CoaxialBleServices(
    // COAXIAL_INFOR_SERVICE — metadata thiết bị
    inforServiceUuid: '9d9db9d1-cd4e-4a4c-a391-ab35f79b74ef',
    // COAXIAL_CONTROL_SERVICE — điều khiển + sensor binding
    controlServiceUuid: 'd0232816-a375-46fa-a4a6-f062bdc1de2a',
    // SMP_SERVICE — Nordic SMP service cho DFU (MCUmgr) khi firmware update
    smpServiceUuid: '8D53DC1D-1DB7-4CD3-868B-8A527460AA84',
  );

  static const _coaxialCharacteristics = CoaxialBleCharacteristics(
    // OTA_UUID — Read | UTF-8 string | phiên bản firmware
    otaUuid: 'fff8ba54-fa86-49cb-afea-20c370f8dccd',
    // NAME_CHAR_UUID — Read/Write | UTF-8 string | tên hiển thị
    nameCharUuid: '90f4bc1d-6856-4528-b78a-a803b23adbbd',
    // HARDWARE_CHAR_UUID — Read/Write | UTF-8 "140499"+HW ID | nhận diện loại coaxial
    hardwareCharUuid: 'e0d32c17-5138-4903-a52a-405c51aa6619',
    // CONNECT_UUID — Read/Notify | 1 byte (1=connected) | trạng thái sensor ngoài
    connectUuid: '8a2fd88b-3e27-472e-ab00-69e96e7d0959',
    // ADDR_UUID — Read/Write | UTF-8 sensor ID | gán/đọc sensor đã ghép
    addrUuid: 'e8d2d449-bb77-4a2e-b179-35e195698e08',
    // CONTROL_UUID — Write | 1 byte | lệnh điều khiển trung tâm (FW ≥1.0)
    controlUuid: '95fe21ab-c462-4b3c-a10a-c6713bcec972',
    // BATTERY_UUID — Read/Notify | 1 byte 0–100% | mức pin
    batteryUuid: '97e119d2-383c-4af0-80fd-b16b60611619',
  );

  static const coaxial = BleDeviceProfile(
    advUuid: BleAdvUuids.advUUIDCoaxial,
    services: _coaxialServices,
    characteristics: _coaxialCharacteristics,
  );

  // ---------------------------------------------------------------------------
  // Wrist — nguồn: wristProcess.dart (UUID map gần giống Elbow)
  // ---------------------------------------------------------------------------

  static const _wristServices = WristBleServices(
    // WRIST_INFOR_SERVICE — metadata thiết bị
    inforServiceUuid: 'cfb227d4-4fa1-11ee-be56-0242ac120002',
    // WRIST_CONTROL_SERVICE — điều khiển + sensor binding
    controlServiceUuid: '546afe6a-6299-11ee-8c99-0242ac120002',
    // SMP_SERVICE — Nordic SMP service cho DFU (MCUmgr) khi firmware update
    smpServiceUuid: '8D53DC1D-1DB7-4CD3-868B-8A527460AA84',
  );

  static const _wristCharacteristics = WristBleCharacteristics(
    // OTA_UUID — Read | UTF-8 string | phiên bản firmware
    otaUuid: '01621cb0-979a-4f74-8920-1c6ff6eb3e97',
    // NAME_UUID — Read/Write | UTF-8 string | tên hiển thị
    nameUuid: '216394f2-4f9b-11ee-be56-242ac1200022',
    // HARDWARE_UUID — Read/Write | UTF-8 "140499"+HW ID | nhận diện loại cổ tay
    hardwareUuid: '8745acee-241f-4ed2-883a-e29c27fea761',
    // ADDR_UUID — Read/Write | UTF-8 "prefix@MAC" | gán/đọc sensor đã ghép
    addrUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac1',
    // CONTROL_UUID — Write | 1 byte | lệnh điều khiển trung tâm (FW ≥1.55)
    controlUuid: '6bd4ff92-6299-8c99-7766-0242ac120002',
    // SPEED_UUID — Read/Write | byte hoặc UTF-8 string | tốc độ chuyển động
    speedUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac3',
    // BATTERY_UUID — Read/Notify | 1 byte 0–100% | mức pin
    batteryUuid: 'e18abb38-4f9c-11ee-be56-0242ac120002',
    // STATE_WRIST_UUID — định nghĩa trong legacy nhưng chưa dùng trong wristProcess.dart
    stateWristUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac5',
    // CONNECT_UUID — Read/Notify | 1 byte (1=connected) | trạng thái sensor ngoài
    connectUuid: 'f15421bd-25be-48a5-98c2-9aeed640bac6',
  );

  static const wrist = BleDeviceProfile(
    advUuid: BleAdvUuids.advUUIDElbow,
    services: _wristServices,
    characteristics: _wristCharacteristics,
  );

  // ---------------------------------------------------------------------------
  // Ring / MyoBand — nguồn: ringProcess.dart, ringThreshold.dart, ringSync.dart
  // ---------------------------------------------------------------------------

  static const _ringServices = RingBleServices(
    // RING_SERVICE — service chính Myoband
    ringServiceUuid: 'db1df223-4020-4c5a-930c-1989ea04991f',
    // SENSOR_SERVICE — legacy ring firmware <0.7 (advertising cũ)
    sensorServiceUuid: 'efedd9eb-24a9-492a-b66a-ed8543ee096e',
    // SMP_SERVICE — Nordic SMP service cho DFU (MCUmgr)
    smpServiceUuid: '8d53dc1d-1db7-4cd3-868b-8a527460aa84',
  );

  static const _ringCharacteristics = RingBleCharacteristics(
    // OTA_UUID — Read | UTF-8 string | phiên bản firmware
    otaUuid: '149f93ef-7481-4536-8f75-50b5b55ab058',
    // NAME_CHAR_UUID — Read/Write | UTF-8 string | tên hiển thị thiết bị
    nameCharUuid: '514bd5a1-1ef9-49c8-b569-127a84896d25',
    // HARDWARE_CHAR_UUID — Read/Write | UTF-8 HW ID (strip suffix "/...") | nhận diện loại Myoband
    hardwareCharUuid: '4e1dd354-3a27-466f-bd2f-4a4b870a132a',
    // MODE_CHAR_UUID — Read/Write | byte[0] hoặc UTF-8 number | chế độ hoạt động
    modeCharUuid: 'b0b77c90-e567-42f4-b41f-37767d8c8465',
    // VIBRATION_CHAR_UUID — Read/Write | 2 byte binary RingVibrationConfig | cường độ rung + trigger flags
    vibrationCharUuid: 'eca2c4c8-7766-43c6-b34c-a68abe448292',
    // ACTION_BUTTON_UUID — Read/Write/Notify | 2 bytes / UTF-8 "label0|label1" | map nút vật lý (none/logic/speed/force/controlGrip)
    actionButtonUuid: 'ded4b268-ef3c-4e08-ad24-169e3fbb4187',
    // SIGNAL_UUID — Write "255"/"000" + Notify ≥32B | 8× float32 LE (EMG ch0–2 + IMU) | stream realtime cho hiệu chuẩn
    signalUuid: 'ebbb06e2-e254-4989-9555-a7fc9ca8f5c4',
    // MEDICAL_UUID — Write 1 byte MedicalMode + Notify | packet y tế (EMG, IMU, HR, SpO2…) | chế độ medical/rehab
    // LƯU Ý: trùng UUID với SETTING_UUID trên firmware cũ — cùng characteristic, khác ngữ cảnh dùng
    medicalUuid: '54a46f3b-4f3a-48ee-8dca-f42358b7483e',
    // THRESHOLD_UUID — Read/Write | 28-byte RingThresholdConfig hoặc legacy text/binary | ngưỡng EMG: threshold[1]=nghỉ, [2]=co; exThreshold, handUp/Down, move
    thresholdUuid: '39b2df5b-b7d4-48c6-afd2-e0095d4a999c',
    // LOGIC_UUID — Read/Write | byte hoặc UTF-8 "1"/"2" | logic điều khiển: 1=mặc định mở, 2=mặc định đóng
    logicUuid: '363b46ab-0bc8-4b76-ad6f-2320302d1da5',
    // STATE_CONTROL_UUID — Notify | 1–3 bytes [state,?,?] | trạng thái điều khiển realtime (subscribe có nhưng thường không bật on connect)
    stateControlUuid: '22e5bbd9-62d8-45eb-9ffd-4a2b88cd6c3a',
    // BATTERY_UUID — Read/Notify | byte[0]=%; byte[1]=0x2B nếu đang sạc | mức pin + trạng thái charging
    batteryUuid: 'd23b3d36-e178-4528-af4d-7e8f9139aa20',
    // COUNT_CONTROL_UUID — Read/Write | UTF-8 epoch + 10-byte records × N ngày | đồng bộ thời gian + lịch sử open/hold/close
    countControlUuid: '9f340bf0-970e-4f02-8de5-a7b175abfdca',
    // CALIB_HISTORY_UUID — Read | 10-byte records × N | lịch sử hiệu chuẩn (threshold0, lower, upper + epoch)
    calibHistoryUuid: 'b55a506d-fc89-41ba-8d35-811a90bbe346',
    // SMP_CHAR_UUID — Write | 10-byte SMP reset frame | factory/DFU reset trên ring hỗ trợ SMP
    smpCharUuid: 'da2e7828-fbce-4e01-ae9e-261174997c48',
    // SETTING_UUID — Read/Write | byte[0]=PMIC, byte[1]=battery type (FW ≥1.81) | cấu hình PMIC/loại pin
    // LƯU Ý: trùng UUID với MEDICAL_UUID trên firmware cũ — cùng characteristic, khác ngữ cảnh dùng
    settingUuid: '54a46f3b-4f3a-48ee-8dca-f42358b7483e',
  );

  static const ring = BleDeviceProfile(
    advUuid: BleAdvUuids.advUUIDRing,
    additionalAdvUuids: [BleAdvUuids.advUUIDRingOld],
    services: _ringServices,
    characteristics: _ringCharacteristics,
  );

  // ---------------------------------------------------------------------------
  // SensorBox — nguồn: sensorboxProcess.dart
  // ---------------------------------------------------------------------------

  static const _sensorBoxServices = SensorBoxBleServices(
    // SENSORBOX_SERVICE — service chính Sensorbox
    sensorBoxServiceUuid: 'ffee1404-bbaa-9988-7766-554433221100',
    // SENSORBOX_INFOR_SERVICE — GAP 0x1800 (device name chuẩn BLE)
    inforServiceUuid: '1800',
  );

  static const _sensorBoxCharacteristics = SensorBoxBleCharacteristics(
    // NAME_CHAR_UUID (GAP 0x2A00) — Read | UTF-8 string | tên thiết bị chuẩn BLE
    nameCharUuid: '2a00',
    // STATE_CONTROL_UUID — Notify | 3 bytes control[0..2] | stream trạng thái điều khiển sensor
    stateControlUuid: 'ffee1999-bbaa-9988-7766-554433221100',
    // BATTERY_UUID — Read/Notify | 1 byte 0–100% | mức pin
    batteryUuid: 'ffee2806-bbaa-9988-7766-554433221100',
  );

  static const sensorBox = BleDeviceProfile(
    advUuid: BleAdvUuids.advUUIDSensorbox,
    services: _sensorBoxServices,
    characteristics: _sensorBoxCharacteristics,
  );

  // ---------------------------------------------------------------------------
  // BLE Adapter (Electrode) — nguồn: bleadapterProcess.dart
  // ---------------------------------------------------------------------------

  static const _bleAdapterServices = BleAdapterBleServices(
    // BLEADAPTER_INFOR_SERVICE — metadata thiết bị (cùng UUID family với Elbow/Wrist)
    inforServiceUuid: 'cfb227d4-4fa1-11ee-be56-0242ac120002',
    // BLEADAPTER_CONTROL_SERVICE — điều khiển adapter
    controlServiceUuid: '546afe6a-6299-11ee-8c99-0242ac120002',
  );

  static const _bleAdapterCharacteristics = BleAdapterBleCharacteristics(
    // OTA_UUID — Read | UTF-8 string | phiên bản firmware
    otaUuid: '01621cb0-979a-4f74-8920-1c6ff6eb3e97',
    // NAME_CHAR_UUID — Read/Write | UTF-8 string | tên hiển thị
    nameCharUuid: '216394f2-4f9b-11ee-be56-242ac1200022',
    // HARDWARE_CHAR_UUID — Read/Write | UTF-8 "140499"+HW ID | nhận diện loại BLE adapter
    hardwareCharUuid: '8745acee-241f-4ed2-883a-e29c27fea761',
    // SIGNAL_UUID — định nghĩa trong legacy nhưng chưa wire trong bleadapterProcess.dart
    signalUuid: '1e738148-4f9c-11ee-be56-0242ac120002',
    // STATE_CONTROL_UUID — Notify | 1–3 bytes control[0..2] | trạng thái điều khiển adapter
    stateControlUuid: '6bd4ff92-6299-8c99-7766-0242ac120002',
    // LOGIC_UUID — Read/Write | UTF-8 "1"/"2" | logic mở/đóng: 1=mặc định mở, 2=mặc định đóng
    logicUuid: 'bbacc8a2-4f9c-11ee-be56-0242ac120002',
    // BATTERY_UUID — Read/Notify | Read: UTF-8 int; Notify: byte[0] | mức pin
    batteryUuid: 'e18abb38-4f9c-11ee-be56-0242ac120002',
  );

  static const bleAdapter = BleDeviceProfile(
    advUuid: BleAdvUuids.advUUIDBleadapter,
    services: _bleAdapterServices,
    characteristics: _bleAdapterCharacteristics,
  );

  // (bao gồm GATT Services và Characteristics) và đăng ký vào danh sách `all` dưới đây.
  //TODO:[Add New Device] Step 1: Định nghĩa BleDeviceProfile của thiết bị mới

  /// Tất cả profile GATT đã đăng ký.
  static const List<BleDeviceProfile> all = [
    hand,
    elbow,
    coaxial,
    wrist,
    ring,
    sensorBox,
    bleAdapter,
  ];

  /// Tất cả advertisement UUIDs cho scan không lọc.
  static List<Guid> allVulcanScanGuids() {
    return List.generate(all.length, (index) => Guid(all[index].advUuid));
    // return BleAdvUuids.allAdvUuids.map(Guid.new).toList();
  }

  /// Map [types] sang native scan service UUIDs (deduplicated).
  static List<Guid> scanGuidsForDeviceTypes(List<VulcanDeviceType> types) {
    final addedUuids = <String>{};
    final guids = <Guid>[];

    void addUuid(String uuid) {
      if (addedUuids.add(uuid)) {
        guids.add(Guid(uuid));
      }
    }

    for (final type in types) {
      final profile = type.profile;
      if (profile == null) continue;

      for (final uuid in profile.allAdvUuids) {
        addUuid(uuid);
      }

      // elbowAdapter: scan-only, không có GATT profile
      if (type == VulcanDeviceType.elbowAdapter) {
        addUuid(BleAdvUuids.advUUIDBleadapter);
      }
    }

    return guids;
  }
}

/// Backward-compatible alias while migrating call sites.
// typedef BleVulcanUuids = BleVulcanProfiles;
