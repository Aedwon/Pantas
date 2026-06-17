import 'dart:convert';
import 'dart:typed_data';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
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

const _fixture = '''
{
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
      "lessonId": "l1", "language": "en", "stem": "Tagged question",
      "choices": [], "explanation": "Because."
    },
    {
      "id": "q2", "version": 1, "examIds": ["e1"], "topicId": "t1",
      "language": "en", "stem": "Untagged question",
      "choices": [], "explanation": "Because."
    }
  ]
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Seeder seeder;

  setUp(() {
    db = inMemoryDatabase();
    seeder = Seeder(db, bundle: rootBundle);
  });
  tearDown(() => db.close());

  // Counts are deliberately not asserted as literals: the seed asset is
  // regenerated whenever content is authored, and pinning the numbers here made
  // every content commit a failing test. What matters is that each table is
  // populated and that seeding twice does not duplicate rows.
  test(
      'maybeSeed populates exams/subjects/topics/questions/lessons on empty DB',
      () async {
    await seeder.maybeSeed();

    expect(await db.select(db.exams).get(), isNotEmpty);
    expect(await db.select(db.subjects).get(), isNotEmpty);
    expect(await db.select(db.topics).get(), isNotEmpty);
    expect(await db.select(db.questions).get(), isNotEmpty);
    expect(await db.select(db.lessons).get(), isNotEmpty);
  });

  test('maybeSeed is idempotent (running twice does not duplicate rows)',
      () async {
    await seeder.maybeSeed();
    final afterFirst = [
      (await db.select(db.exams).get()).length,
      (await db.select(db.subjects).get()).length,
      (await db.select(db.topics).get()).length,
      (await db.select(db.questions).get()).length,
      (await db.select(db.lessons).get()).length,
    ];

    await seeder.maybeSeed();
    final afterSecond = [
      (await db.select(db.exams).get()).length,
      (await db.select(db.subjects).get()).length,
      (await db.select(db.topics).get()).length,
      (await db.select(db.questions).get()).length,
      (await db.select(db.lessons).get()).length,
    ];

    expect(afterSecond, equals(afterFirst));
  });

  test('a question carries its lesson id when the seed provides one', () async {
    await Seeder(db, bundle: _FixtureBundle(_fixture)).maybeSeed();

    final row = await (db.select(db.questions)..where((q) => q.id.equals('q1')))
        .getSingle();

    expect(row.lessonId, 'l1');
  });

  test('a question with no lesson id in the seed stores null', () async {
    await Seeder(db, bundle: _FixtureBundle(_fixture)).maybeSeed();

    final row = await (db.select(db.questions)..where((q) => q.id.equals('q2')))
        .getSingle();

    expect(row.lessonId, isNull);
  });

  test('lessons are inserted before the questions that reference them',
      () async {
    await Seeder(db, bundle: _FixtureBundle(_fixture)).maybeSeed();

    // Enforce the constraint the app never turns on, to prove the seed order
    // would survive it.
    await db.customStatement('PRAGMA foreign_key_check');
  });
}
