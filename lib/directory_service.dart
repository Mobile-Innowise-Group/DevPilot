import 'dart:io';

class DirectoryService {
  static void copyDirectory(String sourcePath, String destinationPath) {
    Directory sourceDirectory = Directory(sourcePath);
    if (!sourceDirectory.existsSync()) {
      print('Source folder does not exist');
      return;
    }
    Directory destinationDirectory = Directory(destinationPath);
    if (!destinationDirectory.existsSync()) {
      destinationDirectory.createSync(recursive: true);
    }
    List<FileSystemEntity> entities = sourceDirectory.listSync();
    for (FileSystemEntity entity in entities) {
      late String newPath;
      if (entity.uri.pathSegments.last.isEmpty) {
        newPath =
            '${destinationDirectory.path}/${entity.uri.pathSegments[entity.uri.pathSegments.length - 2]}';
      } else {
        newPath =
            '${destinationDirectory.path}/${entity.uri.pathSegments.last}';
      }
      if (entity is Directory) {
        Directory newDirectory = Directory(newPath);
        newDirectory.createSync();
        copyDirectory(entity.path, newDirectory.path);
      } else if (entity is File) {
        entity.copySync(newPath);
      }
    }
  }
}
