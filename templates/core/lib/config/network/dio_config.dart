import 'dart:async';

import 'package:dio/dio.dart';
import '../app_config.dart';
import 'interceptors/dio_log_interceptor.dart';

part 'interceptors/error_interceptor.dart';
part 'interceptors/request_interceptor.dart';
part 'interceptors/response_interceptor.dart';

class DioConfig {
  final AppConfig appConfig;
  static const int timeout = 10 * 1000;

  final Dio _dio = Dio();

  Dio get dio => _dio;

  DioConfig({required this.appConfig}) {
    _dio
      ..options.baseUrl = appConfig.baseUrl
      ..interceptors.addAll(<Interceptor>[
        RequestInterceptor(_dio, headers),
        ErrorInterceptor(_dio),
        ResponseInterceptor(_dio),
        dioLoggerInterceptor,
      ]);
  }

  Map<String, String> headers = <String, String>{};

  void setToken(String? token) {
    headers['authtoken'] = token ?? '';
  }
}
