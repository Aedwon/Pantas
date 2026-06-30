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
      ByteData.sublistView(Uint8List.fromList([]));
}

const _seedWithPassagesJson = '''
{
  "schemaVersion": 1,
  "contentVersion": 2026080400,
  "exams": [
    {
      "id": "e1", "code": "UPCAT", "name": "UPCAT",
      "shortName": "UPCAT", "language": "en",
      "subjects": [
        {"id": "s1", "examId": "e1", "name": "Reading", "ordering": 1}
      ]
    }
  ],
  "topics": [{"id": "t1", "subjectId": "s1", "name": "Comprehension", "ordering": 1}],
  "lessons": [],
  "passages": [
    {
      "id": "p1",
      "topicId": "t1",
      "title": "The Palay Harvest",
      "body": "Sample body text for reading passage.",
      "language": "en",
      "wordCount": 6
    }
  ],
  "questions": [
    {
      "id": "q1", "version": 1, "examIds": ["e1"], "topicId": "t1",
      "passageId": "p1", "language": "en", "stem": "Question about passage",
      "choices": [], "explanation": "Explanation."
    }
  ]
}
''';

const _seedWithoutPassagesJson = '''
{
  "schemaVersion": 1,
  "contentVersion": 2026080401,
  "exams": [
    {
      "id": "e1", "code": "UPCAT", "name": "UPCAT",
      "shortName": "UPCAT", "language": "en",
      "subjects": [
        {"id": "s1", "examId": "e1", "name": "Reading", "ordering": 1}
      ]
    }
  ],
  "topics": [{"id": "t1", "subjectId": "s1", "name": "Comprehension", "ordering": 1}],
  "lessons": [],
  "questions": [
    {
      "id": "q2", "version": 1, "examIds": ["e1"], "topicId": "t1",
      "language": "en", "stem": "Freestanding question",
      "choices": [], "explanation": "Explanation."
    }
  ]
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seeder inserts passages and questions resolve passageId', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await Seeder(db, bundle: _FixtureBundle(_seedWithPassagesJson)).maybeSeed();

    final passage = await db.select(db.passages).getSingle();
    expect(passage.id, equals('p1'));
    expect(passage.title, equals('The Palay Harvest'));
    expect(passage.wordCount, equals(6));

    final question = await (db.select(db.questions)
          ..where((q) => q.id.equals('q1')))
        .getSingle();
    expect(question.passageId, equals('p1'));
  });

  test('seeder works unchanged for a seed without passages', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await Seeder(db, bundle: _FixtureBundle(_seedWithoutPassagesJson))
        .maybeSeed();

    final passages = await db.select(db.passages).get();
    expect(passages, isEmpty);

    final question = await (db.select(db.questions)
          ..where((q) => q.id.equals('q2')))
        .getSingle();
    expect(question.passageId, isNull);
  });
}
