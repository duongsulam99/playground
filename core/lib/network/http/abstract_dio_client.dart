import 'package:dio/dio.dart';

abstract class AbstractDioClient {
  final Dio client;
  final CancelToken cancelToken = CancelToken();
  final BaseOptions baseOptions = BaseOptions(contentType: "application/json");
  final String baseUrl;

  AbstractDioClient({required this.baseUrl, Dio? dioInstance})
      : client = dioInstance ?? Dio() {
    client.options = baseOptions;
    client.options.baseUrl = baseUrl;
    init();
  }

  Future<void> init() async {
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, handler) {
          options.cancelToken = cancelToken;
          applyAuthentication(options);
          return handler.next(options);
        },
        onResponse: (Response response, handler) {
          debugStatusLog(response);
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (shouldHandleUnauthorized(e.response?.statusCode)) {
            await onUnauthorized(e.requestOptions);
            return;
          }
          return handler.next(e);
        },
      ),
    );
  }

  void applyAuthentication(RequestOptions options);
  Future<void> onUnauthorized(RequestOptions requestOptions);

  Future<Response<T>> executeRequest<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw handleErrors(e);
    }
  }

  static bool shouldHandleUnauthorized(int? statusCode) {
    return statusCode == 403 || statusCode == 401;
  }

  /// Handles Dio errors.
  Exception handleErrors(DioException e);

  /// Decodes raw Dio response payload into a JSON object/array.
  dynamic decodeJsonResponse(dynamic data);

  /// Parses decoded JSON into any target model type.
  Future<T> parseJson<T>(T Function() mapper);

  /// Logs raw Dio response payload to the console.
  void debugStatusLog(Response response) {
    return;
  }

  void cancelAllRequests() {
    cancelToken.cancel();
  }
}
