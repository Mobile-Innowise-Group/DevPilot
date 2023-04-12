import 'dart:io';

class Validator {
  static RegExp fullStringRegex = RegExp(r'^[a-zA-Z]+$');
  static RegExp snakeCaseRegex = RegExp(r'^[a-z]+(_[a-z]+)*$');

  static bool kIsValidProjectName(String? name) {
    return name == null
        ? false
        : (fullStringRegex.hasMatch(name) || snakeCaseRegex.hasMatch(name));
  }

  static bool kIsValidPath(String? path) {
    if (path == null) {
      return false;
    }

    final Directory directory = Directory(path);

    return directory.existsSync();
  }

  static bool kIsValidListString(String? input) {
    if (input == null || input.isEmpty) {
      return false;
    }

    List<String> modules = input.split(',');

    for (String module in modules) {
      if (!fullStringRegex.hasMatch(module.trim()) &&
          !snakeCaseRegex.hasMatch(module.trim())) {
        return false;
      }
    }

    return true;
  }

  static bool kIsValidFlavorsInput(String? input) {
    if (input == null) {
      return false;
    }
    final List<String> flavors = input.split(',');

    for (String flavor in flavors) {
      if (!fullStringRegex.hasMatch(flavor.trim())) {
        return false;
      }
    }

    return true;
  }

  static bool kIsValidSingleString(String? input) {
    if (input == null || input.isEmpty) {
      return false;
    }

    return fullStringRegex.hasMatch(input.trim()) ||
        snakeCaseRegex.hasMatch(input.trim());
  }
}
