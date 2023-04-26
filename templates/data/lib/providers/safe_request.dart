
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';


Future<dynamic> safeRequest(Future<dynamic> Function() request) async {
  try {
    return await request();
  } on DioError catch (e) {
    final Response<dynamic>? response = e.response;
    throw AppException(
      response?.data['message'].toString() ?? e.toString(),
    );
  }
}
