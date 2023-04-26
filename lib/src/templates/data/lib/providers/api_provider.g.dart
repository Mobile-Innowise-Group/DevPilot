part of 'api_provider.dart';

class _ApiProvider implements ApiProvider {
  _ApiProvider(this._dio);

  final Dio _dio;

  @override
  void setToken(String? token) {
    // TODO: implement setToken
  }
}
