import 'dart:io';

import 'package:dcli/dcli.dart';

import '../constants/app_constants.dart';
import 'converter_service.dart';

/// This class provides functions to update file content, append to files,
/// and remove trailing commas.
class FileService {
  /// Updates the contents of the file at the given [filePath] by replacing
  /// all occurrences of [oldString] with [newString].
  ///
  /// Throws an exception if the file cannot be read or written to.
  static Future<void> updateFileContent({
    required String oldString,
    required String newString,
    required String filePath,
  }) async {
    final File file = File(filePath);
    String content = await file.readAsString();
    content = content.replaceAll(oldString, newString);
    await file.writeAsString(content);
  }

  /// Appends [newString] to the file at the given [filePath] after the
  /// first occurrence of [oldString].
  ///
  /// Throws an exception if the file cannot be read or written to, or if
  /// [oldString] is not found in the file.
  static Future<void> appendToFile(String oldString, String newString, String filePath) async {
    final File file = File(filePath);
    final String content = await file.readAsString();
    final int oldIndex = content.indexOf(oldString);
    if (oldIndex == -1) {
      throw Exception(red('❌ Could not find the old string in the file'));
    }
    final String newContent = content.replaceRange(
        oldIndex + oldString.length, oldIndex + oldString.length, '\n$newString');
    await file.writeAsString(newContent);
  }

  /// Removes the trailing comma from the given [input] string, if present.
  ///
  /// Returns the modified string or null if [input] is null.
  static String? removeTrailingComma(String? input) {
    if (input != null) {
      if (input.endsWith(',')) {
        return input.substring(0, input.length - 1);
      } else {
        return input;
      }
    }
    return null;
  }

  /// Rewrite the contents of the file at the given [filePath] by replacing
  /// all occurrences with [newString].
  ///
  /// Throws an exception if the file cannot be read or written to.
  static Future<void> rewriteFileContent({
    required String newString,
    required String filePath,
  }) async {
    final File file = File(filePath);
    await file.writeAsString('', flush: true);
    await file.writeAsString(newString);
  }

  static Future<void> prettifyYaml(String filePath) async {
    final File file = File(filePath);
    final List<String> lines = await file.readAsLines();

    final List<String> filtered = _removeComments(lines);
    final List<String> compressed = _removeWhitespaces(filtered);

    final String result = compressed.reduce(
      (String value, String line) => '$value${Platform.lineTerminator}$line',
    );

    await file.writeAsString(result, flush: true);
  }

  static List<String> _removeComments(List<String> lines) {
    final RegExp regExp = RegExp(r'^\s*#');

    return lines.where((String line) => !regExp.hasMatch(line)).map(
      (String line) {
        final int commentPos = line.indexOf('#');
        return commentPos == -1 ? line : line.substring(0, commentPos);
      },
    ).toList();
  }

  static List<String> _removeWhitespaces(List<String> lines) {
    if (lines.isEmpty) {
      return lines;
    }

    final List<String> filtered = <String>[lines.first];

    for (int i = 1; i < lines.length; i++) {
      if (lines[i].trim().isNotEmpty) {
        filtered.add(lines[i]);
        continue;
      }

      final String previous = lines[i - 1].trimRight();
      if (previous.endsWith(':')) {
        continue;
      }

      if (previous.trimLeft().isEmpty) {
        continue;
      }

      filtered.add(lines[i]);
    }

    return filtered;
  }

  static Future<void> appendFeatureDependenciesToNavigation({
    required String yamlFilePath,
    required List<String> features,
  }) async {
    final String sep = Platform.pathSeparator;
    final File file = File(yamlFilePath);

    final List<String> lines = await file.readAsLines();

    final List<String> imports = features
        .expand(
          (String feature) => <String>[
            '  $feature:',
            '    path: ..$sep${AppConstants.kFeatures}$sep$feature',
          ],
        )
        .toList();

    final int packageDependenciesIndex = _getRelativeDependenciesEndLine(lines);
    lines.insertAll(packageDependenciesIndex, imports);
    final String result = lines.reduce(
      (String value, String line) => '$value${Platform.lineTerminator}$line',
    );

    await file.writeAsString(result);
  }

  static int _getRelativeDependenciesEndLine(List<String> lines) {
    int lastRelativeDependencyLine = -1;

    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i].trim();
      if (line.startsWith('path:')) {
        lastRelativeDependencyLine = i + 1;
      }
    }

    return lastRelativeDependencyLine;
  }

  static Future<void> appendFeatureDependenciesToAppRouter({
    required String appRouterFilePath,
    required List<String> features,
  }) async {
    final String sep = Platform.pathSeparator;
    final File file = File(appRouterFilePath);

    final List<String> lines = await file.readAsLines();

    final List<String> imports = <String>[
      ...lines.where((String line) => line.contains("import 'package:")),
      ...features.map((String feature) => "import 'package:$feature$sep$feature.dart';"),
    ];

    imports.sort();
    lines.removeWhere((String line) => line.contains("import 'package:"));

    final int routesIndex = lines.indexOf('  List<AutoRoute> get routes => <AutoRoute>[];');

    final List<String> routes = features.map(
      (String feature) {
        final String pascalName = ConverterService.snakeToPascalCase(feature);
        return '        ...${pascalName}Router().routes,';
      },
    ).toList();

    final List<String> appended = <String>[
      ...imports,
      ...lines.sublist(0, routesIndex),
      '  List<AutoRoute> get routes => <AutoRoute>[',
      ...routes,
      '      ];',
      ...lines.sublist(routesIndex + 1),
    ];

    final String result = appended.reduce(
      (String value, String line) => '$value${Platform.lineTerminator}$line',
    );

    await file.writeAsString(result);
  }

  static Future<void> appendFeatureExportsToNavigation({
    required String libraryFilePath,
    required List<String> features,
  }) async {
    final String sep = Platform.pathSeparator;
    final File file = File(libraryFilePath);

    final List<String> lines = await file.readAsLines();

    final List<String> exports = <String>[
      ...lines.where((String line) => line.contains("export 'package:")),
      ...features.map((String feature) => "export 'package:$feature$sep$feature.dart';"),
    ];

    final int exportsIndex = lines.indexWhere((String line) => line.contains("export 'package:"));

    exports.sort();
    lines.removeWhere((String line) => line.contains("export 'package:"));
    lines.insertAll(exportsIndex, exports);

    final String result = lines.reduce(
      (String value, String line) => '$value${Platform.lineTerminator}$line',
    );

    await file.writeAsString(result);
  }
}
