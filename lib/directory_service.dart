import 'dart:io';

import 'package:dev_pilot/app_constants.dart';
import 'package:dev_pilot/file_service.dart';

class DirectoryService {
  static Future<void> copy({
    required String sourcePath,
    required String destinationPath,
    bool isFeature = false,
  }) async {
    Directory sourceDirectory = Directory(sourcePath);
    if (!sourceDirectory.existsSync()) {
      print(AppConstants.kInvalidSourceFolder);
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
        copy(sourcePath: entity.path, destinationPath: newDirectory.path);
      } else if (entity is File) {
        entity.copySync(newPath);
        if (isFeature) {
          String featureName = destinationDirectory.path.split('/').last;
          await FileService.updateFileContent(
            oldString: AppConstants.kFeaturePlug,
            newString: AppConstants.kFeaturePlugReplaceWith(featureName),
            filePath: newPath,
          );
        }
      }
    }
  }

  static void deleteFile({
    required String directoryPath,
    required String fileName,
    bool deleteEmptyDir = false,
  }) {
    final directory = Directory(directoryPath);
    final file = File('${directory.path}/$fileName');

    if (file.existsSync()) {
      file.deleteSync();

      if (deleteEmptyDir && directory.listSync().isEmpty) {
        directory.deleteSync();
      }
    }
  }
}
