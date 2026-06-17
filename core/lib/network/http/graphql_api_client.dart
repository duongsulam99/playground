import 'package:dio/dio.dart';

import 'abstract_dio_client.dart';

abstract class GraphqlApiClient extends AbstractDioClient {
  GraphqlApiClient({required super.baseUrl});

  Future<Response<dynamic>> query(
    String query, {
    Map<String, dynamic>? variables,
    Options? options,
  }) async {
    return executeRequest(() => client.post(
          baseUrl,
          data: {'query': query, 'variables': variables},
          options: options,
        ));
  }

  Future<Response<dynamic>> mutate(
    String mutation, {
    Map<String, dynamic>? variables,
    Options? options,
  }) async {
    return executeRequest(() => client.post(
          baseUrl,
          data: {'query': mutation, 'variables': variables},
          options: options,
        ));
  }
}
