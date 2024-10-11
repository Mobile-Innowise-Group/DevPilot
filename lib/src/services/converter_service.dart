class ConverterService {
  static String snakeToPascalCase(String input) {
    return input
        .split('_')
        .map((String word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join();
  }
}
