class ConverterService {
  static String snakeToPascalCase(String input) {
    return input
        .split('_')
        .map((String word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join();
  }

  /// Replaces backslashes with forward slashes and remove trailing slash if presented
  static String standardizeFilePath(String path) {
    final String fixed = path.replaceAll(RegExp(r'\\+'), '/');

    if (fixed.endsWith('/')) {
      return fixed.substring(0, fixed.length - 1);
    }

    return fixed;
  }
}
