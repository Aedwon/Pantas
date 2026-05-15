import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late AssessmentRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = AssessmentRepository(db);
  });

  tearDown(() => db.close());

  group('resultForExam', () {
    test('returns null when no result exists', () async {
      expect(await repo.resultForExam('exam1'), isNull);
    });

    test('returns row after saveResult', () async {
      final now = DateTime(2026);
      await repo.saveResult('exam1', now, [
        const TopicScore(topicId: 't1', correct: 2, total: 3),
      ]);

      final row = await repo.resultForExam('exam1');
      expect(row, isNotNull);
      expect(row!.examId, equals('exam1'));
      expect(row.completedAt, equals(now));
      final scores = (jsonDecode(row.topicScoresJson) as List)
          .cast<Map<String, dynamic>>();
      expect(scores, hasLength(1));
      expect(scores.first['topicId'], equals('t1'));
      expect(scores.first['correct'], equals(2));
      expect(scores.first['total'], equals(3));
    });
  });

  group('hasCompletedForExam', () {
    test('returns false when no result exists', () async {
      expect(await repo.hasCompletedForExam('exam1'), isFalse);
    });

    test('returns true after saveResult', () async {
      await repo.saveResult('exam1', DateTime.now(), []);
      expect(await repo.hasCompletedForExam('exam1'), isTrue);
    });
  });

  group('saveResult upsert', () {
    test('second saveResult for same exam overwrites, not duplicates',
        () async {
      final t1 = DateTime(2026);
      final t2 = DateTime(2026, 2);
      await repo.saveResult('exam1', t1, [
        const TopicScore(topicId: 't1', correct: 1, total: 3),
      ]);
      await repo.saveResult('exam1', t2, [
        const TopicScore(topicId: 't1', correct: 3, total: 3),
      ]);

      final row = await repo.resultForExam('exam1');
      expect(row!.completedAt, equals(t2));
      final scores = (jsonDecode(row.topicScoresJson) as List)
          .cast<Map<String, dynamic>>();
      expect(scores.first['correct'], equals(3));
    });
  });
}
