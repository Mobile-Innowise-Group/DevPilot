import 'dart:io';

import 'package:innowise/app_constants.dart';
import 'package:innowise/directory_service.dart';
import 'package:innowise/file_service.dart';
import 'package:innowise/input.dart';
import 'package:innowise/script_service.dart';
import 'package:innowise/validator.dart';
import 'package:mason_logger/mason_logger.dart' as mason;
import 'package:dcli/dcli.dart' as dcli;

void main(List<String> arguments) async {
  if (arguments.contains('create')) {
  print(dcli.red(AppConstants.kLogo));
    if (! await ScriptService.isDartVersionInRange('2.19.5', '3.0.0')) {
      print(dcli.red(AppConstants.kUpdateDartVersion));
      return;
    }
    final mason.Logger logger = mason.Logger();
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
    String? specifyPath = logger.chooseOne(
      AppConstants.kNeedSpecifyPath,
      choices: [
        AppConstants.kYes,
        AppConstants.kNo,
      ],
    );

    if (specifyPath == AppConstants.kYes) {
      path = Input.getValidatedInput(
        stdoutMessage: AppConstants.kEnterPath,
        errorMessage: AppConstants.kInvalidPath,
        functionValidator: Validator.kIsValidPath,
      );
    }
    // FEATURE
    String? addFeatures = logger.chooseOne(
      AppConstants.kAddFeature,
      choices: [
        AppConstants.kYes,
        AppConstants.kNo,
      ],
    );

    if (addFeatures == AppConstants.kYes) {
      String? featuresInput = Input.getValidatedInput(
        stdoutMessage: AppConstants.kEnterFeatures,
        errorMessage: AppConstants.kInvalidFeatureName,
        functionValidator: Validator.kIsValidListString,
      );
      featureModules = featuresInput!.split(',').map((e) => e.trim()).toList();
    }

    //FLAVORS
    String? flavorsInput = logger.chooseOne(
      AppConstants.kWillYouUseFlavours,
      choices: [
        AppConstants.kYes,
        AppConstants.kNo,
      ],
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

    String? addPackages = logger.chooseOne(
      AppConstants.kAddPackages(modulesString),
      choices: [
        AppConstants.kYes,
        AppConstants.kNo,
      ],
    );

    if (addPackages?.toLowerCase() == AppConstants.kYes) {
      isPackagesNeeded = true;
    }
    while (isPackagesNeeded) {
      String? selectedModule = logger.chooseOne(
        AppConstants.kSelectModule(modulesString),
        choices: [...mainModules, ...featureModules],
      );

      String? packageInput = Input.getValidatedInput(
        stdoutMessage: AppConstants.kAddPackageSelectModule(selectedModule),
        errorMessage: AppConstants.kInvalidPackage,
        functionValidator: Validator.kIsValidListString
      );

      List<String> selectedPackages = packageInput?.split(',') ?? [];
      selectedPackages = selectedPackages
          .map((package) => package.trim())
          .where((package) => Validator.kIsValidSingleString(package))
          .toList();
      packageModules.add(selectedModule!);
      packages[selectedModule] = selectedPackages;
      String? addMorePackages = logger.chooseOne(
        AppConstants.kAddPackageOtherModule,
        choices: [
          AppConstants.kYes,
          AppConstants.kNo,
        ],
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

    print(dcli.green('✅  ${AppConstants.kCreateAppSuccess}'));
  } else {
    stdout.writeln(dcli.red('Undefined Command'));
  }
}

