import 'dart:io';

import 'package:dcli/dcli.dart';

/// This class provides functions to update file content, append to files,
/// and remove trailing commas.
class FileService {
  /// Updates the contents of the file at the given [filePath] by replacing
  /// all occurrences of [oldString] with [newString].
  ///
  /// Throws an exception if the file cannot be read or written to.
  static Future<void> updateFileContent({
    required String oldString,
    required String newString,
    required String filePath,
  }) async {
    final File file = File(filePath);
    String content = await file.readAsString();
    content = content.replaceAll(oldString, newString);
    await file.writeAsString(content);
  }

  /// Appends [newString] to the file at the given [filePath] after the
  /// first occurrence of [oldString].
  ///
  /// Throws an exception if the file cannot be read or written to, or if
  /// [oldString] is not found in the file.
  static Future<void> appendToFile(
      String oldString, String newString, String filePath) async {
    final File file = File(filePath);
    final String content = await file.readAsString();
    final int oldIndex = content.indexOf(oldString);
    if (oldIndex == -1) {
      throw Exception(red('❌ Could not find the old string in the file'));
    }
    final String newContent = content.replaceRange(oldIndex + oldString.length,
        oldIndex + oldString.length, '\n$newString');
    await file.writeAsString(newContent);
  }

  /// Removes the trailing comma from the given [input] string, if present.
  ///
  /// Returns the modified string or null if [input] is null.
  static String? removeTrailingComma(String? input) {
    if (input != null) {
      if (input.endsWith(',')) {
        return input.substring(0, input.length - 1);
      } else {
        return input;
      }
    }
    return null;
  }

  /// Rewrite the contents of the file at the given [filePath] by replacing
  /// all occurrences with [newString].
  ///
  /// Throws an exception if the file cannot be read or written to.
  static Future<void> rewriteFileContent({
    required String newString,
    required String filePath,
  }) async {
    final File file = File(filePath);
    await file.writeAsString('', flush: true);
    await file.writeAsString(newString);
  }
}
