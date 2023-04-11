import 'dart:io';

import 'package:innowise/app_constants.dart';
import 'package:innowise/validator.dart';

void main(List<String> arguments) {
  stdout.write(AppConstants.kEnterProjectName);
  String? projectName = stdin.readLineSync()?.trim();

  while (!Validator.kIsValidProjectName(projectName)) {
    stdout.write(AppConstants.kEnterValidProjectName);
    projectName = stdin.readLineSync()?.trim();
  }
  stdout.write(AppConstants.kEnterPath);
  String? path = stdin.readLineSync()?.trim();

  while (!Validator.kIsValidPath(path)) {
    stdout.write(AppConstants.kInvalidPath);
    path = stdin.readLineSync()?.trim();
  }
  stdout.write(AppConstants.kAddFeature);
  String? addFeatures = stdin.readLineSync()?.trim().toLowerCase();

  List<String> modules = [];

  if (addFeatures == AppConstants.kYes) {
    stdout.write(AppConstants.kEnterFeatures);
    String? featuresInput = stdin.readLineSync()?.trim();

    while (!Validator.kIsValidListString(featuresInput)) {
      stdout.write(AppConstants.kInvalidFeatureName);
      featuresInput = stdin.readLineSync()?.trim();
    }

    modules = featuresInput!.split(',').map((e) => e.trim()).toList();
  }

  stdout.write(AppConstants.kWillYouUseDio);
  String? dioInput = stdin.readLineSync()?.trim().toLowerCase();

  while (dioInput != AppConstants.kYes && dioInput != AppConstants.kNo) {
    stdout.write(AppConstants.kWillYouUseDio);
    dioInput = stdin.readLineSync()?.trim().toLowerCase();
  }

  bool isDioNeeded = dioInput == AppConstants.kYes;

  stdout.write(AppConstants.kWillYouUseFlavours);
  String? flavorsInput = stdin.readLineSync()?.trim().toLowerCase();

  while (
      flavorsInput != AppConstants.kYes && flavorsInput != AppConstants.kNo) {
    stdout.write(AppConstants.kInvalidYesOrNo);
    flavorsInput = stdin.readLineSync()?.trim().toLowerCase();
  }

  bool isFlavorsNeeded = flavorsInput == AppConstants.kYes;

  List<String> flavors = [];
  if (isFlavorsNeeded) {
    stdout.write(AppConstants.kEnterFlavours);
    String? flavorsInput = stdin.readLineSync()?.trim();

    while (!Validator.kIsValidFlavorsInput(flavorsInput)) {
      stdout.write(AppConstants.kInvalidFlavours);
      flavorsInput = stdin.readLineSync()?.trim();
    }

    flavors = flavorsInput!.split(',').map((flavor) => flavor.trim()).toList();
  }

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

  ProcessResult result = Process.runSync(
    'flutter',
    [
      'create',
      '--no-pub',
      '--org',
      'com.example',
      '--project-name',
      projectName!,
      path!
    ],
  );

  if (result.exitCode != 0) {
    print('Failed to create Flutter project: ${result.stderr}');
  }
}
