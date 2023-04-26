import 'package:dio/dio.dart';
part 'api_provider.g.dart';

abstract class ApiProvider {
  factory ApiProvider(Dio dio) = _ApiProvider;

  void setToken(String? token);
}
