// Runs every verification check. Exit 0 if clean, 1 if any check has a finding
// that is not accepted. Run from the project root:
//
//   dart run tool/checks/run_checks.dart
//
// To add a check: a new file here, its failing-sample test under
// test/tool/checks/, and a line in allChecks.
import 'dart:io';

import 'bold_stem.dart';
import 'check.dart';
import 'design_token_literals.dart';
import 'lesson_list_exam_scope.dart';
import 'legal_text_drafting.dart';
import 'letter_shortcut_gate.dart';
import 'mock_blueprint_topics.dart';
import 'shell_route_push.dart';
import 'sync_mutations_typed_read.dart';

const allChecks = <Check>[
  ShellRoutePushCheck(),
  SyncMutationsTypedReadCheck(),
  MockBlueprintTopicsCheck(),
  BoldStemCheck(),
  LessonListExamScopeCheck(),
  DesignTokenLiteralsCheck(),
  LetterShortcutGateCheck(),
  LegalTextDraftingCheck(),
];

void main() {
  if (!Directory('lib').existsSync()) {
    stderr.writeln('lib/ not found; run from the project root.');
    exit(2);
  }
  final root = Directory.current.path;
  var failed = 0;
  for (final check in allChecks) {
    final found = check.run(root);
    final open = found.where((v) => v.acceptedBecause == null).toList();
    if (open.isEmpty) {
      stdout.writeln('OK    ${check.name}');
    } else {
      failed++;
      stderr
        ..writeln('FAIL  ${check.name} (${open.length})')
        ..writeln('      Came from: ${check.origin}');
      for (final violation in open) {
        stderr.writeln('      $violation');
      }
    }
    for (final violation in found.where((v) => v.acceptedBecause != null)) {
      stdout.writeln(
        '      accepted $violation (${violation.acceptedBecause})',
      );
    }
  }
  exit(failed == 0 ? 0 : 1);
}
