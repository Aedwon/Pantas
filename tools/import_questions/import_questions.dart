import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'converter.dart';
import 'ids.dart';

Future<void> main(List<String> args) async {
  final root = _flag(args, '--root') ?? 'content/questions';
  final seedJson = _flag(args, '--seed-json');
  final updatedAt = DateTime.now().toUtc();

  final questionDocs = <Map<String, Object?>>[];
  final seenIds = <String>{};
  final examCodes = <String>{};
  final topicSlugs = <String, String>{}; // topicSlug -> subjectSlug

  final dir = Directory(root);
  if (!dir.existsSync()) {
    stderr.writeln('Question root not found: $root');
    exitCode = 66;
    return;
  }

  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.yaml'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    try {
      final doc = loadYaml(file.readAsStringSync());
      if (doc is! Map || doc['meta'] is! Map) {
        throw const FormatException('missing a top-level `meta:` block');
      }
      final meta = Map<Object?, Object?>.from(doc['meta'] as Map);
      // Named explicitly, because a missing key used to escape the catch below
      // as an unhandled null cast: exit 255, a raw stack trace, and no file
      // name to act on.
      for (final key in ['subject', 'topic', 'subtopic', 'exams']) {
        if (meta[key] == null) {
          throw FormatException('meta is missing `$key:`');
        }
      }
      if (doc['questions'] is! List) {
        throw const FormatException('missing a top-level `questions:` list');
      }
      final qm = QuestionMeta(
        subjectSlug: meta['subject']! as String,
        topicSlug: meta['topic']! as String,
        subtopicSlug: meta['subtopic']! as String,
        examCodes: [for (final e in (meta['exams']! as List)) e as String],
      );
      topicSlugs[qm.topicSlug] = qm.subjectSlug;
      examCodes.addAll(qm.examCodes);
      for (final raw in (doc['questions'] as List)) {
        final q = Map<Object?, Object?>.from(raw as Map);
        final built = questionToDoc(q, qm, updatedAt: updatedAt);
        final id = built['_id']! as String;
        if (!seenIds.add(id)) {
          throw FormatException('$id: duplicate question id');
        }
        questionDocs.add(built);
      }
    } on FormatException catch (e) {
      stderr.writeln('${file.path}: ${e.message}');
      exitCode = 65;
      return;
    } catch (e) {
      // Anything else still names its file. An agent that cannot see which
      // file broke cannot fix it, and asks a human instead.
      stderr.writeln('${file.path}: $e');
      exitCode = 65;
      return;
    }
  }

  if (seedJson != null) {
    final payload = {
      'exam': [
        for (final code in examCodes)
          {
            '_id': examId(code),
            '_type': 'exam',
            '_updatedAt': updatedAt.toIso8601String(),
            'schemaVersion': 1,
            'isActive': true,
            'code': code.toUpperCase(),
            'name': code.toUpperCase(),
            'shortName': code.toUpperCase(),
            'language': 'en',
            'ordering': 1,
          },
      ],
      'subject': [
        for (final slug in topicSlugs.values.toSet())
          {
            '_id': subjectId(slug),
            '_type': 'subject',
            '_updatedAt': updatedAt.toIso8601String(),
            'schemaVersion': 1,
            'isActive': true,
            'exam': {'_ref': examId(examCodes.first)},
            'name': slug,
            'ordering': 1,
          },
      ],
      'topic': [
        for (final entry in topicSlugs.entries)
          {
            '_id': topicId(entry.key),
            '_type': 'topic',
            '_updatedAt': updatedAt.toIso8601String(),
            'schemaVersion': 1,
            'isActive': true,
            'subject': {'_ref': subjectId(entry.value)},
            'name': entry.key,
            'ordering': 1,
          },
      ],
      'question': questionDocs,
    };
    File(seedJson)
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
    return;
  }

  final out = StringBuffer();
  for (final doc in questionDocs) {
    out.writeln(jsonEncode(doc));
  }
  stdout.write(out.toString());
}

String? _flag(List<String> args, String name) {
  final i = args.indexOf(name);
  return (i == -1 || i + 1 >= args.length) ? null : args[i + 1];
}
