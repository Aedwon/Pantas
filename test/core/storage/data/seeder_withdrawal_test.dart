import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
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

const _v1WithdrawnJson = '''
{
  "schemaVersion": 1,
  "contentVersion": 2026080400,
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
  "lessons": [],
  "questions": [
    {
      "id": "q1", "version": 1, "examIds": ["e1"], "topicId": "t1",
      "language": "en", "stem": "Active question",
      "choices": [], "explanation": "Explanation 1",
      "isWithdrawn": false
    },
    {
      "id": "q2", "version": 1, "examIds": ["e1"], "topicId": "t1",
      "language": "en", "stem": "Withdrawn question",
      "choices": [], "explanation": "Explanation 2",
      "isWithdrawn": true
    }
  ]
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'withdrawn question is excluded from pickers '
      'but accessible by id for history', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await Seeder(db, bundle: _FixtureBundle(_v1WithdrawnJson)).maybeSeed();

    final repo = ContentRepository(db);

    // 1. Excluded from questionsByTopic picker
    final activeQuestions = await repo.questionsByTopic('t1');
    expect(activeQuestions.map((q) => q.id), contains('q1'));
    expect(activeQuestions.map((q) => q.id), isNot(contains('q2')));

    // 2. Accessible by id for history rendering
    final withdrawnQuestion = await repo.questionById('q2');
    expect(withdrawnQuestion, isNotNull);
    expect(withdrawnQuestion!.stem, equals('Withdrawn question'));
  });
}
