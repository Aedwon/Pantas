import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

const _customId = 'exam_custom_6f1d0a52-3c1b-4c0e-8a52-0f6a3d2c9b11';

/// What `CustomBlueprint.toSectionsJson` writes for a 100 question paper over
/// two topics. The test below saves through the real writer and compares, so
/// this cannot drift from it.
final _wholeExamSections = [
  '[{"id":"section_all","name":"Whole exam",',
  '"questionCount":100,"suggestedMinutes":120,',
  '"topicIds":["topic_upcat_algebra","topic_upcat_chem"]}]',
].join();

class _Setup {
  _Setup(this.db, this.content, this.container, this.calls);
  final AppDatabase db;
  final ContentDatabase content;
  final ProviderContainer container;
  final List<(String, Map<String, Object?>)> calls;
}

Future<_Setup> _setup(String examId) async {
  final db = inMemoryDatabase();
  final content = inMemoryContentDatabase();
  addTearDown(db.close);
  addTearDown(content.close);
  await SyncActiveContextStore(db).clearStable();
  await AppPreferencesRepository(db).setSelectedExamId(examId);
  final calls = <(String, Map<String, Object?>)>[];
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      contentDatabaseProvider.overrideWithValue(content),
      authStateProvider.overrideWith(
        (_) => Stream.value(const AuthState.anonymous(uid: 'original')),
      ),
      activeExamFocusProvider.overrideWith(
        (_) async => ActiveExamFocus.selected(buildExam(id: examId)),
      ),
      studyApiProvider.overrideWithValue(
        StudyApi((name, data) async {
          calls.add((name, data));
          return <String, Object?>{};
        }),
      ),
    ],
  );
  addTearDown(container.dispose);
  await container.read(authStateProvider.future);
  await container.read(activeExamFocusProvider.future);
  return _Setup(db, content, container, calls);
}

Future<void> _storeTrack(_Setup setup, {String name = 'Barangay exam'}) =>
    setup.db.into(setup.db.customTrackMetaLocal).insert(
          CustomTrackMetaLocalCompanion.insert(examId: _customId, name: name),
        );

Future<Map<String, Object?>> _publishedSettings(_Setup setup) async {
  final sent = Completer<Map<String, Object?>>();
  final timer = Timer(const Duration(seconds: 3), () {
    if (!sent.isCompleted) sent.completeError(StateError('Nothing was sent'));
  });
  addTearDown(timer.cancel);
  final publication = await setup.container.read(studySettingsCaptureProvider)(
    examId: setup.container.read(activeExamFocusProvider).value!.exam!.id,
  );
  await publication();
  while (!sent.isCompleted) {
    final match = setup.calls.where((c) => c.$1 == 'setExamSettings');
    if (match.isNotEmpty) sent.complete(match.first.$2);
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  return sent.future;
}

void main() {
  test('settings for a custom exam carry its name and saved paper', () async {
    final setup = await _setup(_customId);
    await _storeTrack(setup);
    await CustomBlueprintRepository(setup.db).save(
      const CustomBlueprint(
        examId: _customId,
        totalQuestions: 100,
        totalMinutes: 120,
      ),
      topicsBySubject: {
        'subj_math': ['topic_upcat_algebra'],
        'subj_sci': ['topic_upcat_chem'],
      },
      now: DateTime.utc(2026, 11, 4, 8),
    );

    final sent = await _publishedSettings(setup);

    expect(sent['expectedUid'], 'original');
    expect(sent['examId'], _customId);
    expect(sent['customTrack'], {
      'name': 'Barangay exam',
      'blueprint': {
        'sectionsJson': _wholeExamSections,
        'totalQuestions': 100,
        'totalMinutes': 120,
        'sectionsTimedSeparately': false,
        'updatedAt': DateTime.utc(2026, 11, 4, 8).millisecondsSinceEpoch,
      },
    });
    expect(sent['excludedTopicIds'], isEmpty);
  });

  test('a saved paper the server would refuse is left out of the publish',
      () async {
    final setup = await _setup(_customId);
    await _storeTrack(setup);
    await setup.db.into(setup.db.customBlueprintsLocal).insert(
          CustomBlueprintsLocalCompanion.insert(
            examId: _customId,
            totalQuestions: 50,
            totalMinutes: 60,
            sectionsJson: '[]',
            updatedAt: DateTime.utc(2025),
          ),
        );

    final sent = await _publishedSettings(setup);

    expect(sent['customTrack'], {'name': 'Barangay exam'});
    expect(
      await setup.db.select(setup.db.customBlueprintsLocal).get(),
      hasLength(1),
    );
  });

  test('a custom exam with no stored paper sends only its name', () async {
    final setup = await _setup(_customId);
    await _storeTrack(setup);

    final sent = await _publishedSettings(setup);

    expect(sent['customTrack'], {'name': 'Barangay exam'});
  });

  test('settings for a listed exam carry no custom block', () async {
    final setup = await _setup('exam_cse_pro');

    final sent = await _publishedSettings(setup);

    expect(sent.containsKey('customTrack'), isFalse);
  });

  test('stored observations for a custom exam are delivered', () async {
    final setup = await _setup(_customId);
    await AttemptsRepository(setup.db).save(
      Attempt(
        id: 'att',
        examId: _customId,
        origin: 'drill',
        startedAt: DateTime(2026, 10, 24, 12),
        completedAt: DateTime(2026, 10, 24, 13),
        items: const [
          AttemptItem(
            questionId: 'q',
            questionVersion: 1,
            chosenChoiceId: 'a',
            correctChoiceId: 'a',
            responseMs: 1000,
          ),
        ],
      ),
    );

    await setup.container.read(studyObservationDeliveryProvider)();

    final sessions = setup.calls.where((c) => c.$1 == 'ingestSession');
    expect(sessions, hasLength(1));
    expect(sessions.single.$2['examId'], _customId);
    expect(sessions.single.$2['expectedUid'], 'original');
    expect(sessions.single.$2['sessionId'], 'att');
  });
}
