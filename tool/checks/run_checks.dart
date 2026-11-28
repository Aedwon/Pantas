// Runs every verification check. Exit 0 if clean, 1 if any check has a finding
// that is not accepted. Run from the project root:
//
//   dart run tool/checks/run_checks.dart
//
// To add a check: a new file here, its failing-sample test under
// test/tool/checks/, and a line in allChecks.
import 'dart:io';

import 'analytics_never_blocks.dart';
import 'bold_stem.dart';

import 'check.dart';
import 'content_approval_check.dart';
import 'custom_subject_tiers.dart';
import 'design_token_literals.dart';
import 'figure_classes.dart';
import 'generated_types_check.dart';
import 'internal_terms.dart';
import 'legal_text_drafting.dart';
import 'lesson_list_exam_scope.dart';
import 'lesson_minutes_on_screen.dart';
import 'lesson_pool_check.dart';
import 'lesson_size_check.dart';
import 'lesson_split_coverage_check.dart';
import 'letter_shortcut_gate.dart';
import 'mock_blueprint_topics.dart';
import 'question_id_limits.dart';
import 'session_stored_order.dart';
import 'shell_route_push.dart';
import 'sync_mutations_typed_read.dart';
import 'walkthrough_block_spacing_check.dart';
import 'walkthrough_emphasis_check.dart';
import 'walkthrough_example_connection_check.dart';
import 'walkthrough_fence_line_check.dart';
import 'walkthrough_fresh_instance_check.dart';
import 'walkthrough_giveaway_check.dart';
import 'walkthrough_hard_break_check.dart';
import 'walkthrough_slim_format_check.dart';
import 'walkthrough_trap_pair_check.dart';

const allChecks = <Check>[
  GeneratedTypesCheck(),
  ContentApprovalCheck(),
  LessonSizeCheck(),
  LessonSplitCoverageCheck(),
  LessonPoolCheck(),
  WalkthroughTrapPairCheck(),
  WalkthroughExampleConnectionCheck(),
  WalkthroughFreshInstanceCheck(),
  WalkthroughHardBreakCheck(),
  WalkthroughBlockSpacingCheck(),
  WalkthroughEmphasisCheck(),
  WalkthroughFenceLineCheck(),
  WalkthroughSlimFormatCheck(),
  WalkthroughGiveawayCheck(),
  ShellRoutePushCheck(),
  SyncMutationsTypedReadCheck(),
  MockBlueprintTopicsCheck(),
  BoldStemCheck(),
  LessonListExamScopeCheck(),
  LessonMinutesOnScreenCheck(),
  DesignTokenLiteralsCheck(),
  CustomSubjectTiersCheck(),
  LetterShortcutGateCheck(),
  LegalTextDraftingCheck(),
  AnalyticsNeverBlocksCheck(),
  QuestionIdLimitsCheck(),
  SessionStoredOrderCheck(),
  FigureClassesCheck(),
  InternalTermsCheck(),
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
