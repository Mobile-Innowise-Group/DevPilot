import 'dart:io';

import 'package:innowise/app_constants.dart';
import 'package:innowise/validator.dart';

void main(List<String> arguments) {
  //PROJECT NAME
  stdout.write(AppConstants.kEnterProjectName);
  String? projectName = stdin.readLineSync()?.trim();

  while (!Validator.kIsValidProjectName(projectName)) {
    stdout.write(AppConstants.kEnterValidProjectName);
    projectName = stdin.readLineSync()?.trim();
  }

  //PATH

  stdout.write(AppConstants.kNeedSpecifyPath);
  String? specifyPath = stdin.readLineSync()?.trim();
  String? path = Directory.current.path;
  while (specifyPath != AppConstants.kYes && specifyPath != AppConstants.kNo) {
    stdout.write(AppConstants.kInvalidYesOrNo);
    specifyPath = stdin.readLineSync()?.trim();
  }

  if (specifyPath == AppConstants.kYes) {
    stdout.write(AppConstants.kEnterPath);
    path = stdin.readLineSync()?.trim();

    while (!Validator.kIsValidPath(path)) {
      stdout.write(AppConstants.kInvalidPath);
      path = stdin.readLineSync()?.trim();
    }
  }
  // FEATURE
  stdout.write(AppConstants.kAddFeature);
  String? addFeatures = stdin.readLineSync()?.trim().toLowerCase();
  List<String> modules = [];

  while (addFeatures != AppConstants.kYes && addFeatures != AppConstants.kNo) {
    stdout.write(AppConstants.kAddFeature);
    addFeatures = stdin.readLineSync()?.trim().toLowerCase();
  }

  if (addFeatures == AppConstants.kYes) {
    stdout.write(AppConstants.kEnterFeatures);
    String? featuresInput = stdin.readLineSync()?.trim();

    while (!Validator.kIsValidListString(featuresInput)) {
      stdout.write(AppConstants.kInvalidFeatureName);
      featuresInput = stdin.readLineSync()?.trim();
    }

    modules = featuresInput!.split(',').map((e) => e.trim()).toList();
  }

  //DIO
  stdout.write(AppConstants.kWillYouUseDio);
  String? dioInput = stdin.readLineSync()?.trim().toLowerCase();

  while (dioInput != AppConstants.kYes && dioInput != AppConstants.kNo) {
    stdout.write(AppConstants.kWillYouUseDio);
    dioInput = stdin.readLineSync()?.trim().toLowerCase();
  }
  bool isDioNeeded = dioInput == AppConstants.kYes;

  //FLAVORS
  stdout.write(AppConstants.kWillYouUseFlavours);
  String? flavorsInput = stdin.readLineSync()?.trim().toLowerCase();
  List<String> flavors = [];

  while (
      flavorsInput != AppConstants.kYes && flavorsInput != AppConstants.kNo) {
    stdout.write(AppConstants.kInvalidYesOrNo);
    flavorsInput = stdin.readLineSync()?.trim().toLowerCase();
  }
  bool isFlavorsNeeded = flavorsInput == AppConstants.kYes;

  if (isFlavorsNeeded) {
    stdout.write(AppConstants.kEnterFlavours);
    String? flavorsInput = stdin.readLineSync()?.trim();

    while (!Validator.kIsValidFlavorsInput(flavorsInput)) {
      stdout.write(AppConstants.kInvalidFlavours);
      flavorsInput = stdin.readLineSync()?.trim();
    }

    flavors = flavorsInput!.split(',').map((flavor) => flavor.trim()).toList();
  }

  //PACKAGES FOR SELECTED MODULES
  bool isPackagesNeeded = false;
  List<String> packageModules = [];
  Map<String, List<String>> packages = {};
  String modulesString = modules.join(', ');
  stdout.write(AppConstants.kAddPackages(modulesString));
  String? addPackages = stdin.readLineSync()?.trim();
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

    stdout.write(AppConstants.kAddPackageOtherModule);
    String? addMorePackages = stdin.readLineSync()?.trim();
    if (addMorePackages?.toLowerCase() != AppConstants.kYes) {
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

  for (String module in modules) {
    result = Process.runSync(
      AppConstants.kFlutter,
      [
        AppConstants.kCreate,
        AppConstants.kTemplate,
        AppConstants.kPackage,
        '$path/$projectName/$module',
      ],
    );

    // Print the output of the Flutter create command
    print(result.stdout);

    // Print an error message if the Flutter create command failed
    if (result.exitCode != 0) {
      print(AppConstants.kFailCreateModule(module, result.stderr));
      return;
    }
  }

  print(AppConstants.kCreateModulesSuccess);
}
