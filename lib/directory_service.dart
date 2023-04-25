import 'dart:io';

import 'app_constants.dart';
import 'file_service.dart';

class DirectoryService {
  static Future<void> copy({
    required String sourcePath,
    required String destinationPath,
    bool isFeature = false,
  }) async {
    final Directory sourceDirectory = Directory(sourcePath);
    if (!sourceDirectory.existsSync()) {
      stdout.write(AppConstants.kInvalidSourceFolder);
      return;
    }
    final Directory destinationDirectory = Directory(destinationPath);
    if (!destinationDirectory.existsSync()) {
      destinationDirectory.createSync(recursive: true);
    }
    final List<FileSystemEntity> entities = sourceDirectory.listSync();
    for (final FileSystemEntity entity in entities) {
      late String newPath;
      if (entity.uri.pathSegments.last.isEmpty) {
        newPath =
            '${destinationDirectory.path}/${entity.uri.pathSegments[entity.uri.pathSegments.length - 2]}';
      } else {
        newPath =
            '${destinationDirectory.path}/${entity.uri.pathSegments.last}';
      }
      if (entity is Directory) {
        final Directory newDirectory = Directory(newPath);
        newDirectory.createSync();
        await copy(sourcePath: entity.path, destinationPath: newDirectory.path);
      } else if (entity is File) {
        entity.copySync(newPath);
        if (isFeature) {
          final String featureName = destinationDirectory.path.split('/').last;
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
    final Directory directory = Directory(directoryPath);
    final File file = File('${directory.path}/$fileName');

    if (file.existsSync()) {
      file.deleteSync();

      if (deleteEmptyDir && directory.listSync().isEmpty) {
        directory.deleteSync();
      }
    }
  }
}
