import 'dart:io';

import 'package:dcli/dcli.dart';

class ScriptService {
  static Future<void> flutterClean(String modulePath) async {
    final cleanProcess = await Process.run(
      'flutter',
      ['clean'],
      workingDirectory: modulePath,
    );
    if (cleanProcess.exitCode != 0) {
      print(
          red('❌  Error running flutter clean for $modulePath: ${cleanProcess.stderr}'));
    } else {
      print(green('✅  Successfully ran flutter clean for $modulePath'));
    }
  }

  static Future<void> flutterPubGet(String modulePath) async {
    final pubGetProcess = await Process.run('flutter', ['pub', 'get'],
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
    final modulePath = '$workingDirectory/$moduleName';
    final packageArgs = ['pub', 'add', ...packages];

    final processResult = await Process.run(
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
}
