// The generated custom exam price table must match the question tree.
//
// A custom exam's price tier comes from content/exams/custom_subject_tiers.json.
// New content or a changed exam tag can move a subject's tier. A stale file
// would price a custom exam wrongly, so this check regenerates the table in
// memory and fails, naming the subject, when the file differs.
//
// Fix: `dart run tools/custom_tiers/build_custom_tiers.dart`, then review.
import 'dart:convert';
import 'dart:io';

import '../../tools/custom_tiers/build_custom_tiers.dart';
import 'check.dart';

class CustomSubjectTiersCheck extends Check {
  const CustomSubjectTiersCheck();

  @override
  String get name => 'custom-subject-tiers';

  @override
  String get origin =>
      'Nov 2026: a custom exam is priced from its subjects, so a subject '
      'table older than the exam tags would charge the wrong tier';

  @override
  List<Violation> run(String root) {
    final file = File('$root/content/exams/custom_subject_tiers.json');
    final committed = file.existsSync()
        ? jsonDecode(file.readAsStringSync()) as Map<String, Object?>
        : null;
    final generated = jsonDecode(jsonEncode(buildCustomTiersFromTree(root)))
        as Map<String, Object?>;
    return findStaleSubjectTiers(committed, generated);
  }
}

Map<String, Map<String, Object?>> _byName(Map<String, Object?> table) => {
      for (final s in (table['subjects']! as List).cast<Map<String, Object?>>())
        s['name']! as String: s,
    };

List<Violation> findStaleSubjectTiers(
  Map<String, Object?>? committed,
  Map<String, Object?> generated,
) {
  const fix = 'run dart run tools/custom_tiers/build_custom_tiers.dart';
  if (committed == null) {
    return [
      const Violation(
        'content/exams/custom_subject_tiers.json',
        'missing; run dart run tools/custom_tiers/build_custom_tiers.dart',
      ),
    ];
  }
  final have = _byName(committed);
  final want = _byName(generated);
  final found = <Violation>[];
  for (final name in {...want.keys, ...have.keys}) {
    final a = have[name];
    final b = want[name];
    if (b == null) {
      found.add(Violation(name, 'in the file but no longer in the tree; $fix'));
    } else if (a == null) {
      found.add(Violation(name, 'missing from the file (${b['tier']}); $fix'));
    } else if (a['tier'] != b['tier']) {
      found.add(
        Violation(
          name,
          'file says ${a['tier']}, the tree says ${b['tier']}; $fix',
        ),
      );
    } else if (jsonEncode(a['topicIds']) != jsonEncode(b['topicIds'])) {
      found.add(Violation(name, 'topic list differs from the tree; $fix'));
    }
  }
  final haveTopics =
      (committed['topicTiers'] ?? <String, Object?>{}) as Map<String, Object?>;
  final wantTopics = generated['topicTiers']! as Map<String, Object?>;
  for (final id in {...wantTopics.keys, ...haveTopics.keys}) {
    if (haveTopics[id] != wantTopics[id]) {
      found.add(
        Violation(
          id,
          'topic tier is ${haveTopics[id]} in the file, ${wantTopics[id]} in '
          'the tree; $fix',
        ),
      );
    }
  }
  if (found.isEmpty && jsonEncode(committed) != jsonEncode(generated)) {
    found.add(Violation('custom_subject_tiers.json', 'differs; $fix'));
  }
  return found;
}
