import 'dart:io';

import 'package:dcli/dcli.dart';

class FileService {
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

  static String? removeTrailingComma(String? input) {
    if(input != null){
      if (input.endsWith(',')) {
        return input.substring(0, input.length - 1);
      } else {
        return input;
      }
    }
    return null;
  }

}
