class AppConstants {
  //STRING CONSTANTS
  static const String kEnterProjectName = 'Enter a project name: ';
  static const String kEnterValidProjectName =
      'Please enter a valid project name (full string or snake case string): ';
  static const String kEnterPath =
      'Please specify the path where you want to create the project: ';
  static const String kInvalidPath =
      'Invalid path. Please specify a valid path: ';
  static const String kAddFeature = 'Do you want add features now? (Yes/No): ';
  static const String kYes = 'yes';
  static const String kNo = 'no';
  static const String kInvalidYesOrNo =
      'Invalid input. Please enter "yes" or "no": ';
  static const String kEnterFeatures =
      'Please enter all required feature modules separated by commas (Please Note that line can\'t endup with comma): ';
  static const String kInvalidFeatureName =
      'Invalid feature modules input. Please enter full string or snake case strings separated by commas (Please Note that line can\'t endup with comma): ';
  static const String kWillYouUseDio =
      'Will you use Dio in your project? (yes/no) ';
  static const String kWillYouUseFlavours =
      'Will you use flavors in your project? (yes/no) ';
  static const String kEnterFlavours =
      'Please enter the flavors separated by commas (dev, stage, prod etc... Please Note that line can\'t endup with comma): ';
  static const String kInvalidFlavours =
      'Invalid input. Please enter only full strings separated by commas (Please Note that line can\'t endup with comma): ';

  static String kAddPackages(String modulesString) {
    return 'Do you want to add any packages to any of the following modules (core, core_ui, data, domain, features, $modulesString navigation)? (yes/no): ';
  }

  static String kSelectModule(String modulesString) {
    return 'Please select a module from the following list to add packages to (core, core_ui, data, domain, features, $modulesString navigation) (Please Note that line can\'t endup with comma): ';
  }

  static String kAddPackageSelectModule(String? selectedModule) {
    return 'Please enter the packages you want to add to ${selectedModule ?? ''} module (comma-separated Please Note that line can\'t endup with comma): ';
  }

  static String kAddPackageFeatureModule(String? featureName) {
    return 'Please enter the packages you want to add to the $featureName feature (comma-separated Please Note that line can\'t endup with comma): ';
  }

  static const String kEnterFeatureForPackage =
      'Please enter the feature name for which you want to add packages: ';
  static const String kInvalidFeatureForPackage =
      'Invalid feature name entered. Please try again.\n';
  static const String kInvalidModuleName =
      'Invalid module name entered. Please try again.\n';
  static const String kAddPackageOtherModule =
      'Do you want to add packages to any other module? (yes/no): ';

  static const String kCore = 'core';
  static const String kCoreUi = 'core_ui';
  static const String kData = 'data';
  static const String kDomain = 'domain';
  static const String kFeatures = 'features';
  static const String kNavigation = 'navigation';
}
