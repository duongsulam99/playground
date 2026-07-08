import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../domain/entity/firmware_channel.dart';
import '../helper/firmware_hardware_resolver.dart';
import '../model/firmware_model.dart';

class FirmwareFirebaseRemote {
  FirmwareFirebaseRemote({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const int _maxDownloadBytes = 4 * 1024 * 1024;
  static const _logger = Logger(className: "FirmwareFirebaseRemote");

  Future<FirmwareModel> fetchFirmwareMetadata({
    required VulcanDeviceType deviceType,
    required FirmwareChannel channel,
  }) async {
    try {
      final hardwareId = resolveFirmwareHardwareId(deviceType);
      final hardwareUid = await _resolveHardwareUid(hardwareId);
      final snapshot = await _queryFirmwareCollection(
        hardwareUid: hardwareUid,
        channel: channel,
      );

      if (snapshot.docs.isEmpty) {
        throw FirmwareException(
          'No firmware metadata found for $hardwareId (${channel.name})',
        );
      }

      final result = snapshot.docs.first.data();

      _logger.debug('Firebase API Response', result);

      return FirmwareModel.fromFirestore(result);
    } on FirmwareException {
      rethrow;
    } catch (error) {
      throw FirmwareException('Failed to fetch firmware metadata: $error');
    }
  }

  Future<Uint8List> downloadFirmwareBytes(String storageUrl) async {
    try {
      final reference = _storage.refFromURL(storageUrl);
      final data = await reference.getData(_maxDownloadBytes);
      if (data == null) {
        throw const FirmwareException('Firmware download returned null');
      }
      return data;
    } on FirmwareException {
      rethrow;
    } catch (error) {
      throw FirmwareException('Failed to download firmware: $error');
    }
  }

  Future<String> _resolveHardwareUid(String hardwareId) async {
    final hardwareSnapshot = await _firestore
        .collection('hardware')
        .where('hardwareID', isEqualTo: hardwareId)
        .get();

    if (hardwareSnapshot.docs.isEmpty) {
      throw FirmwareException('Hardware not found for id $hardwareId');
    }

    final uid = hardwareSnapshot.docs.first.data()['firebase_uid'];
    if (uid is! String || uid.isEmpty) {
      throw FirmwareException('Invalid firebase_uid for hardware $hardwareId');
    }

    return uid;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _queryFirmwareCollection({
    required String hardwareUid,
    required FirmwareChannel channel,
  }) {
    final hardwareDoc = _firestore.collection('hardware').doc(hardwareUid);

    switch (channel) {
      case FirmwareChannel.release:
        return hardwareDoc
            .collection('firmware')
            .orderBy('build_number', descending: true)
            .limit(1)
            .get();
      case FirmwareChannel.troubleshoot:
        return hardwareDoc
            .collection('firmware')
            .orderBy('build_number', descending: false)
            .limit(1)
            .get();
      case FirmwareChannel.dev:
        return hardwareDoc
            .collection('dev')
            .orderBy('build_number', descending: true)
            .limit(1)
            .get();
      case FirmwareChannel.airmouse:
        return hardwareDoc
            .collection('airmouse')
            .orderBy('build_number', descending: true)
            .limit(1)
            .get();
    }
  }
}
