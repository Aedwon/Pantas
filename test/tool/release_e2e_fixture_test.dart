import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';

import '../../integration_test/release/support/release_harness.dart';
import '../../integration_test/release/support/test_content_fixture.dart';
import '../../integration_test/release/support/test_content_seed.dart';

void main() {
  group('release E2E deterministic fixture', () {
    test('uses production export document keys and stable human-readable IDs',
        () {
      final document = releaseTestContentDocument();

      expect(
        document.keys,
        containsAll(<String>[
          'exam',
          'subject',
          'topic',
          'lesson',
          'question',
          'mockBlueprint',
          'mockExam',
        ]),
      );
      expect(_single(document, 'exam')['_id'], ReleaseTestContentIds.exam);
      expect(_single(document, 'subject')['exam'],
          {'_ref': ReleaseTestContentIds.exam});
      expect(_single(document, 'topic')['subject'],
          {'_ref': ReleaseTestContentIds.subject});
      expect(_single(document, 'lesson')['topic'],
          {'_ref': ReleaseTestContentIds.topic});

      final questions = _list(document, 'question');
      expect(questions, hasLength(3));
      expect(
        questions.map((question) => question['_id']),
        <String>[
          ReleaseTestContentIds.question1,
          ReleaseTestContentIds.question2,
          ReleaseTestContentIds.question3,
        ],
      );
      for (final question in questions) {
        expect(question['topic'], {'_ref': ReleaseTestContentIds.topic});
        expect(question['examIds'], <Object>[
          {'_ref': ReleaseTestContentIds.exam}
        ]);
        expect(question['choices'], isA<List<Object?>>());
      }

      final blueprint = _single(document, 'mockBlueprint');
      expect(blueprint['schemaVersion'], 2);
      expect(blueprint['exam'], {'_ref': ReleaseTestContentIds.exam});
      final sections = blueprint['sections']! as List<Object?>;
      expect(sections, hasLength(1));
      expect(
        (sections.single! as Map<String, Object?>)['topicIds'],
        <String>[ReleaseTestContentIds.topic],
      );
      expect(
        _single(document, 'mockExam')['blueprint'],
        {'_ref': ReleaseTestContentIds.mockBlueprint},
      );

      expect(jsonEncode(document), isNot(contains('INSERT INTO')));
    });

    test('support helpers contain no direct SQLite row-seeding API', () {
      for (final path in <String>[
        'integration_test/release/support/test_content_fixture.dart',
        'integration_test/release/support/test_content_seed.dart',
        'integration_test/release/support/release_harness.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(source, isNot(contains('.into(')), reason: path);
        expect(source, isNot(contains('customStatement(')), reason: path);
        expect(source.toUpperCase(), isNot(contains('INSERT INTO')),
            reason: path);
      }
    });

    test('round trip uses seed writer, SeedInstaller, and content providers',
        () async {
      final root =
          await Directory.systemTemp.createTemp('pantas-release-e2e-fixture-');
      addTearDown(() async {
        if (root.existsSync()) await root.delete(recursive: true);
      });
      final installedFile = File('${root.path}/installed/content.db');

      final installation = await installReleaseTestContent(
        buildDirectory: Directory('${root.path}/build'),
        destinationFile: () async => installedFile,
        openContent: () async => ContentDatabase(
          NativeDatabase.createInBackground(installedFile),
        ),
      );
      addTearDown(installation.dispose);

      expect(installation.exportJson.existsSync(), isTrue);
      expect(installation.generatedSeed.existsSync(), isTrue);
      expect(installedFile.existsSync(), isTrue);
      expect(
          await installation.providerContainer
              .read(examRepoProvider)
              .findById(ReleaseTestContentIds.exam),
          isNotNull);
      expect(
          await installation.providerContainer
              .read(lessonRepoProvider)
              .findById(ReleaseTestContentIds.lesson),
          isNotNull);
      expect(
          await installation.providerContainer
              .read(mockBlueprintRepoProvider)
              .byExam(ReleaseTestContentIds.exam),
          isNotEmpty);
      expect(
          await installation.providerContainer
              .read(mockExamRepoProvider)
              .byBlueprint(ReleaseTestContentIds.mockBlueprint),
          isNotEmpty);
    });
  });

  group('release harness', () {
    test('reconstruction disposes app state and opens new database objects',
        () async {
      var appOpenCount = 0;
      var contentOpenCount = 0;
      var appTreeDisposed = false;

      Future<AppDatabase> openApp() async {
        appOpenCount++;
        return _CloseTrackingAppDatabase();
      }

      Future<ContentDatabase> openContent() async {
        contentOpenCount++;
        return _CloseTrackingContentDatabase();
      }

      final harness = ReleaseHarness(
        openAppDatabase: openApp,
        openContentDatabase: openContent,
      );
      addTearDown(harness.dispose);
      await harness.openDatabases();
      final firstApp = harness.appDatabase as _CloseTrackingAppDatabase;
      final firstContent =
          harness.contentDatabase as _CloseTrackingContentDatabase;

      await harness.reconstruct(
        disposeAppTree: () async {
          appTreeDisposed = true;
        },
      );

      expect(appTreeDisposed, isTrue);
      expect(harness.appDatabase, isNot(same(firstApp)));
      expect(harness.contentDatabase, isNot(same(firstContent)));
      expect(appOpenCount, 2);
      expect(contentOpenCount, 2);
      expect(firstApp.closed, isTrue);
      expect(firstContent.closed, isTrue);
    });

    test('waitUntil is bounded and reports useful timeout diagnostics',
        () async {
      var clock = DateTime.utc(2026, 9, 5, 16);
      var attempts = 0;
      final deadline = clock.add(const Duration(milliseconds: 250));

      Future<void> fakeDelay(Duration duration) async {
        clock = clock.add(duration);
      }

      await expectLater(
        waitUntil(
          () async {
            attempts++;
            return false;
          },
          deadline: deadline,
          diagnostics: () => 'fixture rows missing after $attempts attempts',
          pollInterval: const Duration(milliseconds: 100),
          now: () => clock,
          delay: fakeDelay,
        ),
        throwsA(
          isA<TimeoutException>()
              .having((error) => error.message, 'message',
                  contains('fixture rows missing'))
              .having(
                  (error) => error.message, 'message', contains('deadline')),
        ),
      );
      expect(attempts, greaterThanOrEqualTo(2));
    });

    test('waitUntil stops polling as soon as the predicate succeeds', () async {
      var clock = DateTime.utc(2026, 9, 5, 16);
      var attempts = 0;

      await waitUntil(
        () async => ++attempts == 3,
        deadline: clock.add(const Duration(seconds: 1)),
        diagnostics: () => 'attempts=$attempts',
        pollInterval: const Duration(milliseconds: 100),
        now: () => clock,
        delay: (duration) async {
          clock = clock.add(duration);
        },
      );

      expect(attempts, 3);
    });
  });
}

Map<String, Object?> _single(Map<String, Object?> document, String key) =>
    _list(document, key).single;

List<Map<String, Object?>> _list(Map<String, Object?> document, String key) =>
    (document[key]! as List<Object?>).cast<Map<String, Object?>>();

class _CloseTrackingAppDatabase extends AppDatabase {
  _CloseTrackingAppDatabase() : super(NativeDatabase.memory());

  bool closed = false;

  @override
  Future<void> close() {
    closed = true;
    return super.close();
  }
}

class _CloseTrackingContentDatabase extends ContentDatabase {
  _CloseTrackingContentDatabase() : super(NativeDatabase.memory());

  bool closed = false;

  @override
  Future<void> close() {
    closed = true;
    return super.close();
  }
}
