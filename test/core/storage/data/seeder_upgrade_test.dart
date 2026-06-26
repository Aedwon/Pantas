import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/seeder.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

class _FixtureBundle extends CachingAssetBundle {
  _FixtureBundle(this.json);

  final String json;

  @override
  Future<String> loadString(String key, {bool cache = true}) async => json;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(json)));
}

class _ThrowingBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      throw UnimplementedError('Asset bundle should not be read');

  @override
  Future<ByteData> load(String key) async =>
      throw UnimplementedError('Asset bundle should not be read');
}

const _v1Json = '''
{
  "schemaVersion": 1,
  "contentVersion": 2026080100,
  "exams": [
    {
      "id": "e1", "code": "CSE", "name": "Civil Service Exam",
      "shortName": "CSE", "language": "en",
      "subjects": [
        {"id": "s1", "examId": "e1", "name": "Science", "ordering": 1}
      ]
    }
  ],
  "topics": [{"id": "t1", "subjectId": "s1", "name": "Chemistry", "ordering": 1}],
  "lessons": [
    {
      "id": "l1", "topicId": "t1", "title": "Balancing equations",
      "summary": "How to balance.", "bodyJson": [], "estimatedMinutes": 5
    }
  ],
  "questions": [
    {
      "id": "q1", "version": 1, "examIds": ["e1"], "topicId": "t1",
      "lessonId": "l1", "language": "en", "stem": "Original Stem Q1",
      "choices": [], "explanation": "Because."
    }
  ]
}
''';

const _v2Json = '''
{
  "schemaVersion": 1,
  "contentVersion": 2026080200,
  "exams": [
    {
      "id": "e1", "code": "CSE", "name": "Civil Service Exam",
      "shortName": "CSE", "language": "en",
      "subjects": [
        {"id": "s1", "examId": "e1", "name": "Science", "ordering": 1}
      ]
    }
  ],
  "topics": [{"id": "t1", "subjectId": "s1", "name": "Chemistry", "ordering": 1}],
  "lessons": [
    {
      "id": "l1", "topicId": "t1", "title": "Balancing equations",
      "summary": "How to balance.", "bodyJson": [], "estimatedMinutes": 5
    }
  ],
  "questions": [
    {
      "id": "q1", "version": 2, "examIds": ["e1"], "topicId": "t1",
      "lessonId": "l1", "language": "en", "stem": "Revised Stem Q1",
      "choices": [], "explanation": "Revised explanation."
    },
    {
      "id": "q2", "version": 1, "examIds": ["e1"], "topicId": "t1",
      "language": "en", "stem": "New Question Q2",
      "choices": [], "explanation": "New explanation."
    }
  ]
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'seeder upgrade pass updates questions and preserves student data',
    () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);

      // Initial seed v1
      await Seeder(db, bundle: _FixtureBundle(_v1Json)).maybeSeed();

      final prefs = AppPreferencesRepository(db);
      expect(await prefs.appliedContentVersion(), equals(2026080100));

      // Simulate student work: write an attempt, review state, flag
      await db.into(db.attemptsLocal).insert(
            AttemptsLocalCompanion.insert(
              id: 'attempt_1',
              examId: 'e1',
              startedAt: DateTime.now(),
              itemsJson: jsonEncode([
                {'questionId': 'q1', 'choiceId': 'a', 'isCorrect': true},
              ]),
            ),
          );

      await db.into(db.reviewStateLocal).insert(
            ReviewStateLocalCompanion.insert(
              questionId: 'q1',
              questionVersion: 1,
              stage: 'learning',
              stability: 2.5,
              difficulty: 3,
              due: DateTime.now(),
              lastReview: DateTime.now(),
              reps: 1,
              lapses: 0,
              elapsedDays: 1,
              scheduledDays: 3,
            ),
          );

      await db.into(db.questionFlagsLocal).insert(
            QuestionFlagsLocalCompanion.insert(
              questionId: 'q1',
              flaggedAt: DateTime.now(),
            ),
          );

      final attemptsBefore = await db.select(db.attemptsLocal).get();
      final reviewBefore = await db.select(db.reviewStateLocal).get();
      final flagsBefore = await db.select(db.questionFlagsLocal).get();

      // Run upgrade to v2
      await Seeder(db, bundle: _FixtureBundle(_v2Json)).maybeSeed();

      // 1. The revised question's stem changed.
      final q1 = await (db.select(db.questions)
            ..where((q) => q.id.equals('q1')))
          .getSingle();
      expect(q1.stem, equals('Revised Stem Q1'));

      // 2. The revised question's id did not change.
      expect(q1.id, equals('q1'));

      // 3. New questions are present.
      final q2 = await (db.select(db.questions)
            ..where((q) => q.id.equals('q2')))
          .getSingleOrNull();
      expect(q2, isNotNull);
      expect(q2!.stem, equals('New Question Q2'));

      // 4. attempts_local is unchanged.
      final attemptsAfter = await db.select(db.attemptsLocal).get();
      expect(attemptsAfter.length, equals(attemptsBefore.length));
      expect(attemptsAfter.first.id, equals(attemptsBefore.first.id));
      expect(
        attemptsAfter.first.itemsJson,
        equals(attemptsBefore.first.itemsJson),
      );

      // 5. review_state_local is unchanged.
      final reviewAfter = await db.select(db.reviewStateLocal).get();
      expect(reviewAfter.length, equals(reviewBefore.length));
      expect(
        reviewAfter.first.questionId,
        equals(reviewBefore.first.questionId),
      );

      // 6. Flags still point at the revised question.
      final flagsAfter = await db.select(db.questionFlagsLocal).get();
      expect(
        flagsAfter.first.questionId,
        equals(flagsBefore.first.questionId),
      );

      // 7. The stored contentVersion advanced.
      expect(await prefs.appliedContentVersion(), equals(2026080200));
    },
  );

  test(
    'a pass that throws mid-transaction leaves stored version unadvanced',
    () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);

      await Seeder(db, bundle: _FixtureBundle(_v1Json)).maybeSeed();
      final prefs = AppPreferencesRepository(db);
      expect(await prefs.appliedContentVersion(), equals(2026080100));

      // Bad json that throws inside transaction during question parsing
      const badJson = '''
{
  "schemaVersion": 1,
  "contentVersion": 2026080300,
  "exams": [], "topics": [], "lessons": [],
  "questions": "not_a_list"
}
''';

      expect(
        () => Seeder(db, bundle: _FixtureBundle(badJson)).maybeSeed(),
        throwsA(isA<TypeError>()),
      );

      // Stored version remains 2026080100
      expect(await prefs.appliedContentVersion(), equals(2026080100));
      final q1 = await (db.select(db.questions)
            ..where((q) => q.id.equals('q1')))
          .getSingle();
      expect(q1.stem, equals('Original Stem Q1'));
    },
  );

  test('equal versions do not load asset at all', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await Seeder(db, bundle: _FixtureBundle(_v1Json)).maybeSeed();
    final prefs = AppPreferencesRepository(db);
    expect(await prefs.appliedContentVersion(), equals(2026080100));

    // Running maybeSeed with a throwing bundle when
    // stored version == contentVersion should return without reading bundle
    await Seeder(db, bundle: _ThrowingBundle()).maybeSeed(
      contentVersion: 2026080100,
    );
  });
}
