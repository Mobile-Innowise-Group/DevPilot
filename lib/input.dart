import 'dart:io';

import 'package:dcli/dcli.dart';
import 'file_service.dart';

/// This class provides a function
/// to get validated user input from the command line.
class Input {
  /// Gets validated user input from the command line.
  ///
  /// [stdoutMessage] is the message to display to the user before getting input.
  /// [errorMessage] is the message to display to the user if the input is invalid.
  /// [functionValidator] is an optional function that takes a string
  /// and returns a bool indicating whether the input is valid.
  /// If not provided, all input is considered valid.
  ///
  /// Trailing commas are automatically removed from the input.
  ///
  /// Returns the validated input from the user.
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
