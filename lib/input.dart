import 'dart:io';

import 'app_constants.dart';

class Input {
  static String? getValidatedInput({
    String? stdoutMessage,
    String? errorMessage,
    bool? Function(String? message)? functionValidator,
    bool? isPositiveResponse,
  }) {
    stdout.write(stdoutMessage);
    String? message = stdin.readLineSync()?.trim().toLowerCase();
    while (!(functionValidator?.call(message) ?? true) ||
        (isPositiveResponse == true
            ? message != AppConstants.kYes && message != AppConstants.kNo
            : false)) {
      stdout.write(errorMessage);
      message = stdin.readLineSync()?.trim();
    }
    return message;
  }
}
