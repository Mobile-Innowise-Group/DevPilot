import 'dart:io';

/// This class provides a set of static methods to validate different types of
/// input strings
class Validator {
  /// Regular expression for a string containing only alphabetical characters
  static RegExp fullStringRegex = RegExp(r'^[a-zA-Z]+$');

  /// Regular expression for a string in snake_case format
  /// (lowercase letters separated by underscores)
  static RegExp snakeCaseRegex = RegExp(r'^[a-z]+(_[a-z]+)*$');

  /// Returns true if the given project name is valid
  ///
  /// A valid project name is either a full string or a snake_case string
  /// If the [name] parameter is null, the method returns false
  static bool kIsValidProjectName(String? name) {
    return name == null
        ? false
        : (fullStringRegex.hasMatch(name) || snakeCaseRegex.hasMatch(name));
  }

  /// Returns true if the given path exists
  ///
  /// If the [path] parameter is null, the method returns false
  static bool kIsValidPath(String? path) {
    if (path == null) {
      return false;
    }

    final Directory directory = Directory(path);

    return directory.existsSync();
  }

  /// Returns true if the given input string is a comma-separated
  /// list of valid module names
  ///
  /// A valid module name is either a full string or a snake_case string
  /// If the [input] parameter is null or empty, the method returns false
  static bool kIsValidListString(String? input) {
    if (input == null || input.isEmpty) {
      return false;
    }

    final List<String> modules = input.split(',');

    for (final String module in modules) {
      if (!fullStringRegex.hasMatch(module.trim()) &&
          !snakeCaseRegex.hasMatch(module.trim())) {
        return false;
      }
    }

    return true;
  }

  /// Returns true if the given input string is a comma-separated
  /// list of valid flavor names
  ///
  /// A valid flavor name is a full string
  /// If the [input] parameter is null, the method returns false
  static bool kIsValidFlavorsInput(String? input) {
    if (input == null) {
      return false;
    }
    final List<String> flavors = input.split(',');

    for (final String flavor in flavors) {
      if (!fullStringRegex.hasMatch(flavor.trim())) {
        return false;
      }
    }

    return true;
  }

  /// Returns true if the given input string is a valid single module or flavor name
  ///
  /// A valid name is either a full string or a snake_case string
  /// If the [input] parameter is null or empty, the method returns false
  static bool kIsValidSingleString(String? input) {
    if (input == null || input.isEmpty) {
      return false;
    }

    return fullStringRegex.hasMatch(input.trim()) ||
        snakeCaseRegex.hasMatch(input.trim());
  }
}
