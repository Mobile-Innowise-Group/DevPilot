import 'dart:io';

import 'package:dcli/dcli.dart' as dcli;
import 'package:dev_pilot/app_constants.dart';
import 'package:dev_pilot/directory_service.dart';
import 'package:dev_pilot/file_service.dart';
import 'package:dev_pilot/input.dart';
import 'package:dev_pilot/script_service.dart';
import 'package:dev_pilot/validator.dart';
import 'package:mason_logger/mason_logger.dart' as mason;

void main(List<String> arguments) async {
  if (arguments.contains('create')) {
    stdout.write(dcli.red(AppConstants.kLogo));
    if (!await ScriptService.isDartVersionInRange('2.19.5', '3.0.0')) {
      stdout.write(dcli.red(AppConstants.kUpdateDartVersion));
      return;
    }
    final mason.Logger logger = mason.Logger();
    String? path = AppConstants.kCurrentPath;
    List<String> featureModules = <String>[];
    List<String> flavors = <String>[];
    bool isPackagesNeeded = false;
    final List<String> packageModules = <String>[];
    final Map<String, List<String>> packages = <String, List<String>>{};

    final List<String> mainModules = <String>[
      AppConstants.kCore,
      AppConstants.kCoreUi,
      AppConstants.kData,
      AppConstants.kDomain,
      AppConstants.kNavigation,
    ];

    //PROJECT NAME
    final String? projectName = Input.getValidatedInput(
      stdoutMessage: AppConstants.kEnterProjectName,
      errorMessage: AppConstants.kEnterValidProjectName,
      functionValidator: Validator.kIsValidProjectName,
    );

    //PATH
    final String? specifyPath = logger.chooseOne(
      AppConstants.kNeedSpecifyPath,
      choices: <String?>[
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
    final String? addFeatures = logger.chooseOne(
      AppConstants.kAddFeature,
      choices: <String?>[
        AppConstants.kYes,
        AppConstants.kNo,
      ],
    );

    if (addFeatures == AppConstants.kYes) {
      final String? featuresInput = Input.getValidatedInput(
        stdoutMessage: AppConstants.kEnterFeatures,
        errorMessage: AppConstants.kInvalidFeatureName,
        functionValidator: Validator.kIsValidListString,
      );
      featureModules = featuresInput!.split(',').map((String e) => e.trim()).toList();
    }

    //FLAVORS
    final String? flavorsInput = logger.chooseOne(
      AppConstants.kWillYouUseFlavours,
      choices: <String?>[
        AppConstants.kYes,
        AppConstants.kNo,
      ],
    );

    final bool isFlavorsNeeded = flavorsInput == AppConstants.kYes;

    if (isFlavorsNeeded) {
      final String? flavorsInput = Input.getValidatedInput(
        stdoutMessage: AppConstants.kEnterFlavours,
        errorMessage: AppConstants.kInvalidFlavours,
        functionValidator: Validator.kIsValidFlavorsInput,
      );
      flavors =
          flavorsInput!.split(',').map((String flavor) => flavor.trim()).toList();
    }

    //PACKAGES FOR SELECTED MODULES
    final String modulesString = featureModules.join(', ');

    final String? addPackages = logger.chooseOne(
      AppConstants.kAddPackages(modulesString),
      choices: <String?>[
        AppConstants.kYes,
        AppConstants.kNo,
      ],
    );

    if (addPackages?.toLowerCase() == AppConstants.kYes) {
      isPackagesNeeded = true;
    }
    while (isPackagesNeeded) {
      final String? selectedModule = logger.chooseOne(
        AppConstants.kSelectModule(modulesString),
        choices: <String?>[...mainModules, ...featureModules],
      );

      final String? packageInput = Input.getValidatedInput(
          stdoutMessage: AppConstants.kAddPackageSelectModule(selectedModule),
          errorMessage: AppConstants.kInvalidPackage,
          functionValidator: Validator.kIsValidListString);

      List<String> selectedPackages = packageInput?.split(',') ?? <String>[];
      selectedPackages = selectedPackages
          .map((String package) => package.trim())
          .where(Validator.kIsValidSingleString)
          .toList();
      packageModules.add(selectedModule!);
      packages[selectedModule] = selectedPackages;
      final String? addMorePackages = logger.chooseOne(
        AppConstants.kAddPackageOtherModule,
        choices: <String?>[
          AppConstants.kYes,
          AppConstants.kNo,
        ],
      );

      if (addMorePackages?.toLowerCase() == AppConstants.kNo) {
        isPackagesNeeded = false;
      }
    }

    //CREATE PROJECT WITH A GIVEN PATH AND PROJECT NAME
    final ProcessResult result = Process.runSync(
      AppConstants.kFlutter,
      <String>[
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
      stdout.write(AppConstants.kFailCreateProject(result.stderr));
    }

    await FileService.appendToFile(
        AppConstants.kSdkFlutter,
        AppConstants.kMainPubspecDependencies,
        '$path/$projectName/pubspec.yaml');

    for (final String module in mainModules) {
      final String modulePath = '$path/$projectName/$module';
      await DirectoryService.copy(
        sourcePath: '${AppConstants.kTemplates}/$module',
        destinationPath: modulePath,
      );
    }
    for (final String module in mainModules) {
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

    for (final String feature in featureModules) {
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

    await DirectoryService.copy(
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

      for (final String flavor in flavors) {
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

      const String fileName = 'main_common.dart';
      final File file = File('$libPath/$fileName');
      file.writeAsStringSync(AppConstants.kMainCommonContent);
    }

    DirectoryService.deleteFile(
      directoryPath: '$path/$projectName/test',
      fileName: 'widget_test.dart',
    );

    await ScriptService.flutterClean('$path/$projectName');
    await ScriptService.flutterPubGet('$path/$projectName');

    stdout.write(dcli.green('✅  ${AppConstants.kCreateAppSuccess}'));
  } else {
    stdout.writeln(dcli.red('Undefined Command'));
  }
}
