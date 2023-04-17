

import 'package:dio/dio.dart';

import '../../../logger/logger.dart';


final dioLoggerInterceptor = InterceptorsWrapper(
  onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
    String headers = options.headers.entries
        .map((entry) => "${entry.key}: ${entry.value}")
        .join("\n");
    AppLogger().debug(
      "NETWORK REQUEST: ${options.method} ${options.uri}\n"
      "Query: ${options.data.toString()}\n"
      "Headers:\n$headers",
    );
    handler.next(options);
  },
  onResponse: (Response response, ResponseInterceptorHandler handler) async {
    if (response.data != null || response.data != []) {
      AppLogger().info(
        "NETWORK RESPONSE [code ${response.statusCode}]:\n"
        "🟢 ${response.data.toString()} 🟢",
      );
    }
    handler.next(response);
  },
  onError: (DioError error, ErrorInterceptorHandler handler) async {
    AppLogger().error(
      "NETWORK ERROR: ${error.error}: ${error.response?.toString()}\n"
      "path=${error.requestOptions.path}",
    );
    handler.next(error);
  },
);
