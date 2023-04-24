import 'dart:io';

import 'package:dcli/dcli.dart';

class ScriptService {
  static Future<void> flutterClean(String modulePath) async {
    final ProcessResult cleanProcess = await Process.run(
      'flutter',
      ['clean'],
      workingDirectory: modulePath,
    );
    if (cleanProcess.exitCode != 0) {
      print(red(
          '❌  Error running flutter clean for $modulePath: ${cleanProcess.stderr}'));
    } else {
      print(green('✅  Successfully ran flutter clean for $modulePath'));
    }
  }

  static Future<void> flutterPubGet(String modulePath) async {
    final ProcessResult pubGetProcess = await Process.run(
        'flutter', ['pub', 'get'],
        workingDirectory: modulePath);
    if (pubGetProcess.exitCode != 0) {
      print(red(
          '❌  Error running flutter pub get for $modulePath : ${pubGetProcess.stderr}'));
    } else {
      print(green('✅  Successfully ran flutter pub get for $modulePath'));
    }
  }

  static Future<void> addPackagesToModules(
    String moduleName,
    List<String> packages,
    String workingDirectory,
  ) async {
    final String modulePath = '$workingDirectory/$moduleName';
    final List<String> packageArgs = ['pub', 'add', ...packages];

    final ProcessResult processResult = await Process.run(
      'flutter',
      packageArgs,
      workingDirectory: modulePath,
    );
    if (processResult.exitCode == 0) {
      print(green('✅ Packages added to module $moduleName'));
    } else {
      print(
        red('❌ Failed to add packages to module $moduleName: ${processResult.stderr}'),
      );
    }
  }

  static Future<void> runScript(String scriptName, String directoryPath) async {
    final String scriptPath = '$directoryPath/$scriptName';
    final ProcessResult process = await Process.run(
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

  static Future<bool> isDartVersionInRange(
      String minVersion, String maxVersion) async {
    ProcessResult processResult = await Process.run('dart', ['--version']);
    final String versionOutput = processResult.stdout.toString().trim();
    final versionMatch =
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
