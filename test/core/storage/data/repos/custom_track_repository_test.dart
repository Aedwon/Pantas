import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/sync/mapping/track_scope_mapper.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late CustomTrackRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    repo = CustomTrackRepository(db, contentDb);
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  Future<void> seedCorpus() async {
    await seedContentExam(contentDb, examId: 'exam_upcat', code: 'UPCAT');
    await seedContentSubject(
      contentDb,
      subjectId: 'math',
      examId: 'exam_upcat',
      name: 'Mathematics',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'sci',
      examId: 'exam_upcat',
      name: 'Science',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'algebra',
      subjectId: 'math',
      name: 'Algebra',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'chem',
      subjectId: 'sci',
      name: 'Chemistry',
    );
  }

  test('lesson exclusions persist beside topics without a schema change',
      () async {
    await repo.setExcluded(
      examId: 'exam_upcat',
      topicIds: {'chem'},
      lessonIds: {'l2', 'l1'},
    );
    final reopened = CustomTrackRepository(db, contentDb);
    expect(await reopened.excludedLessonIds('exam_upcat'), {'l1', 'l2'});
    expect(await reopened.excludedTopicIds('exam_upcat'), {'chem'});
    expect(await reopened.excludedLessonIds('other'), isEmpty);
    expect(db.schemaVersion, 26);
    await reopened
        .setExcluded(examId: 'exam_upcat', topicIds: {'chem'}, lessonIds: {});
    expect(await repo.excludedLessonIds('exam_upcat'), isEmpty);
    expect(await repo.excludedTopicIds('exam_upcat'), {'chem'});
  });

  test('creating a track stores its name and hides nothing it includes',
      () async {
    await seedCorpus();

    final examId = await repo.create(
      name: 'Provincial scholarship exam',
      includedTopicIds: {'algebra', 'chem'},
    );

    final exam = await (contentDb.select(contentDb.contentExams)
          ..where((e) => e.id.equals(examId)))
        .getSingle();
    expect(exam.name, 'Provincial scholarship exam');
    expect(exam.shortName, 'Provincial scholarship exam');
    expect(await repo.excludedTopicIds(examId), isEmpty);
  });

  test('creating a track excludes every topic it did not include', () async {
    await seedCorpus();

    final examId = await repo.create(
      name: 'Maths only',
      includedTopicIds: {'algebra'},
    );

    expect(await repo.excludedTopicIds(examId), {'chem'});
  });

  test('the created track is custom and is not listed', () async {
    await seedCorpus();

    final examId = await repo.create(name: 'Mine', includedTopicIds: {});
    final exam = await (contentDb.select(contentDb.contentExams)
          ..where((e) => e.id.equals(examId)))
        .getSingle();

    expect(exam.isCustom, isTrue);

    final listed = await (contentDb.select(contentDb.contentExams)
          ..where((e) => e.isCustom.equals(false)))
        .get();
    expect(listed.map((e) => e.id), ['exam_upcat']);
  });

  test('re-including a topic deletes its exclusion', () async {
    await seedCorpus();
    final examId = await repo.create(
      name: 'Maths only',
      includedTopicIds: {'algebra'},
    );

    await repo.setExcluded(examId: examId, topicIds: {});

    expect(await repo.excludedTopicIds(examId), isEmpty);
  });

  test('setting exclusions never touches attempts or review state', () async {
    await seedCorpus();
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'att_1',
            examId: 'exam_upcat',
            startedAt: DateTime(2026, 8),
            completedAt: Value(DateTime(2026, 8, 1, 0, 10)),
            itemsJson: jsonEncode([]),
          ),
        );
    await db.into(db.reviewStateLocal).insert(
          ReviewStateLocalCompanion.insert(
            questionId: 'q_1',
            questionVersion: 1,
            stage: 'review',
            stability: 3,
            difficulty: 5,
            due: DateTime(2026, 8, 5),
            lastReview: DateTime(2026, 8),
            reps: 2,
            lapses: 0,
            elapsedDays: 1,
            scheduledDays: 4,
          ),
        );

    await repo.setExcluded(examId: 'exam_upcat', topicIds: {'chem'});

    // Narrowing hides and never purges: both survive untouched.
    expect(await db.select(db.attemptsLocal).get(), hasLength(1));
    expect(await db.select(db.reviewStateLocal).get(), hasLength(1));
  });

  test('two tracks keep their own scopes', () async {
    await seedCorpus();

    final first = await repo.create(name: 'One', includedTopicIds: {'algebra'});
    final second = await repo.create(name: 'Two', includedTopicIds: {'chem'});

    expect(await repo.excludedTopicIds(first), {'chem'});
    expect(await repo.excludedTopicIds(second), {'algebra'});
  });

  group('after a reload on web', () {
    test('the in-memory content database has no custom exam and no marker',
        () async {
      await seedCorpus();
      final examId = await repo.create(name: 'Mine', includedTopicIds: {});
      expect(await repo.projectionRequired(examId), isFalse);

      // A reload opens a fresh in-memory content database. The study
      // database keeps the track, and no retry marker is left to act on.
      final reloaded = inMemoryContentDatabase();
      addTearDown(reloaded.close);
      final afterReload = CustomTrackRepository(db, reloaded);

      expect(await afterReload.retryPendingProjections(), isTrue);
      expect(await ContentRepository(reloaded).listExams(), isEmpty);
      expect(await db.select(db.customTrackMetaLocal).get(), hasLength(1));
    });

    test('reprojectAll puts every stored track back as a custom exam',
        () async {
      await seedCorpus();
      final first = await repo.create(name: 'One', includedTopicIds: {});
      final second = await repo.create(name: 'Two', includedTopicIds: {});

      final reloaded = inMemoryContentDatabase();
      addTearDown(reloaded.close);
      await CustomTrackRepository(db, reloaded).reprojectAll();

      final exams = await ContentRepository(reloaded).listExams();
      expect(exams.map((e) => e.id).toSet(), {first, second});
      expect(exams.every((e) => e.isCustom), isTrue);
      expect(
        {for (final e in exams) e.id: e.name},
        {first: 'One', second: 'Two'},
      );
    });

    test('reprojectAll leaves listed exams alone and skips a deleted track',
        () async {
      await seedCorpus();
      final kept = await repo.create(name: 'Kept', includedTopicIds: {});
      final gone = await repo.create(name: 'Gone', includedTopicIds: {});
      await repo.delete(gone);

      await repo.reprojectAll();

      final ids = (await ContentRepository(contentDb).listExams())
          .map((e) => e.id)
          .toSet();
      expect(ids, {'exam_upcat', kept});
    });

    test('a sign-out wipe leaves the next account no track and no exam',
        () async {
      await seedCorpus();
      await repo.create(name: 'Maria exam', includedTopicIds: {});
      await SyncLocalStateWiper(db).wipeAll();

      final reloaded = inMemoryContentDatabase();
      addTearDown(reloaded.close);
      await CustomTrackRepository(db, reloaded).reprojectAll();

      expect(await db.select(db.customTrackMetaLocal).get(), isEmpty);
      expect(await db.select(db.trackScopeLocal).get(), isEmpty);
      expect(await ContentRepository(reloaded).listExams(), isEmpty);
    });
  });

  group('what the server is sent for a custom exam', () {
    const examId = 'exam_custom_6f1d0a52-3c1b-4c0e-8a52-0f6a3d2c9b11';
    const algebra = 'topic_upcat_algebra';
    const chem = 'topic_upcat_chem';
    const topicsBySubject = {
      'subj_math': [algebra],
      'subj_sci': [chem],
      'subj_empty': <String>[],
    };
    final saved = DateTime.utc(2026, 11, 4, 8);

    Future<void> saveBlueprint(CustomBlueprint blueprint) =>
        CustomBlueprintRepository(db).save(
          blueprint,
          topicsBySubject: topicsBySubject,
          now: saved,
        );

    test('the name comes from the stored track', () async {
      expect(await repo.name(examId), isNull);
      await db.into(db.customTrackMetaLocal).insert(
            CustomTrackMetaLocalCompanion.insert(examId: examId, name: 'Mine'),
          );
      expect(await repo.name(examId), 'Mine');
      expect(await repo.name('exam_custom_other'), isNull);
    });

    test('no stored blueprint gives none', () async {
      expect(await repo.blueprintPayload(examId), isNull);
    });

    // The strings below are what CustomBlueprint.toSectionsJson writes, and
    // each test asserts that, so the fixture cannot drift from the writer.
    final wholeExam = [
      '[{"id":"section_all","name":"Whole exam",',
      '"questionCount":100,"suggestedMinutes":120,',
      '"topicIds":["topic_upcat_algebra","topic_upcat_chem"]}]',
    ].join();
    final twoParts = [
      '[{"id":"section_0","name":"Mathematics",',
      '"questionCount":50,"suggestedMinutes":60,',
      '"topicIds":["topic_upcat_algebra"]},',
      '{"id":"section_1","name":"Science","questionCount":40,',
      '"suggestedMinutes":45,"topicIds":["topic_upcat_chem"]}]',
    ].join();

    test('one continuous paper is sent with exactly the five fields', () async {
      await saveBlueprint(
        const CustomBlueprint(
          examId: examId,
          totalQuestions: 100,
          totalMinutes: 120,
        ),
      );
      final row = (await CustomBlueprintRepository(db).read(examId))!;
      expect(row.sectionsJson, wholeExam);

      expect(await repo.blueprintPayload(examId), {
        'sectionsJson': wholeExam,
        'totalQuestions': 100,
        'totalMinutes': 120,
        'sectionsTimedSeparately': false,
        'updatedAt': saved.millisecondsSinceEpoch,
      });
    });

    test('parts timed separately are sent when the minutes add up', () async {
      await saveBlueprint(
        const CustomBlueprint(
          examId: examId,
          totalQuestions: 90,
          totalMinutes: 105,
          sectionsTimedSeparately: true,
          sections: [
            CustomBlueprintSectionDraft(
              subjectId: 'subj_math',
              name: 'Mathematics',
              questions: 50,
              minutes: 60,
            ),
            CustomBlueprintSectionDraft(
              subjectId: 'subj_sci',
              name: 'Science',
              questions: 40,
              minutes: 45,
            ),
          ],
        ),
      );
      final row = (await CustomBlueprintRepository(db).read(examId))!;
      expect(row.sectionsJson, twoParts);

      final payload = (await repo.blueprintPayload(examId))!;
      expect(payload['sectionsJson'], twoParts);
      expect(payload['totalQuestions'], 90);
      expect(payload['totalMinutes'], 105);
      expect(payload['sectionsTimedSeparately'], isTrue);
    });

    test('a part the student named uses every topic and is sent', () async {
      await saveBlueprint(
        const CustomBlueprint(
          examId: examId,
          totalQuestions: 60,
          totalMinutes: 70,
          sections: [
            CustomBlueprintSectionDraft(
              name: 'Everything',
              questions: 60,
              minutes: 70,
            ),
          ],
        ),
      );
      final payload = (await repo.blueprintPayload(examId))!;
      expect(
        payload['sectionsJson'],
        '[{"id":"section_0","name":"Everything","questionCount":60,'
        '"suggestedMinutes":70,"topicIds":'
        '["topic_upcat_algebra","topic_upcat_chem"]}]',
      );
      expect(payload['sectionsTimedSeparately'], isFalse);
    });

    // Real shapes the setup screen can save that the server refuses. The
    // blueprint is left out of the publish and the local row stays.
    final refused = <String, CustomBlueprint>{
      'one part timed separately': const CustomBlueprint(
        examId: examId,
        totalQuestions: 50,
        totalMinutes: 60,
        sectionsTimedSeparately: true,
        sections: [
          CustomBlueprintSectionDraft(
            subjectId: 'subj_math',
            name: 'Mathematics',
            questions: 50,
            minutes: 60,
          ),
        ],
      ),
      'parts that add up to more than 300 questions': const CustomBlueprint(
        examId: examId,
        totalQuestions: 320,
        totalMinutes: 200,
        sections: [
          CustomBlueprintSectionDraft(
            subjectId: 'subj_math',
            name: 'Mathematics',
            questions: 160,
            minutes: 100,
          ),
          CustomBlueprintSectionDraft(
            subjectId: 'subj_sci',
            name: 'Science',
            questions: 160,
            minutes: 100,
          ),
        ],
      ),
      'parts that add up to more than 720 minutes': const CustomBlueprint(
        examId: examId,
        totalQuestions: 100,
        totalMinutes: 800,
        sections: [
          CustomBlueprintSectionDraft(
            subjectId: 'subj_math',
            name: 'Mathematics',
            questions: 50,
            minutes: 400,
          ),
          CustomBlueprintSectionDraft(
            subjectId: 'subj_sci',
            name: 'Science',
            questions: 50,
            minutes: 400,
          ),
        ],
      ),
      'a part whose subject has no topics left': const CustomBlueprint(
        examId: examId,
        totalQuestions: 20,
        totalMinutes: 30,
        sections: [
          CustomBlueprintSectionDraft(
            subjectId: 'subj_empty',
            name: 'Emptied',
            questions: 20,
            minutes: 30,
          ),
        ],
      ),
    };
    for (final entry in refused.entries) {
      test('${entry.key} is left out and the local row stays', () async {
        await saveBlueprint(entry.value);
        expect(await repo.blueprintPayload(examId), isNull);
        expect(
          await CustomBlueprintRepository(db).exists(examId),
          isTrue,
        );
      });
    }

    for (final legacy in ['[]', 'not json', '{"id":"section_all"}']) {
      test('a stored row with sections $legacy is left out', () async {
        await db.into(db.customBlueprintsLocal).insert(
              CustomBlueprintsLocalCompanion.insert(
                examId: examId,
                totalQuestions: 50,
                totalMinutes: 60,
                sectionsJson: legacy,
                updatedAt: saved,
              ),
            );
        expect(await repo.blueprintPayload(examId), isNull);
        expect(await CustomBlueprintRepository(db).exists(examId), isTrue);
      });
    }
  });

  group('restoring a track from the server', () {
    const examId = 'exam_custom_6f1d0a52-3c1b-4c0e-8a52-0f6a3d2c9b11';
    final sections = [
      '[{"id":"section_all","name":"Whole exam",',
      '"questionCount":100,"suggestedMinutes":120,',
      '"topicIds":["topic_upcat_algebra"]}]',
    ].join();
    Map<String, Object?> json({
      Object? name = 'From the server',
      Object? blueprint,
      Object? excludedTopicIds = const ['topic_upcat_chem', 'topic_upcat_bio'],
      Object? examIdValue = examId,
    }) =>
        {
          'examId': examIdValue,
          'name': name,
          'excludedTopicIds': excludedTopicIds,
          'excludedLessonIds': ['lesson_2', 'lesson_1'],
          'blueprint': blueprint,
          'createdAt': 1762243200000,
          'updatedAt': 1762246800000,
        };
    final blueprintJson = {
      'sectionsJson': sections,
      'totalQuestions': 100,
      'totalMinutes': 120,
      'sectionsTimedSeparately': false,
      'updatedAt': 1762246800000,
    };

    Future<List<String>> recorded() async => [
          for (final row in await db
              .customSelect(
                'select collection, row_id from sync_local_mutations '
                'order by collection, row_id',
              )
              .get())
            '${row.read<String>('collection')}:${row.read<String>('row_id')}',
        ];

    test('writes the track, its scope, lessons and blueprint, then projects',
        () async {
      final row = CustomTrackRow.fromJson(json(blueprint: blueprintJson));

      expect(await repo.restoreFromServer(row), isTrue);

      expect(await repo.name(examId), 'From the server');
      expect(
        await repo.excludedTopicIds(examId),
        {'topic_upcat_chem', 'topic_upcat_bio'},
      );
      expect(await repo.excludedLessonIds(examId), {'lesson_1', 'lesson_2'});
      final blueprint = (await CustomBlueprintRepository(db).read(examId))!;
      expect(blueprint.sectionsJson, sections);
      expect(blueprint.totalQuestions, 100);
      expect(blueprint.totalMinutes, 120);
      expect(blueprint.sectionsTimedSeparately, isFalse);
      expect(
        blueprint.updatedAt.millisecondsSinceEpoch,
        1762246800000,
      );
      final exam = await (contentDb.select(contentDb.contentExams)
            ..where((e) => e.id.equals(examId)))
          .getSingle();
      expect(exam.name, 'From the server');
      expect(exam.isCustom, isTrue);
      expect(await repo.projectionRequired(examId), isFalse);
    });

    test('records the track, each scope row and the blueprint for sync',
        () async {
      await repo.restoreFromServer(
        CustomTrackRow.fromJson(json(blueprint: blueprintJson)),
      );

      final bio = TrackScopeDocumentId.scope(examId, 'topic_upcat_bio');
      final chem = TrackScopeDocumentId.scope(examId, 'topic_upcat_chem');
      expect(
        await recorded(),
        unorderedEquals([
          'custom_blueprints:$examId',
          'track_scope:${TrackScopeDocumentId.metadata(examId)}',
          'track_scope:$bio',
          'track_scope:$chem',
        ]),
      );
    });

    test('a track without a blueprint writes no blueprint row', () async {
      await repo.restoreFromServer(CustomTrackRow.fromJson(json()));

      expect(await CustomBlueprintRepository(db).exists(examId), isFalse);
      expect(
        (await recorded()).where((r) => r.startsWith('custom_blueprints')),
        isEmpty,
      );
    });

    test('local wins: a track already here is left exactly as it is', () async {
      await db.into(db.customTrackMetaLocal).insert(
            CustomTrackMetaLocalCompanion.insert(
              examId: examId,
              name: 'Local name',
            ),
          );
      await db.into(db.trackScopeLocal).insert(
            TrackScopeLocalCompanion.insert(
              examId: examId,
              topicId: 'topic_upcat_algebra',
            ),
          );

      final restored = await repo.restoreFromServer(
        CustomTrackRow.fromJson(json(blueprint: blueprintJson)),
      );

      expect(restored, isFalse);
      expect(await repo.name(examId), 'Local name');
      expect(await repo.excludedTopicIds(examId), {'topic_upcat_algebra'});
      expect(await CustomBlueprintRepository(db).exists(examId), isFalse);
      expect(await recorded(), isEmpty);
    });

    test('a track with no name is not restored', () async {
      final restored = await repo
          .restoreFromServer(CustomTrackRow.fromJson(json(name: null)));

      expect(restored, isFalse);
      expect(await db.select(db.customTrackMetaLocal).get(), isEmpty);
      expect(await recorded(), isEmpty);
    });

    test('the restored blueprint is sent back unchanged', () async {
      await repo.restoreFromServer(
        CustomTrackRow.fromJson(json(blueprint: blueprintJson)),
      );

      expect(await repo.blueprintPayload(examId), blueprintJson);
    });
  });

  group('CustomTrackRow.fromJson', () {
    const examId = 'exam_custom_6f1d0a52-3c1b-4c0e-8a52-0f6a3d2c9b11';
    Map<String, Object?> good() => {
          'examId': examId,
          'name': 'Mine',
          'excludedTopicIds': ['a'],
          'excludedLessonIds': <String>[],
          'blueprint': null,
          'createdAt': 1,
          'updatedAt': 2,
        };

    test('reads a row the server wrote', () {
      final row = CustomTrackRow.fromJson(good());
      expect(row.examId, examId);
      expect(row.name, 'Mine');
      expect(row.excludedTopicIds, {'a'});
      expect(row.blueprint, isNull);
      expect(row.createdAt, 1);
    });

    test('accepts whole numbers that arrive as doubles', () {
      final row = CustomTrackRow.fromJson(
        good()
          ..['createdAt'] = 1762243200000.0
          ..['blueprint'] = {
            'sectionsJson': '[]',
            'totalQuestions': 5.0,
            'totalMinutes': 6.0,
            'sectionsTimedSeparately': false,
            'updatedAt': 7.0,
          },
      );
      expect(row.createdAt, 1762243200000);
      expect(row.blueprint!.totalQuestions, 5);
    });

    final bad = <String, void Function(Map<String, Object?>)>{
      'not a map': (_) {},
      'no exam id': (m) => m.remove('examId'),
      'exam id not text': (m) => m['examId'] = 7,
      'a listed exam id': (m) => m['examId'] = 'exam_cse_pro',
      'name a number': (m) => m['name'] = 3,
      'topics not a list': (m) => m['excludedTopicIds'] = 'a',
      'a topic not text': (m) => m['excludedTopicIds'] = [1],
      'lessons missing': (m) => m.remove('excludedLessonIds'),
      'created at text': (m) => m['createdAt'] = '1',
      'created at fractional': (m) => m['createdAt'] = 1.5,
      'updated at missing': (m) => m.remove('updatedAt'),
      'blueprint not a map': (m) => m['blueprint'] = 'x',
      'blueprint sections not text': (m) => m['blueprint'] = {
            'sectionsJson': 1,
            'totalQuestions': 1,
            'totalMinutes': 1,
            'sectionsTimedSeparately': false,
            'updatedAt': 1,
          },
      'blueprint flag not a bool': (m) => m['blueprint'] = {
            'sectionsJson': '[]',
            'totalQuestions': 1,
            'totalMinutes': 1,
            'sectionsTimedSeparately': 'no',
            'updatedAt': 1,
          },
    };
    for (final entry in bad.entries) {
      test('refuses ${entry.key}', () {
        final map = good();
        entry.value(map);
        final input = entry.key == 'not a map' ? 'x' : map;
        expect(() => CustomTrackRow.fromJson(input), throwsFormatException);
      });
    }
  });
}
