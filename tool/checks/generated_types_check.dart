// Tool libraries live outside the root package lib directory.
// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import '../generator/lib/src/check/files.dart';
import 'check.dart';

/// A generated list must never reach content delivery without independent
/// checks.
class GeneratedTypesCheck extends Check {
  const GeneratedTypesCheck();
  @override
  String get name => 'generated-types';
  @override
  String get origin => 'Question generator spec B5: planted invalid variants';
  @override
  List<Violation> run(String root) {
    final path = '$root/content/types';
    final heldPath = '$root/content/types-held';
    if (!Directory(path).existsSync() && !Directory(heldPath).existsSync()) {
      stdout.writeln(
        '      no content/types/ directory; generated types skipped',
      );
      return [];
    }
    final failures = checkTypeFiles(root: root, typesPath: path)
      ..addAll(checkTypeFiles(root: root, typesPath: heldPath, held: true));
    return failures
        .map(
          (failure) => Violation(
            '${failure.typeId} #${failure.index} ${failure.check}',
            failure.reason,
          ),
        )
        .toList();
  }
}
