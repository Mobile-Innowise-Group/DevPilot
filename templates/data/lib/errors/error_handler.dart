import 'package:dio/dio.dart';
import 'package:domain/domain.dart';


class ErrorHandler {
  Future<Never> handleError(DioError error) async {
    final Response<dynamic>? response = error.response;
    if (response == null) {
      throw AppException('empty response');
    } else {
      final int? statusCode = response.statusCode;
      if (statusCode != null) {
        if (statusCode == 400) {
          throw AppException(
              error.response?.data['message'] ?? 'empty message');
        }

        if (statusCode == 401) {
          throw AppException(error.response?.data['message'] ?? 'no auth');
        }

        if (statusCode >= 500) {
          throw AppException(error.response?.data['message'] ?? 'server error');
        }
      }

      throw Exception(error.toString());
    }
  }
}
