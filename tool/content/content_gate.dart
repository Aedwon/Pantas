import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'ledger.dart';
import 'question_hash.dart';
import 'shipping_questions.dart';

class GateFinding {
  const GateFinding(this.id, this.reason);
  final String id;
  final String reason;
  @override
  String toString() => '$id: $reason';
}

// The exact legacy.json byte hashes, frozen once by the lead (Nov 14, 2026) and
// never edited after. Never accept a pin supplied by content itself.
const pinnedLegacyLedgers = <String>{
  // main content/ at 5369c0147: 3,163 questions.
  'd2b4b39ad671a38b99df4551eabcfc2c5de6acebd1b889c8914874f20dadfff7',
  // content/cse-rewrite-r1 1ca8dfd0c (the prod CSE root): 3,406 questions.
  'b28eb7bc7c6f975160338faa133c8c88e12ada289674161e7aca96747a5219e2',
};

List<GateFinding> runContentGate(
  String contentRoot, {
  Set<String>? legacyPins,
}) {
  final findings = <GateFinding>[];
  try {
    final legacyFile =
        File(p.join(contentRoot, 'question-ledger', 'legacy.json'));
    final legacy = readLedger(legacyFile);
    final approved = readLedger(
      File(p.join(contentRoot, 'question-ledger', 'approved.json')),
    );
    if (legacyFile.existsSync() &&
        !(legacyPins ?? pinnedLegacyLedgers).contains(
          sha256.convert(legacyFile.readAsBytesSync()).toString(),
        )) {
      findings.add(const GateFinding('legacy.json', 'legacy list changed'));
    }
    final splitTopics = <String>{};
    final lessons = Directory(p.join(contentRoot, 'lessons'));
    if (lessons.existsSync()) {
      for (final file in lessons
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.md'))) {
        final path = p.split(p.relative(file.path, from: lessons.path));
        if (path.length != 3) continue;
        final source = file.readAsStringSync();
        final match = RegExp(r'^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)')
            .firstMatch(source);
        if (match == null) continue;
        final frontmatter = loadYaml(match.group(1)!) as YamlMap;
        if (frontmatter.containsKey('part')) {
          splitTopics.add(p.join(path[0], path[1]));
        }
      }
    }
    for (final q in allQuestionsForApproval(contentRoot)) {
      final hash = questionHash(q.question, q.meta);
      if (approved[q.id]?['hash'] == hash) continue;
      String reason;
      if (legacy[q.id]?['hash'] == hash) {
        final path = p.split(
          p.relative(q.file.path, from: p.join(contentRoot, 'questions')),
        );
        if (path.length < 3 ||
            !splitTopics.contains(p.join(path[0], path[1]))) {
          continue;
        }
        reason = 'split topic on legacy status';
      } else if (approved.containsKey(q.id)) {
        reason = 'edited after approval';
      } else if (legacy.containsKey(q.id)) {
        reason = 'changed since frozen';
      } else {
        reason = 'not approved';
      }
      findings.add(GateFinding(q.id, reason));
    }
  } on Object catch (error) {
    findings.add(GateFinding('content', '$error'));
  }
  return findings;
}

void main(List<String> args) {
  if (args.length != 2 ||
      args.first != '--root' ||
      !Directory(args[1]).existsSync()) {
    stderr.writeln(
      'Usage: dart run tool/content/content_gate.dart --root <content dir>',
    );
    exitCode = 2;
    return;
  }
  final findings = runContentGate(args[1]);
  for (final finding in findings) {
    stderr.writeln(finding);
  }
  exitCode = findings.isEmpty ? 0 : 1;
}
