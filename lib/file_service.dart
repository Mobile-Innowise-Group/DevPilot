import 'dart:io';

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
      throw Exception('Could not find the old string in the file');
    }
    final newContent = content.replaceRange(oldIndex + oldString.length,
        oldIndex + oldString.length, '\n$newString');
    await file.writeAsString(newContent);
  }
}
