import 'dart:typed_data';

import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../domain/entity/firmware_channel.dart';
import '../helper/firmware_hardware_resolver.dart';
import '../model/firmware_model.dart';

class FirmwareRemoteApi extends RestfulApiClient {
  FirmwareRemoteApi({required super.baseUrl});

  static const _logger = Logger(className: "FirmwareRemoteApi");

  Future<FirmwareModel> fetchFirmwareMetadata({
    required VulcanDeviceType deviceType,
    required FirmwareChannel channel,
  }) async {
    final hardwareId = resolveFirmwareHardwareId(deviceType);
    final response = await getRequest<dynamic>(
      '/v1/hardware/$hardwareId/firmware',
      queryParameters: {'channel': channel.name},
    );

    _logger.debug('Restful API Response', response.data);
    final decoded = decodeJsonResponse(response.data);
    if (decoded is! Map<String, dynamic>) {
      throw const FirmwareException('Invalid firmware metadata response');
    }

    return FirmwareModel.fromJson(decoded);
  }

  Future<Uint8List> downloadFirmwareBytes(String url) async {
    try {
      final response = await client.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const FirmwareException('Firmware download returned empty data');
      }
      return Uint8List.fromList(data);
    } on DioException catch (error) {
      throw handleErrors(error);
    }
  }

  @override
  void applyAuthentication(RequestOptions options) {}

  @override
  Future<void> onUnauthorized(RequestOptions requestOptions) async {
    throw const FirmwareException('Unauthorized firmware API request');
  }

  @override
  Exception handleErrors(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 404) {
      return const FirmwareException('Firmware metadata not found');
    }
    return FirmwareException(e.message ?? 'Firmware API request failed');
  }

  @override
  dynamic decodeJsonResponse(data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data);
    return jsonDecode(jsonEncode(data));
  }

  @override
  Future<T> parseJson<T>(T Function() mapper) async => mapper();
}
