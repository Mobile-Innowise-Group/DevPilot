import 'dart:io';

import 'package:dcli/dcli.dart';

import 'app_constants.dart';
import 'file_service.dart';

/// This class provides functions to copy directories and delete files.
class DirectoryService {
  /// Copies a directory from the source path to the destination path.
  ///
  /// [sourcePath] is the path of the directory to be copied.
  /// [destinationPath] is the path of the directory where the contents will
  /// be copied.
  /// [isFeature] is a boolean flag indicating whether the directory being
  /// copied is a feature directory.
  ///
  /// If the source directory does not exist, an error message will be printed
  /// to the console and the function will return.
  ///
  /// If the destination directory does not exist, it will be created recursively.
  ///
  /// The function will copy all files and subdirectories in the source
  /// directory to the destination directory. If [isFeature] is `true`,
  /// it will also update the contents of any copied files.
  ///
  /// Throws an exception if there is an error copying any files or directories.
  static Future<void> copy({
    required String sourcePath,
    required String destinationPath,
    bool isFeature = false,
  }) async {
    final Directory sourceDirectory = Directory(sourcePath);
    if (!sourceDirectory.existsSync()) {
      stdout.writeln(red(AppConstants.kInvalidSourceFolder));
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

  /// Deletes a file with the given [fileName] in the directory at [directoryPath].
  ///
  /// If the file does not exist, this function does nothing.
  ///
  /// If [deleteEmptyDir] is `true` and the directory is empty after deleting
  /// the file, the directory will be deleted.
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
