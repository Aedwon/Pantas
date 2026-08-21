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

  test('assets/seed/v1.json carries integer contentVersion', () {
    final file = File('assets/seed/v1.json');
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

  test('all seven generated exams in assets/seed/v1.json are active', () {
    final file = File('assets/seed/v1.json');
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
}
