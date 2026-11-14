import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'ledger.dart';
import 'question_hash.dart';
import 'shipping_questions.dart';

// Approval is a lead-only operation after an independent solve. The evidence
// file is required even for a pure move; YAML's checkbox grants no authority.
void main(List<String> args) {
  final options = <String, String>{};
  var moved = false;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--moved' && !moved) {
      moved = true;
    } else if (['--root', '--ids', '--evidence'].contains(arg) &&
        !options.containsKey(arg) &&
        i + 1 < args.length &&
        !args[i + 1].startsWith('--')) {
      options[arg] = args[++i];
    } else {
      _usage();
      return;
    }
  }
  if (options.length != 3 ||
      !Directory(options['--root']!).existsSync() ||
      !File(options['--ids']!).existsSync() ||
      !File(options['--evidence']!).existsSync()) {
    _usage();
    return;
  }
  try {
    final root = options['--root']!;
    final evidence = _relativeEvidence(root, options['--evidence']!);
    final ids = File(options['--ids']!)
        .readAsLinesSync()
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    if (ids.isEmpty) {
      _usage();
      return;
    }
    final file = File(p.join(root, 'question-ledger', 'approved.json'));
    final approved = readLedger(file);
    final legacy =
        readLedger(File(p.join(root, 'question-ledger', 'legacy.json')));
    final questions = {for (final q in allQuestionsForApproval(root)) q.id: q};
    for (final id in ids) {
      final q = questions[id];
      if (q == null) {
        stderr.writeln('$id: not found among questions');
        exitCode = 1;
        continue;
      }
      if (moved &&
          ![approved[id], legacy[id]].any(
            (entry) =>
                entry != null &&
                entry['lesson'] is String &&
                questionHash(
                      {...q.question, 'lesson': entry['lesson']},
                      q.meta,
                    ) ==
                    entry['hash'],
          )) {
        stderr.writeln(
          '$id: move includes an edit or has no matching ledger entry',
        );
        exitCode = 1;
        continue;
      }
      // Reload after each edit: offsets of later questions in this file shift.
      final current = allQuestionsForApproval(root)
          .firstWhere((candidate) => candidate.id == id);
      _setApproved(current);
      approved[id] = {
        'hash': questionHash(q.question, q.meta),
        'lesson': questionLesson(q.question, q.meta),
        'evidence': evidence,
        'approvedAt': DateTime.now().toUtc().toIso8601String().substring(0, 10),
      };
      writeLedger(file, approved);
      stdout.writeln('$id: approved');
    }
  } on Object catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}

void _usage() {
  stderr.writeln(
    'Usage: dart run tool/content/approve.dart --root <content dir> '
    '--ids <file> --evidence <existing file> [--moved]',
  );
  exitCode = 2;
}

void _setApproved(ShippingQuestion q) {
  final source = q.file.readAsStringSync();
  void writeValidated(String edited) {
    loadYaml(edited, sourceUrl: q.file.uri);
    q.file.writeAsStringSync(edited);
  }

  for (final entry in q.question.nodes.entries) {
    if ((entry.key as YamlNode).value == 'approved') {
      if (entry.value.value == true) return;
      final span = entry.value.span;
      writeValidated(
        source.replaceRange(span.start.offset, span.end.offset, 'true'),
      );
      return;
    }
  }
  final start = q.question.span.start.offset;
  if (source[start] == '{') {
    // Insert before any existing trailing comma, whitespace, or comment.
    final end = q.question.nodes.values.last.span.end.offset;
    writeValidated(source.replaceRange(end, end, ', approved: true'));
    return;
  }
  final newline = source.contains('\r\n') ? '\r\n' : '\n';
  final idNode = q.question.nodes.entries
      .firstWhere((entry) => (entry.key as YamlNode).value == 'id')
      .value;
  final lineEnd = source.indexOf('\n', idNode.span.end.offset);
  final indent = ' ' * q.question.span.start.column;
  if (lineEnd < 0) {
    writeValidated('$source$newline${indent}approved: true$newline');
  } else {
    writeValidated(
      source.replaceRange(
        lineEnd + 1,
        lineEnd + 1,
        '${indent}approved: true$newline',
      ),
    );
  }
}

String _relativeEvidence(String contentRoot, String evidencePath) {
  var repository = Directory(contentRoot).absolute;
  while (!File(p.join(repository.path, '.git')).existsSync() &&
      !Directory(p.join(repository.path, '.git')).existsSync()) {
    final parent = repository.parent;
    if (parent.path == repository.path) {
      throw StateError('Content root is not inside a repository.');
    }
    repository = parent;
  }
  final root = repository.resolveSymbolicLinksSync();
  final evidence = File(evidencePath).resolveSymbolicLinksSync();
  if (!p.isWithin(root, evidence)) {
    throw StateError('Evidence must be inside the content repository.');
  }
  return p.relative(evidence, from: root).split(p.separator).join('/');
}
