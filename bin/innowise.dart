import 'dart:io';

import 'package:args/args.dart';
import 'package:innowise/app_constants.dart';
import 'package:innowise/directory_service.dart';
import 'package:innowise/file_service.dart';
import 'package:innowise/input.dart';
import 'package:innowise/script_service.dart';
import 'package:innowise/validator.dart';

void main(List<String> arguments) async {

  final parser = ArgParser()
  ..addCommand('create')
    ..addOption(
      'create',
      abbr: 'c',
      help: 'Specify project name',
    );

  final ArgResults argResults = parser.parse(arguments);

  if (argResults.arguments.contains('create')) {
    String? path = AppConstants.kCurrentPath;
    List<String> featureModules = [];
    List<String> flavors = [];
    bool isPackagesNeeded = false;
    List<String> packageModules = [];
    Map<String, List<String>> packages = {};

    final List<String> mainModules = [
      AppConstants.kCore,
      AppConstants.kCoreUi,
      AppConstants.kData,
      AppConstants.kDomain,
      AppConstants.kNavigation,
    ];

    //PROJECT NAME
    String? projectName = Input.getValidatedInput(
      stdoutMessage: AppConstants.kEnterProjectName,
      errorMessage: AppConstants.kEnterValidProjectName,
      functionValidator: Validator.kIsValidProjectName,
    );

    //PATH
    String? specifyPath = Input.getValidatedInput(
      stdoutMessage: AppConstants.kNeedSpecifyPath,
      errorMessage: AppConstants.kInvalidYesOrNo,
      isPositiveResponse: true,
    );

    if (specifyPath == AppConstants.kYes) {
      path = Input.getValidatedInput(
        stdoutMessage: AppConstants.kEnterPath,
        errorMessage: AppConstants.kInvalidPath,
        functionValidator: Validator.kIsValidPath,
      );
    }
    // FEATURE
    String? addFeatures = Input.getValidatedInput(
      stdoutMessage: AppConstants.kAddFeature,
      errorMessage: AppConstants.kAddFeature,
      isPositiveResponse: true,
    );

    if (addFeatures == AppConstants.kYes) {
      String? featuresInput = Input.getValidatedInput(
        stdoutMessage: AppConstants.kEnterFeatures,
        errorMessage: AppConstants.kInvalidFeatureName,
        functionValidator: Validator.kIsValidListString,
      );
      featureModules = featuresInput!.split(',').map((e) => e.trim()).toList();
    }

    //DIO
    // String? dioInput = Input.getValidatedInput(
    //   stdoutMessage: AppConstants.kWillYouUseDio,
    //   errorMessage: AppConstants.kWillYouUseDio,
    //   isPositiveResponse: true,
    // );
    //
    // bool isDioNeeded = dioInput == AppConstants.kYes;

    //FLAVORS
    String? flavorsInput = Input.getValidatedInput(
      stdoutMessage: AppConstants.kWillYouUseFlavours,
      errorMessage: AppConstants.kInvalidYesOrNo,
      isPositiveResponse: true,
    );

    bool isFlavorsNeeded = flavorsInput == AppConstants.kYes;

    if (isFlavorsNeeded) {
      String? flavorsInput = Input.getValidatedInput(
        stdoutMessage: AppConstants.kEnterFlavours,
        errorMessage: AppConstants.kInvalidFlavours,
        functionValidator: Validator.kIsValidFlavorsInput,
      );
      flavors =
          flavorsInput!.split(',').map((flavor) => flavor.trim()).toList();
    }

    //PACKAGES FOR SELECTED MODULES
    String modulesString = featureModules.join(', ');
    String? addPackages = Input.getValidatedInput(
      stdoutMessage: AppConstants.kAddPackages(modulesString),
      errorMessage: AppConstants.kInvalidYesOrNo,
      isPositiveResponse: true,
    );

    if (addPackages?.toLowerCase() == AppConstants.kYes) {
      isPackagesNeeded = true;
    }
    while (isPackagesNeeded) {
      stdout.write(AppConstants.kSelectModule(modulesString));
      String? selectedModule = stdin.readLineSync()?.trim().toLowerCase();
      switch (selectedModule) {
        case AppConstants.kCore:
        case AppConstants.kCoreUi:
        case AppConstants.kData:
        case AppConstants.kDomain:
        case AppConstants.kNavigation:
          stdout.write(AppConstants.kAddPackageSelectModule(selectedModule));
          String? packageInput = stdin.readLineSync()?.trim();
          List<String> selectedPackages = packageInput?.split(',') ?? [];
          selectedPackages = selectedPackages
              .map((package) => package.trim())
              .where((package) => Validator.kIsValidSingleString(package))
              .toList();
          packageModules.add(selectedModule!);
          packages[selectedModule] = selectedPackages;
          break;

        case AppConstants.kFeatures:
          stdout.write(AppConstants.kEnterFeatureForPackage);
          String? featureName = stdin.readLineSync()?.trim();
          if (Validator.kIsValidSingleString(featureName)) {
            stdout.write(AppConstants.kAddPackageFeatureModule(featureName));
            String? packageInput = stdin.readLineSync()?.trim();
            List<String> selectedPackages = packageInput?.split(',') ?? [];
            selectedPackages = selectedPackages
                .map((package) => package.trim())
                .where((package) => Validator.kIsValidSingleString(package))
                .toList();
            packageModules.add(featureName!);
            packages[featureName] = selectedPackages;
          } else {
            stdout.write(AppConstants.kInvalidFeatureForPackage);
          }
          break;
        default:
          stdout.write(AppConstants.kInvalidModuleName);
          break;
      }

      String? addMorePackages = Input.getValidatedInput(
        stdoutMessage: AppConstants.kAddPackageOtherModule,
        errorMessage: AppConstants.kInvalidYesOrNo,
        isPositiveResponse: true,
      );
      if (addMorePackages?.toLowerCase() == AppConstants.kNo) {
        isPackagesNeeded = false;
      }
    }

    //CREATE PROJECT WITH A GIVEN PATH AND PROJECT NAME
    ProcessResult result = Process.runSync(
      AppConstants.kFlutter,
      [
        AppConstants.kCreate,
        AppConstants.kNoPub,
        AppConstants.kOrg,
        AppConstants.kComExample,
        AppConstants.kProjectName,
        projectName!,
        '$path/$projectName',
      ],
    );

    if (result.exitCode != 0) {
      print(AppConstants.kFailCreateProject(result.stderr));
    }

    await FileService.appendToFile(
        AppConstants.kSdkFlutter,
        AppConstants.kMainPubspecDependencies,
        '$path/$projectName/pubspec.yaml');

    for (String module in mainModules) {
      final String modulePath = '$path/$projectName/$module';
      await DirectoryService.copy(
        sourcePath: '${AppConstants.kTemplates}/$module',
        destinationPath: modulePath,
      );
    }
    for (String module in mainModules) {
      final String modulePath = '$path/$projectName/$module';

      if (packages[module] != null) {
        await ScriptService.addPackagesToModules(
          module,
          packages[module]!,
          '$path/$projectName',
        );
      }
      await ScriptService.flutterClean(modulePath);
      await ScriptService.flutterPubGet(modulePath);
    }

    for (String feature in featureModules) {
      final String featureDestination =
          '$path/$projectName/${AppConstants.kFeatures}/$feature';
      await DirectoryService.copy(
        sourcePath: '${AppConstants.kTemplates}/${AppConstants.kFeature}',
        destinationPath: featureDestination,
        isFeature: true,
      );
      if (packages[feature] != null) {
        await ScriptService.addPackagesToModules(
          feature,
          packages[feature]!,
          '$path/$projectName/${AppConstants.kFeatures}',
        );
      }
      await ScriptService.flutterClean(featureDestination);
      await ScriptService.flutterPubGet(featureDestination);
    }

    DirectoryService.copy(
      sourcePath: '${AppConstants.kTemplates}/${AppConstants.kPrebuild}',
      destinationPath: '$path/$projectName/',
    );

    if (flavors.isNotEmpty) {
      final String libPath = '$path/$projectName/lib';
      final String appConfigPath =
          '$path/$projectName/${AppConstants.kAppConfigPath}';
      DirectoryService.deleteFile(
        directoryPath: libPath,
        fileName: 'main.dart',
      );

      for (final flavor in flavors) {
        if (flavor != 'dev') {
          await FileService.appendToFile(
            AppConstants.kFlavorEnum,
            '$flavor,',
            appConfigPath,
          );

          await FileService.appendToFile(
            AppConstants.kFlavorSwitch,
            AppConstants.kFlavorCase(flavor),
            appConfigPath,
          );
        }

        final String fileName = 'main_$flavor.dart';
        final File file = File('$libPath/$fileName');
        file.writeAsStringSync(
          AppConstants.kFlavourContent(projectName, flavor),
        );
      }

      final String fileName = 'main_common.dart';
      final File file = File('$libPath/$fileName');
      file.writeAsStringSync(AppConstants.kMainCommonContent);
    }

    DirectoryService.deleteFile(
      directoryPath: '$path/$projectName/test',
      fileName: 'widget_test.dart',
    );

    await ScriptService.flutterClean('$path/$projectName');
    await ScriptService.flutterPubGet('$path/$projectName');

    print(AppConstants.kCreateAppSuccess);
  }
}
