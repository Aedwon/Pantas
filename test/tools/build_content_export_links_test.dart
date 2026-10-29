import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late Map<String, Object?> links;
  late Map<String, Object?> tags;

  void write(String path, Object? value) {
    final file = File('${root.path}/$path');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(value));
  }

  Future<ProcessResult> run({bool assets = false}) {
    write('content/lesson-prerequisites.json', links);
    write('content/question-gap-tags.json', tags);
    return Process.run('dart', [
      'run',
      'tools/build_content_export/build_content_export.dart',
      '${root.path}/export.json',
      root.path,
      if (assets) ...['--assets-out', '${root.path}/assets/seed'],
    ]);
  }

  setUp(() {
    root = Directory.systemTemp.createTempSync('roadmap-export-');
    Directory('${root.path}/content/questions').createSync(recursive: true);
    Directory('${root.path}/content/lessons').createSync(recursive: true);
    write('tools/lesson_author/outline.json', {'subjects': <Object?>[]});
    write('tools/build_content_export/historical_v1.json', {
      'exams': [
        {
          'id': 'exam_cse_pro',
          'subjects': [
            {'id': 's', 'name': 'Subject', 'ordering': 1},
          ],
        },
      ],
      'topics': [
        {'id': 't', 'subjectId': 's'},
      ],
      'lessons': [
        for (final id in ['a', 'b', 'c']) {'id': id, 'topicId': 't'},
      ],
      'questions': [
        {
          'id': 'q',
          'topicId': 't',
          'lessonId': 'a',
          'stem': 'Question',
          'explanation': 'Explanation',
          'choices': [
            {'id': 'q_a', 'label': 'A', 'text': ' Yes ', 'isCorrect': true},
            {'id': 'q_b', 'label': 'B', 'text': ' No ', 'isCorrect': false},
          ],
        },
      ],
    });
    links = {
      'version': 1,
      'lessons': {
        'a': [
          {'lesson': 'b', 'strength': 'required'},
        ],
      },
    };
    tags = {
      'version': 1,
      'questions': {
        'q': {' No ': 'b'},
      },
    };
  });
  tearDown(() => root.deleteSync(recursive: true));

  test('exports stable links, stored choice ids and a slim asset', () async {
    final first = await run(assets: true);
    expect(first.exitCode, 0, reason: '${first.stderr}');
    final file = File('${root.path}/export.json');
    final bytes = file.readAsBytesSync();
    final output = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    expect(output['lessonLink'], [
      {'lesson': 'a', 'requires': 'b', 'strength': 'required'},
    ]);
    expect(output['gapTag'], [
      {'question': 'q', 'choice': 'q_b', 'prerequisite': 'b'},
    ]);
    final asset = File('${root.path}/assets/seed/lesson_links.json');
    expect(jsonDecode(asset.readAsStringSync()), {
      'a': [
        {'lesson': 'b', 'strength': 'required'},
      ],
    });
    expect(asset.readAsStringSync(), isNot(contains('q_b')));
    final again = await run(assets: true);
    expect(again.exitCode, 0);
    expect(file.readAsBytesSync(), bytes);
    expect(first.stdout, contains('1 links and 1 tags'));
  });

  test('skips and counts a tagged figure-pending question', () async {
    write('tools/lesson_author/outline.json', {
      'subjects': [
        {
          'slug': 'math',
          'name': 'Math',
          'topics': [
            {'slug': 't', 'name': 'Topic'},
          ],
        }
      ],
    });
    File('${root.path}/content/questions/pending.yaml').writeAsStringSync('''
meta:
  topic: t
  subtopic: pending
  exams: [cse_pro]
questions:
  - id: pending
    figure: waiting
''');
    (tags['questions']! as Map<String, Object?>)['pending'] = {'No': 'b'};
    final result = await run();
    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect(
      result.stdout,
      contains('skipped 1 tagged figure-pending questions'),
    );
  });
  for (final kind in ['links', 'tags']) {
    test('rejects missing $kind shape', () async {
      (kind == 'links' ? links : tags).clear();
      final result = await run();
      expect(result.exitCode, 65);
    });
  }

  final badLinks = <String, Object?>{
    'bad shape': [],
    'unknown source lesson': {'missing': <Object?>[]},
    'unknown target lesson': {
      'a': [
        {'lesson': 'missing', 'strength': 'required'},
      ],
    },
    'self link': {
      'a': [
        {'lesson': 'a', 'strength': 'required'},
      ],
    },
    'duplicate link': {
      'a': [
        {'lesson': 'b', 'strength': 'required'},
        {'lesson': 'b', 'strength': 'helpful'},
      ],
    },
    'invalid strength': {
      'a': [
        {'lesson': 'b', 'strength': 'optional'},
      ],
    },
    'cycle': {
      'a': [
        {'lesson': 'b', 'strength': 'required'},
      ],
      'b': [
        {'lesson': 'a', 'strength': 'helpful'},
      ],
    },
    'bad link shape': {
      'a': [7],
    },
  };
  for (final entry in badLinks.entries) {
    test('rejects ${entry.key} with exit 65', () async {
      links['lessons'] = entry.value;
      final result = await run();
      expect(result.exitCode, 65, reason: '${result.stderr}');
      expect(result.stderr, contains('lesson-prerequisites.json'));
      expect(result.stderr, contains(entry.key));
      expect(File('${root.path}/export.json').existsSync(), isFalse);
    });
  }
  for (final kind in ['links', 'tags']) {
    for (final bad in [null, 2]) {
      test('rejects $kind version $bad', () async {
        (kind == 'links' ? links : tags)['version'] = bad;
        final result = await run();
        expect(result.exitCode, 65);
        expect(result.stderr, contains('version'));
      });
    }
  }
  final badTags = <String, Object?>{
    'bad shape': [],
    'unknown question': {
      'missing': {'No': 'b'},
    },
    'no matching choice': {
      'q': {'Maybe': 'b'},
    },
    'correct choice': {
      'q': {'Yes': 'b'},
    },
    'unknown lesson': {
      'q': {'No': 'missing'},
    },
    'not a link target': {
      'q': {'No': 'c'},
    },
    'bad tag shape': {'q': <Object?>[]},
  };
  for (final entry in badTags.entries) {
    test('rejects tag ${entry.key} with exit 65', () async {
      tags['questions'] = entry.value;
      final result = await run();
      expect(result.exitCode, 65, reason: '${result.stderr}');
      expect(result.stderr, contains('question-gap-tags.json'));
      expect(result.stderr, contains(entry.key));
    });
  }
  test('rejects ambiguous trimmed choice text', () async {
    final historical =
        File('${root.path}/tools/build_content_export/historical_v1.json');
    final data =
        jsonDecode(historical.readAsStringSync()) as Map<String, dynamic>;
    final questions = data['questions'] as List<dynamic>;
    final question = questions.single as Map<String, dynamic>;
    final choices = question['choices'] as List<dynamic>;
    (choices.first as Map<String, dynamic>)['text'] = 'No';
    historical.writeAsStringSync(jsonEncode(data));
    final result = await run();
    expect(result.exitCode, 65);
    expect(result.stderr, contains('multiple matching choices'));
  });
}
