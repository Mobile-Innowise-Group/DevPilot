import 'dart:io';

import 'package:dcli/dcli.dart';

/// This class provides a set of utility functions for working with scripts
/// in a Flutter project.
class ScriptService {
  /// Runs `flutter clean` for a specific module.
  ///
  /// [modulePath] is the path to the module to clean.
  ///
  /// If the command is successful, a success message is printed to the console.
  /// If the command fails, an error message is printed to the console.
  static Future<void> flutterClean(String modulePath) async {
    final ProcessResult cleanProcess = await Process.run(
      'flutter',
      <String>['clean'],
      workingDirectory: modulePath,
    );
    if (cleanProcess.exitCode != 0) {
      stdout.writeln(red(
          '❌  Error running flutter clean for $modulePath: ${cleanProcess.stderr}'));
    } else {
      stdout
          .writeln(green('✅  Successfully ran flutter clean for $modulePath'));
    }
  }

  /// Runs `flutter pub get` for a specific module.
  ///
  /// [modulePath] is the path to the module to get packages for.
  ///
  /// If the command is successful, a success message is printed to the console.
  /// If the command fails, an error message is printed to the console.
  static Future<void> flutterPubGet(String modulePath) async {
    final ProcessResult pubGetProcess = await Process.run(
        'flutter', <String>['pub', 'get'],
        workingDirectory: modulePath);
    if (pubGetProcess.exitCode != 0) {
      stdout.writeln(red(
          '❌  Error running flutter pub get for $modulePath : ${pubGetProcess.stderr}'));
    } else {
      stdout.writeln(
          green('✅  Successfully ran flutter pub get for $modulePath'));
    }
  }

  /// Adds packages to a specific module.
  ///
  /// [moduleName] is the name of the module to add packages to.
  /// [packages] is a list of package names to add.
  /// [workingDirectory] is the path to the working directory containing the module.
  ///
  /// If the command is successful, a success message is printed to the console.
  /// If the command fails, an error message is printed to the console.
  static Future<void> addPackagesToModules(
    String moduleName,
    List<String> packages,
    String workingDirectory,
  ) async {
    final String modulePath = '$workingDirectory/$moduleName';
    final List<String> packageArgs = <String>['pub', 'add', ...packages];

    final ProcessResult processResult = await Process.run(
      'flutter',
      packageArgs,
      workingDirectory: modulePath,
    );
    if (processResult.exitCode == 0) {
      stdout.writeln(green('✅  Packages added to module $moduleName'));
    } else {
      stdout.writeln(
        red('❌ Failed to add packages to module $moduleName: ${processResult.stderr}'),
      );
    }
  }

  /// Runs a shell script with a given name and path.
  ///
  /// [scriptName] is the name of the script to run.
  /// [directoryPath] is the path to the directory containing the script.
  ///
  /// If the command is successful, a success message is printed to the console.
  /// If the command fails, an error message is printed to the console.
  static Future<void> runScript(String scriptName, String directoryPath) async {
    final String scriptPath = '$directoryPath/$scriptName';
    final ProcessResult process = await Process.run(
      'sh',
      <String>[scriptPath],
      workingDirectory: directoryPath,
    );

    if (process.exitCode != 0) {
      stdout.writeln(red('❌ Error running script: ${process.stderr}'));
    } else {
      stdout.writeln(green('✅ Script output: ${process.stdout}'));
    }
  }

  /// This function takes a nullable integer and returns its value multiplied
  /// by 10 if the value is less than 1000, otherwise it returns the original value.
  /// If the input is null, it returns null as well.
  ///
  /// @param number A nullable integer that needs to be converted to thousands.
  /// @return An integer that represents the converted value or null if the input is null.

  static int? convertToThousands(int? number) {
    if (number != null) {
      if (number < 1000) {
        return number * 10;
      } else {
        return number;
      }
    }
    return null;
  }

  /// This function takes two string arguments, `minVersion` and `maxVersion`,
  /// which represent the minimum and maximum versions of Dart allowed.
  /// It then checks if the version of Dart installed on the machine falls
  /// within this range.
  ///
  /// [minVersion] A string that represents the minimum version of Dart allowed.
  /// [maxVersion] A string that represents the maximum version of Dart allowed.
  /// return A Future<bool> that is true if the installed version of Dart
  /// is within the allowed range and false otherwise.
  static Future<bool> isDartVersionInRange(
      String minVersion, String maxVersion) async {
    final ProcessResult processResult =
        await Process.run('dart', <String>['--version']);
    final String versionOutput = processResult.stdout.toString().trim();
    final RegExpMatch? versionMatch =
        RegExp(r'version: ([\d\.]+)').firstMatch(versionOutput);
    if (versionMatch != null) {
      final String? sdkVersion = versionMatch.group(1);
      if (sdkVersion != null) {
        final int? numericSdkVersion =
            convertToThousands(int.tryParse(sdkVersion.replaceAll('.', '')));
        final int? numericMinVersion =
            convertToThousands(int.tryParse(minVersion.replaceAll('.', '')));
        final int? numericMaxVersion =
            convertToThousands(int.tryParse(maxVersion.replaceAll('.', '')));
        if (numericSdkVersion != null &&
            numericMinVersion != null &&
            numericMaxVersion != null) {
          if (numericSdkVersion >= numericMinVersion &&
              numericSdkVersion <= numericMaxVersion) {
            return true;
          }
        }
      }
    }

    return false;
  }
}
