import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../tools/build_dev_seed/build_dev_seed.dart';

void main() {
  test('computeContentVersion returns monotonic YYYYMMDDHH int', () {
    final t1 = DateTime.utc(2026, 8, 4, 10);
    final t2 = DateTime.utc(2026, 8, 4, 11);

    final v1 = computeContentVersion(t1);
    final v2 = computeContentVersion(t2);

    expect(v1, isA<int>());
    expect(v1, equals(2026080410));
    expect(v2, equals(2026080411));
    expect(v2, greaterThan(v1));
  });

  test('tool-owned historical corpus carries integer contentVersion', () {
    expect(
      File('assets/seed/v1.json').existsSync(),
      isFalse,
      reason: 'retired runtime seed path must stay absent',
    );
    final file = File(devSeedHistoricalCorpusPath);
    expect(file.existsSync(), isTrue);

    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    expect(json.containsKey('contentVersion'), isTrue);
    expect(json['contentVersion'], isA<int>());
  });

  test('every question carries the lesson it belongs to', () {
    final topicIdBySlug = loadTopicIdBySlug();
    final questions = buildQuestions(topicIdBySlug);
    expect(questions, isNotEmpty);
    for (final q in questions) {
      expect(
        q.containsKey('lessonId'),
        isTrue,
        reason: '${q['id']} missing lessonId',
      );
      expect(q['lessonId'], isNotNull, reason: '${q['id']} has null lessonId');
    }
  });

  test('the lesson id matches a lesson that actually exists', () {
    final topicIdBySlug = loadTopicIdBySlug();
    final questions = buildQuestions(topicIdBySlug);
    final lessonIds = buildLessons(topicIdBySlug).map((l) => l['id']).toSet();
    for (final q in questions) {
      expect(lessonIds, contains(q['lessonId']), reason: '${q['id']}');
    }
  });

  test('all seven generated exams in tool-owned historical corpus are active',
      () {
    final file = File(devSeedHistoricalCorpusPath);
    expect(file.existsSync(), isTrue);

    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final exams = (json['exams'] as List).cast<Map<String, dynamic>>();
    expect(exams.length, 7);
    for (final exam in exams) {
      expect(
        exam['isActive'],
        isTrue,
        reason: '${exam['id']} should be active',
      );
    }
  });

  test(
    'buildLessons propagates FormatException on malformed FIGURE JSON '
    'instead of returning empty body',
    () {
      final tempDir =
          Directory.systemTemp.createTempSync('build_dev_seed_malformed_test');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final lessonsDir =
          Directory('${tempDir.path}/content/lessons/mathematics/algebra')
            ..createSync(recursive: true);
      File('${lessonsDir.path}/linear-equations.md').writeAsStringSync('''
---
_id: lesson-algebra-linear-equations
isActive: true
topic: topic-algebra
title: Linear Equations
summary: Basics
estimatedMinutes: 5
ordering: 1
---
# Header
<!-- FIGURE: {invalid-json-here} -->
Paragraph text.
''');

      final topicIdBySlug = {'algebra': 'topic_upcat_algebra'};

      expect(
        () => buildLessons(topicIdBySlug, tempDir.path),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains(
                'content/lessons/mathematics/algebra/linear-equations.md',
              ),
              contains(':2:'),
            ),
          ),
        ),
      );
    },
  );

  test(
    'buildLessons with absent assets.json ignores legacy ILLUSTRATION '
    'markers and preserves text',
    () {
      final tempDir =
          Directory.systemTemp.createTempSync('build_dev_seed_no_assets_test');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final lessonsDir =
          Directory('${tempDir.path}/content/lessons/mathematics/algebra')
            ..createSync(recursive: true);
      File('${lessonsDir.path}/linear-equations.md').writeAsStringSync('''
---
_id: lesson-algebra-linear-equations
isActive: true
topic: topic-algebra
title: Linear Equations
summary: Basics
estimatedMinutes: 5
ordering: 1
---
# Header
<!-- ILLUSTRATION: unconfigured placeholder -->
Paragraph text after.
''');

      final topicIdBySlug = {'algebra': 'topic_upcat_algebra'};

      final lessons = buildLessons(topicIdBySlug, tempDir.path);
      expect(lessons.length, 1);
      final body =
          (lessons.single['bodyJson']! as List).cast<Map<String, dynamic>>();
      expect(body, isNotEmpty);
      expect(body.length, 2);
      expect(body[0]['_type'], 'block');
      expect(body[1]['_type'], 'block');
    },
  );
}
