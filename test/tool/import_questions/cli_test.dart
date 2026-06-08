import 'dart:convert';
import 'dart:io';

import 'package:cse_cet_reviewer/core/content/sanity/parsers/question_parser.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProcessResult> _run(List<String> args) => Process.run(
      'dart',
      ['run', 'tools/import_questions/import_questions.dart', ...args],
    );

void main() {
  test('emits NDJSON docs the shipping parser accepts', () async {
    final tmp = await Directory.systemTemp.createTemp('iq_ndjson_');
    addTearDown(() => tmp.delete(recursive: true));
    // Point at a root that contains only the good fixture.
    final root = Directory('${tmp.path}/science/biology')
      ..createSync(recursive: true);
    File('${root.path}/cell-structure.yaml').writeAsStringSync(
      File('test/fixtures/questions/science/biology/cell-structure.yaml')
          .readAsStringSync(),
    );

    final result = await _run(['--root', tmp.path]);
    expect(result.exitCode, 0, reason: result.stderr as String?);

    final lines = (result.stdout as String)
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    expect(lines, hasLength(2));
    for (final line in lines) {
      final doc = Map<String, Object?>.from(jsonDecode(line) as Map);
      expect(doc['_type'], 'question');
      expect(() => parseQuestion(doc), returnsNormally);
    }
    // Figure-pending question is inactive.
    final byId = {
      for (final l in lines)
        (jsonDecode(l) as Map)['_id'] as String: jsonDecode(l) as Map,
    };
    expect(byId['q-biology-cell-structure-0002']!['isActive'], false);
  });

  test('fails loudly on an invalid question', () async {
    final tmp = await Directory.systemTemp.createTemp('iq_bad_');
    addTearDown(() => tmp.delete(recursive: true));
    final root = Directory('${tmp.path}/science/biology')
      ..createSync(recursive: true);
    File('${root.path}/bad.yaml').writeAsStringSync(
      File('test/fixtures/questions/science/biology/_bad.yaml')
          .readAsStringSync(),
    );

    final result = await _run(['--root', tmp.path]);
    expect(result.exitCode, isNot(0));
    expect(result.stderr as String, contains('q-biology-cell-structure-9001'));
  });

  test('seed-json builds an openable database via seed_writer', () async {
    final tmp = await Directory.systemTemp.createTemp('iq_seed_');
    addTearDown(() => tmp.delete(recursive: true));
    final root = Directory('${tmp.path}/science/biology')
      ..createSync(recursive: true);
    File('${root.path}/cell-structure.yaml').writeAsStringSync(
      File('test/fixtures/questions/science/biology/cell-structure.yaml')
          .readAsStringSync(),
    );
    final seed = '${tmp.path}/seed.json';

    final gen = await _run(['--root', tmp.path, '--seed-json', seed]);
    expect(gen.exitCode, 0, reason: gen.stderr as String?);

    final json = jsonDecode(File(seed).readAsStringSync()) as Map;
    expect((json['question'] as List), hasLength(2));
    expect((json['topic'] as List).first['_id'], 'topic-biology');
    expect((json['subject'] as List).first['_id'], 'subject-science');
    expect((json['exam'] as List).map((e) => e['_id']),
        containsAll(['exam-upcat', 'exam-dost-sei']));
  });
}
