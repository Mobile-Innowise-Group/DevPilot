import 'dart:io';

class AppConstants {
  //STRING CONSTANTS
  static const String kEnterProjectName = 'Enter a project name: ';
  static const String kUpdateDartVersion =
      'Your Dart SDK version is not supported. Please upgrade to a version >=3.2.3 and <4.0.0';
  static const String kEnterValidProjectName =
      'Please enter a valid project name (full string or snake case string): ';
  static const String kNeedSpecifyPath =
      'Do you need specify path ? Note if you select "no" project will be created in a current location (Yes/No): ';
  static const String kEnterPath = 'Please specify the path where you want to create the project: ';
  static const String kInvalidPath = 'Invalid path. Please specify a valid path: ';
  static const String kAddFeature = 'Do you want add features now? (Yes/No): ';
  static const String kYes = 'yes';
  static const String kNo = 'no';
  static const String kInvalidYesOrNo = 'Invalid input. Please enter "yes" or "no": ';
  static const String kEnterFeatures =
      'Please enter all required feature modules separated by commas : ';
  static const String kInvalidFeatureName =
      'Invalid feature modules input. Please enter full string or snake case strings separated by commas : ';
  static const String kWillYouUseDio = 'Will you use Dio in your project? (yes/no) ';
  static const String kWillYouUseFlavours = 'Will you use flavors in your project? (yes/no) ';
  static const String kEnterFlavours =
      'Please enter the flavors separated by commas (dev, stage, prod etc...): ';
  static const String kInvalidFlavours =
      'Invalid input. Please enter only full strings separated by commas : ';

  static String kAddPackages(String modulesString) {
    return 'Do you want to add any packages to any of the following modules (core, core_ui, data, domain, navigation, features ${modulesString.isEmpty ? '' : <String>[
        modulesString
      ]})? (yes/no): ';
  }

  static String kSelectModule(String modulesString) {
    return 'Please select a module from the following list to add packages to (core, core_ui, data, domain, navigation, features ${modulesString.isEmpty ? '' : <String>[
        modulesString
      ]} ) : ';
  }

  static String kAddPackageSelectModule(String? selectedModule) {
    return 'Please enter the packages you want to add to ${selectedModule ?? ''} module (comma-separated): ';
  }

  static String kAddPackageFeatureModule(String? featureName) {
    return 'Please enter the packages you want to add to the $featureName feature (comma-separated): ';
  }

  static String kFailCreateProject(String? error) {
    return 'Failed to create Flutter project: $error';
  }

  static const String kEnterFeatureForPackage =
      'Please enter the feature name for which you want to add packages: ';
  static const String kInvalidFeatureForPackage =
      'Invalid feature name entered. Please try again.\n';
  static const String kInvalidModuleName = 'Invalid module name entered. Please try again.\n';
  static const String kAddPackageOtherModule =
      'Do you want to add packages to any other module? (yes/no): ';
  static const String kInvalidPackage = 'Invalid Package input please try again: ';

  static const String kCore = 'core';
  static const String kCoreUi = 'core_ui';
  static const String kData = 'data';
  static const String kDomain = 'domain';
  static const String kFeatures = 'features';
  static const String kFeature = 'feature';
  static const String kNavigation = 'navigation';
  static const String kApp = 'app';

  static const String kFlutter = 'flutter';
  static const String kCreate = 'create';
  static const String kNoPub = '--no-pub';
  static const String kOrg = '--org';
  static const String kComExample = 'com.example';
  static const String kProjectName = '--project-name';

  static String kCurrentPath = Directory.current.path;
  static String kTemplates = '$kCurrentPath/lib/src/templates';
  static const String kFiles = 'files';
  static const String kGlobalErrorHandler = 'error_handler';

  static const String kFeaturePlug = 'name: plug';

  static String kFeaturePlugReplaceWith(String? featureName) {
    return 'name: $featureName';
  }

  static String kInvalidSourceFolder(String folder) {
    return '$folder folder does not exist';
  }

  static const String kRemoteTemplatesLink =
      'https://github.com/Mobile-Innowise-Group/DevPilotTemplates';

  static String kFlavourContent(String flavor) {
    return '''
import 'package:core/core.dart';

import 'main_common.dart';

void main() {
  mainCommon(Flavor.$flavor);
}
    ''';
  }

  static const String kSdkFlutter = 'sdk: flutter';

  static const String kAppConfigPath = 'core/lib/src/config/app_config.dart';

  static const String kFlavorEnum = 'enum Flavor {';

  static const String kFlavorSwitch = 'switch (flavor) {';

  static String kFlavorCase(String flavor) {
    return '''
    case Flavor.$flavor:
        baseUrl = '';
        webSocketUrl = '';
        break;
    ''';
  }

  static String kMainPubspecDependencies = '''
  domain:
    path: ./domain
  core:
    path: ./core
  core_ui:
    path: ./core_ui
  data:
    path: ./data
  navigation:
    path: ./navigation''';

  static const String kMainFlavorlessContent = '''
$mainImports

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  _setupDI(Flavor.dev);

  runApp(const App());
}

$mainDiSetup

$mainApp
  ''';

  static const String kMainCommonContent = '''
$mainImports

Future<void> mainCommon(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  _setupDI(flavor);

  runApp(const App());
}

$mainDiSetup

$mainApp
  ''';

  static const String mainImports = '''
import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:navigation/navigation.dart';

import 'error_handler/provider/app_error_handler_provider.dart';
  ''';

  static const String mainDiSetup = '''
void _setupDI(Flavor flavor) {
  appLocator.pushNewScope(
    scopeName: unauthScope,
    init: (_) {
      AppDI.initDependencies(appLocator, flavor);
      DataDI.initDependencies(appLocator);
      DomainDI.initDependencies(appLocator);
      NavigationDI.initDependencies(appLocator);
    },
  );
}
  ''';

  static const String mainApp = '''
class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = appLocator<AppRouter>();

    return EasyLocalization(
      path: AppLocalization.langFolderPath,
      supportedLocales: AppLocalization.supportedLocales,
      fallbackLocale: AppLocalization.fallbackLocale,
      child: Builder(
        builder: (BuildContext context) {
          return AppErrorHandlerProvider(
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter.config(),
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: lightTheme,
            ),
          );
        },
      ),
    );
  }
}
  ''';

  static const String kLogo = '''
╦┌┐┌┌┐┌┌─┐┬ ┬┬┌─┐┌─┐
║│││││││ │││││└─┐├┤ 
╩┘└┘┘└┘└─┘└┴┘┴└─┘└─┘         
  ''';
}
