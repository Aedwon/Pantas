import 'dart:io';

import '../checks/check.dart';
import '../checks/lesson_pool_check.dart';
import '../checks/lesson_size_check.dart';
import '../checks/lesson_split_coverage_check.dart';
import '../checks/walkthrough_emphasis_check.dart';
import '../checks/walkthrough_example_connection_check.dart';
import '../checks/walkthrough_fence_line_check.dart';
import '../checks/walkthrough_fresh_instance_check.dart';
import '../checks/walkthrough_hard_break_check.dart';
import '../checks/walkthrough_trap_pair_check.dart';

List<Violation> runLessonChecks(String contentRoot) => [
      ...runLessonSizeCheck(contentRoot),
      ...runLessonSplitCoverageCheck(contentRoot),
      ...runLessonPoolCheck(contentRoot),
      ...runWalkthroughTrapPairCheck(contentRoot),
      ...runWalkthroughExampleConnectionCheck(contentRoot),
      ...runWalkthroughFreshInstanceCheck(contentRoot),
      ...runWalkthroughHardBreakCheck(contentRoot),
      ...runWalkthroughEmphasisCheck(contentRoot),
      ...runWalkthroughFenceLineCheck(contentRoot),
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
