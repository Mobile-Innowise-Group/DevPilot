import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dev_pilot/file_service.dart';

class Input {
  static String? getValidatedInput({
    String? stdoutMessage,
    String? errorMessage,
    bool? Function(String? message)? functionValidator,
  }) {
    stdout.write(stdoutMessage);
    String? message = FileService.removeTrailingComma(
        stdin.readLineSync()?.trim().toLowerCase());
    while (!(functionValidator?.call(message) ?? true)) {
      if (errorMessage != null) {
        stdout.write(red('❌  $errorMessage'));
      }
      message = stdin.readLineSync()?.trim();
    }
    return message;
  }
}
