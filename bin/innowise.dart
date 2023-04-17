import 'dart:io';

import 'package:innowise/app_constants.dart';
import 'package:innowise/directory_service.dart';
import 'package:innowise/input.dart';
import 'package:innowise/validator.dart';

void main(List<String> arguments) {
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
  String? dioInput = Input.getValidatedInput(
    stdoutMessage: AppConstants.kWillYouUseDio,
    errorMessage: AppConstants.kWillYouUseDio,
    isPositiveResponse: true,
  );

  bool isDioNeeded = dioInput == AppConstants.kYes;

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
    flavors = flavorsInput!.split(',').map((flavor) => flavor.trim()).toList();
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

  for (String module in mainModules) {
    DirectoryService.copy(
      sourcePath: '${AppConstants.kTemplates}/$module',
      destinationPath: '$path/$projectName/$module',
    );
  }

  for (String feature in featureModules) {
    DirectoryService.copy(
      sourcePath: '${AppConstants.kTemplates}/${AppConstants.kFeature}',
      destinationPath: '$path/$projectName/${AppConstants.kFeatures}/$feature',
      isFeature: true,
    );
  }

  DirectoryService.copy(
    sourcePath: '${AppConstants.kTemplates}/${AppConstants.kPrebuild}',
    destinationPath: '$path/$projectName/',
  );

  print(AppConstants.kCreateAppSuccess);
}
