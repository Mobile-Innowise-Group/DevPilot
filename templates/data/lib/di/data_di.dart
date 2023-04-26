import 'package:core/config/app_config.dart';
import 'package:core/config/network/dio_config.dart';

import 'package:core/di/app_di.dart';

import '../errors/error_handler.dart';
import '../providers/api_provider.dart';

final DataDI dataDI = DataDI();

class DataDI {
  void initDependencies() {
    _initDio();
    _initApi();
  }

  void _initDio() {
    appLocator.registerLazySingleton<DioConfig>(
      () => DioConfig(
        appConfig: appLocator<AppConfig>(),
      ),
    );
  }


  void _initApi() {
    appLocator.registerLazySingleton<ErrorHandler>(
      ErrorHandler.new,
    );

    appLocator.registerLazySingleton<ApiProvider>(
      () => ApiProvider(
        appLocator<DioConfig>().dio,
      ),
    );
  }

}
