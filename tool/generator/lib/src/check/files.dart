import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../model.dart';
import 'check.dart';
import 'solvers/solver.dart';

Object? _plain(Object? value) {
  if (value is Map) {
    return <String, Object?>{
      for (final entry in value.entries)
        entry.key as String: _plain(entry.value),
    };
  }
  if (value is List) return value.map(_plain).toList();
  return value;
}

Map<String, Object?> _yaml(String source) =>
    _plain(loadYaml(source))! as Map<String, Object?>;

String _git(String root, List<String> args) {
  final result = Process.runSync(
    'git',
    args,
    workingDirectory: root,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  if (result.exitCode != 0) {
    throw FormatException('git ${args.first} failed: ${result.stderr}');
  }
  return result.stdout! as String;
}

/// Read only requested merged questions from the production content revision.
Map<String, Map<String, Object?>> readSourceQuestions(
  String root,
  String ref,
  Set<String> ids,
) {
  if (ids.isEmpty) return {};
  final paths = _git(root, [
    'ls-tree',
    '-r',
    '--name-only',
    ref,
    '--',
    'content/questions/',
  ]).split('\n').where((p) => p.endsWith('.yaml'));
  final questions = <String, Map<String, Object?>>{};
  for (final path in paths) {
    final source = _git(root, ['show', '$ref:$path']);
    // Most files are irrelevant. Avoid parsing the full corpus for one type.
    if (!ids.any(source.contains)) continue;
    final doc = _yaml(source);
    for (final raw in doc['questions']! as List) {
      final question = raw! as Map<String, Object?>;
      final id = question['id']! as String;
      if (!ids.contains(id)) continue;
      if (questions.containsKey(id)) {
        throw FormatException('duplicate source $id');
      }
      questions[id] = question;
    }
  }
  return questions;
}

List<CheckFailure> checkTypeFiles({
  required String root,
  required String typesPath,
  bool held = false,
  String questionsRef = 'origin/content/bite-sized-cse-algebra-r1',
}) {
  final directory = Directory(typesPath);
  if (!directory.existsSync()) return [];
  final files = directory
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (f) => f.path.endsWith('.yaml') && !f.path.endsWith('.variants.yaml'),
      )
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  final failures = <CheckFailure>[];
  final ids = <String>{};
  for (final file in files) {
    var id = file.uri.pathSegments.last.replaceFirst(RegExp(r'\.yaml$'), '');
    try {
      final type = parseProblemType(_yaml(file.readAsStringSync()));
      id = type.id;
      if (!ids.add(id)) throw const FormatException('duplicate type id');
      if (held) {
        if (!figureSolvers.containsKey(type.rule) &&
            !mathSolvers.containsKey(type.rule)) {
          failures.add(
            CheckFailure(
              id,
              0,
              'correctness',
              'no solver for rule ${type.rule}',
            ),
          );
        }
        continue;
      }
      final path = file.path.replaceFirst(RegExp(r'\.yaml$'), '.variants.yaml');
      final doc = parseVariantList(_yaml(File(path).readAsStringSync()));
      if (doc.problemType != id || doc.ruleVersion != type.ruleVersion) {
        throw const FormatException('variant metadata does not match type');
      }
      final sources = readSourceQuestions(
        root,
        questionsRef,
        type.mergedQuestions.map((m) => m.id).toSet(),
      );
      failures.addAll(checkVariants(type, doc.variants, questions: sources));
    } on Object catch (error) {
      failures.add(CheckFailure(id, 0, 'input', '$error'));
    }
  }
  return failures;
}
