
import 'package:dio/dio.dart';
import 'package:domain/error_handler/app_exception.dart';

Future<dynamic> safeRequest(Future<dynamic> Function() request) async {
  try {
    return await request();
  } on DioError catch (e, stackTrace) {
    final Response<dynamic>? response = e.response;
    throw AppException(
      response?.data['message'].toString() ?? e.toString(),
    );
  }
}
