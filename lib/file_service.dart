import 'dart:io';

import 'package:dcli/dcli.dart';

class FileService {
  static Future<void> updateFileContent({
    required String oldString,
    required String newString,
    required String filePath,
  }) async {
    final file = File(filePath);
    String content = await file.readAsString();
    content = content.replaceAll(oldString, newString);
    await file.writeAsString(content);
  }

  static Future<void> appendToFile(
      String oldString, String newString, String filePath) async {
    final file = File(filePath);
    String content = await file.readAsString();
    final oldIndex = content.indexOf(oldString);
    if (oldIndex == -1) {
      throw Exception(red('❌ Could not find the old string in the file'));
    }
    final newContent = content.replaceRange(oldIndex + oldString.length,
        oldIndex + oldString.length, '\n$newString');
    await file.writeAsString(newContent);
  }

  static Future<void> runScript(String scriptName, String directoryPath) async {
    final scriptPath = '$directoryPath/$scriptName';
    final process = await Process.run(
      'sh',
      [scriptPath],
      workingDirectory: directoryPath,
    );

    if (process.exitCode != 0) {
      print(red('❌ Error running script: ${process.stderr}'));
    } else {
      print(green('✅ Script output: ${process.stdout}'));
    }
  }

}
