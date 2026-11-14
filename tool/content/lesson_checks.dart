import 'dart:io';

import '../checks/check.dart';
import '../checks/lesson_pool_check.dart';
import '../checks/lesson_size_check.dart';
import '../checks/lesson_split_coverage_check.dart';

List<Violation> runLessonChecks(String contentRoot) => [
      ...runLessonSizeCheck(contentRoot),
      ...runLessonSplitCoverageCheck(contentRoot),
      ...runLessonPoolCheck(contentRoot),
    ];

void main(List<String> args) {
  if (args.length != 2 ||
      args.first != '--root' ||
      !Directory(args[1]).existsSync()) {
    stderr.writeln(
      'Usage: dart run tool/content/lesson_checks.dart --root <content dir>',
    );
    exitCode = 2;
    return;
  }
  final findings = runLessonChecks(args[1]);
  for (final finding in findings) {
    stderr.writeln(finding);
  }
  exitCode = findings.isEmpty ? 0 : 1;
}
