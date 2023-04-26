part of '../dio_config.dart';

class ErrorInterceptor extends Interceptor {
  final Dio dio;

  ErrorInterceptor(this.dio);

  @override
  Future<void> onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) async {
    switch (err.type) {
      case DioErrorType.cancel:
      case DioErrorType.connectionTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        break;
      case DioErrorType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            break;
          case 404:
            break;
          case 500:
            break;
        }
        break;
      case DioErrorType.connectionError:
        // TODO: Handle this case.
        break;
      case DioErrorType.badCertificate:
        // TODO: Handle this case.
        break;
      case DioErrorType.unknown:
        // TODO: Handle this case.
        break;
    }

    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    final Response<dynamic> response =
        err.response ?? Response<dynamic>(requestOptions: err.requestOptions);
    return handler.resolve(response);
  }

  Future<void> handle401Error(
    DioError error,
    ErrorInterceptorHandler handler,
  ) async {
    return handler.next(error);
  }
}
