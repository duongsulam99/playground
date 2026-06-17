import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'abstract_dio_client.dart';

mixin TokenManagementMixin on AbstractDioClient {
  String accessToken = "";
  String refreshToken = "";
  DateTime accessTokenExpired = DateTime.now();

  final _storage = const FlutterSecureStorage();
  final String _storageKey = 'auth_token';

  @override
  Future<void> init() async {
    super.init();
    await getToken();
  }

  @override
  void applyAuthentication(RequestOptions options) {
    if (isLoggedIn()) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
  }

  @override
  Future<void> onUnauthorized(RequestOptions requestOptions) async {
    await refreshTokenCall();
  }

  Future<void> getToken() async {
    String? storedToken = await _storage.read(key: _storageKey);
    if (storedToken != null) {
      final tokenJson = jsonDecode(storedToken) as Map<String, dynamic>;

      accessToken = tokenJson['accessToken'] ?? '';
      refreshToken = tokenJson['refreshToken'] ?? '';
      accessTokenExpired = DateTime.fromMillisecondsSinceEpoch(
          tokenJson['accessTokenExpired'] ??
              DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<void> saveToken(
    String accessToken,
    String refreshToken,
    DateTime accessTokenExpired,
  ) async {
    final tokenData = {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpired': accessTokenExpired.millisecondsSinceEpoch,
    };

    await _storage.write(key: _storageKey, value: jsonEncode(tokenData));
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _storageKey);
    accessToken = '';
    refreshToken = '';
  }

  Future<void> refreshTokenCall();

  bool isLoggedIn() {
    return accessToken.isNotEmpty &&
        DateTime.now().isBefore(accessTokenExpired);
  }
}
