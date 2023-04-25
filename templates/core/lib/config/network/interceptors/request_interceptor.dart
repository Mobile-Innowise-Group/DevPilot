part of '../dio_config.dart';

class RequestInterceptor extends Interceptor {
  final Dio dio;
  final Map<String, String> headers;

  RequestInterceptor(this.dio, this.headers);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    return handler.next(options);
  }
}
