// Tool libraries live outside the root package lib directory.
// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import '../generator/lib/src/check/files.dart';
import 'check.dart';

/// A generated list must never reach content delivery without independent checks.
class GeneratedTypesCheck extends Check {
  const GeneratedTypesCheck();
  @override
  String get name => 'generated-types';
  @override
  String get origin => 'Question generator spec B5: planted invalid variants';
  @override
  List<Violation> run(String root) {
    final path = '$root/content/types';
    if (!Directory(path).existsSync()) {
      stdout.writeln(
          '      no content/types/ directory; generated types skipped');
      return [];
    }
    return checkTypeFiles(root: root, typesPath: path)
        .map((failure) => Violation(
            '${failure.typeId} #${failure.index} ${failure.check}',
            failure.reason))
        .toList();
  }
}
