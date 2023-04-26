// Import required libraries and packages
import 'dart:io';

import 'package:dcli/dcli.dart' as dcli;
import 'package:dev_pilot/src/constants/app_constants.dart';
import 'package:dev_pilot/src/services/directory_service.dart';
import 'package:dev_pilot/src/services/file_service.dart';
import 'package:dev_pilot/src/services/input_service.dart';
import 'package:dev_pilot/src/services/script_service.dart';
import 'package:dev_pilot/src/validators/validator.dart';
import 'package:mason_logger/mason_logger.dart' as mason;

// Main method
void main(List<String> arguments) async {
  // Check if the argument is create
  if (arguments.contains('create')) {
    // Display the logo

    stdout.write(dcli.red(AppConstants.kLogo));

    // Check if the Dart version is in the correct range
    if (!await ScriptService.isDartVersionInRange('2.19.5', '3.0.0')) {
      stdout.writeln(dcli.red(AppConstants.kUpdateDartVersion));
      return;
    }

    // Create a new logger
    final mason.Logger logger = mason.Logger();

    // Initialize the variables with default values
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

    // Get project name from user input
    final String? projectName = InputService.getValidatedInput(
      stdoutMessage: AppConstants.kEnterProjectName,
      errorMessage: AppConstants.kEnterValidProjectName,
      functionValidator: Validator.kIsValidProjectName,
    );

    // Ask user if  want to specify a path
    final String? specifyPath = logger.chooseOne(
      AppConstants.kNeedSpecifyPath,
      choices: <String?>[
        AppConstants.kYes,
        AppConstants.kNo,
      ],
    );

    // If user selects to specify a path, get the path from user input
    if (specifyPath == AppConstants.kYes) {
      path = InputService.getValidatedInput(
        stdoutMessage: AppConstants.kEnterPath,
        errorMessage: AppConstants.kInvalidPath,
        functionValidator: Validator.kIsValidPath,
      );
    }

    // Ask user if  want to add feature modules
    final String? addFeatures = logger.chooseOne(
      AppConstants.kAddFeature,
      choices: <String?>[
        AppConstants.kYes,
        AppConstants.kNo,
      ],
    );

    // If user selects to add feature modules,
    // get the feature module names from user input
    if (addFeatures == AppConstants.kYes) {
      final String? featuresInput = InputService.getValidatedInput(
        stdoutMessage: AppConstants.kEnterFeatures,
        errorMessage: AppConstants.kInvalidFeatureName,
        functionValidator: Validator.kIsValidListString,
      );
      featureModules =
          featuresInput!.split(',').map((String e) => e.trim()).toList();
    }

    // Ask user if  want to add flavors
    final String? flavorsInput = logger.chooseOne(
      AppConstants.kWillYouUseFlavours,
      choices: <String?>[
        AppConstants.kYes,
        AppConstants.kNo,
      ],
    );

    final bool isFlavorsNeeded = flavorsInput == AppConstants.kYes;

    // If user selects to add flavors, get the flavor names from user input
    if (isFlavorsNeeded) {
      final String? flavorsInput = InputService.getValidatedInput(
        stdoutMessage: AppConstants.kEnterFlavours,
        errorMessage: AppConstants.kInvalidFlavours,
        functionValidator: Validator.kIsValidFlavorsInput,
      );
      flavors = flavorsInput!
          .split(',')
          .map((String flavor) => flavor.trim())
          .toList();
    }

    //Convert specified features List<Strings>
    //to a single String
    final String modulesString = featureModules.join(', ');

    // Ask user if  want to add package to specified module
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

    // If user selects to add packages, get the package names from user input
    // and so on while user selects "no"
    while (isPackagesNeeded) {
      final String? selectedModule = logger.chooseOne(
        AppConstants.kSelectModule(modulesString),
        choices: <String?>[...mainModules, ...featureModules],
      );

      final String? packageInput = InputService.getValidatedInput(
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

    //Create project with a given name
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
      stdout.writeln(dcli.red(AppConstants.kFailCreateProject(result.stderr)));
    }

    //Add dependencies to main pubspec.yaml
    await FileService.appendToFile(
        AppConstants.kSdkFlutter,
        AppConstants.kMainPubspecDependencies,
        '$path/$projectName/pubspec.yaml');

    ///Copy files & folders from local [templates] folder
    ///to the newly created project
    for (final String module in mainModules) {
      final String modulePath = '$path/$projectName/$module';
      await DirectoryService.copy(
        sourcePath: '${AppConstants.kTemplates}/$module',
        destinationPath: modulePath,
      );
    }

    /// If user specified [packages]
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

    //Copy feature folder & pubspec.yaml
    // from local templates folder to a given path
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


    //Copy prebuild.sh from local templates folder to the root of new
    //Flutter project
    await DirectoryService.copy(
      sourcePath: '${AppConstants.kTemplates}/${AppConstants.kPrebuild}',
      destinationPath: '$path/$projectName/',
    );

    //If user specified flavors above so create new files and add
    // new flavors to enum according specified flavors list
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


    //Delete test file as don't need one for the moment
    DirectoryService.deleteFile(
      directoryPath: '$path/$projectName/test',
      fileName: 'widget_test.dart',
    );

    //Clean and pub get ready project
    await ScriptService.flutterClean('$path/$projectName');
    await ScriptService.flutterPubGet('$path/$projectName');
  } else {
    stdout.writeln(dcli.red('Undefined Command'));
  }
}
