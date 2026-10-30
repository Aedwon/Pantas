import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final local in [true, false]) {
    test('missing settings recovers or opens exam onboarding: $local',
        () async {
      final db = inMemoryDatabase();
      final content = inMemoryContentDatabase();
      addTearDown(content.close);
      addTearDown(db.close);
      await SyncActiveContextStore(db).clearStable();
      await AppPreferencesRepository(db).setSelectedExamId('e');
      if (local) {
        await DriftSettingsRepository(db)
            .updateStudyDays(StudyDays(const {1, 3, 5}));
      }
      final names = <String>[];
      var saved = false;
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          authStateProvider.overrideWith(
            (_) => Stream.value(const AuthState.anonymous(uid: 'u')),
          ),
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          studyApiProvider.overrideWithValue(
            StudyApi((name, data) async {
              names.add(name);
              if (name == 'setExamSettings') {
                expect(data['studyDays'], [1, 3, 5]);
                saved = true;
                return <String, Object?>{};
              }
              if (!saved) {
                throw FirebaseFunctionsException(
                  code: 'failed-precondition',
                  message: 'Set your exam first.',
                );
              }
              return {'examId': 'e'};
            }),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authStateProvider.future);
      await container.read(activeExamFocusProvider.future);
      final reader =
          await container.read(studySnapshotReaderProvider('e').future);
      if (local) {
        expect(await reader.request.read('getRoadmap'), {'examId': 'e'});
        expect(names, ['getRoadmap', 'setExamSettings', 'getRoadmap']);
        saved = false;
        expect(await reader.request.read('getRoadmap'), {'examId': 'e'});
        expect(names.where((name) => name == 'setExamSettings'), hasLength(2));

        expect(container.read(studyNeedsExamSettingsProvider), false);
      } else {
        await expectLater(
          reader.request.read('getRoadmap'),
          throwsA(isA<FirebaseFunctionsException>()),
        );
        expect(names, ['getRoadmap']);
        expect(container.read(studyNeedsExamSettingsProvider), true);
      }
    });
  }
  test(
      'explicit settings send lesson exclusions beside topics '
      'for the original owner', () async {
    final db = inMemoryDatabase();
    final content = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(content.close);
    await SyncActiveContextStore(db).clearStable();
    await AppPreferencesRepository(db).setSelectedExamId('e');
    final sent = Completer<Map<String, Object?>>();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'original')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        studyApiProvider.overrideWithValue(
          StudyApi((name, data) async {
            if (name == 'setExamSettings') sent.complete(data);
            return <String, Object?>{};
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    final captured =
        await container.read(studySettingsCaptureProvider)(examId: 'e');
    await captured.apply(
      () => container
          .read(customTrackRepositoryProvider)
          .setExcluded(examId: 'e', topicIds: {'t'}, lessonIds: {'l2', 'l1'}),
    );
    final payload = await sent.future;
    expect(payload['expectedUid'], 'original');
    expect(payload['examId'], 'e');
    expect(payload['excludedTopicIds'], ['t']);
    expect(payload['excludedLessonIds'], ['l1', 'l2']);
  });

  test('native delivery sends stored observations without opening a web page',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await SyncActiveContextStore(db).clearStable();
    await AppPreferencesRepository(db).setSelectedExamId('e');
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'lesson',
            readAt: DateTime.utc(2026, 10, 24),
          ),
        );
    final calls = <String>[];
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        studyUsesServerProvider.overrideWithValue(false),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'original')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        studyApiProvider.overrideWithValue(
          StudyApi((name, data) async {
            calls.add(name);
            expect(data['expectedUid'], 'original');
            return <String, Object?>{};
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    final subscription =
        container.listen(studyDeliveryLifecycleProvider, (_, __) {});
    addTearDown(subscription.close);
    await container.pump();
    for (var i = 0; i < 20 && calls.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(calls, ['recordLessonRead']);
  });

  test('authoritative insight reader sends original account and exact exam',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await SyncActiveContextStore(db).clearStable();
    final calls = <Map<String, Object?>>[];
    final names = <String>[];
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        trackScopeProvider('e').overrideWith((_) async => {}),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'original')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        studyApiProvider.overrideWithValue(
          StudyApi((name, data) async {
            calls.add(data);
            names.add(name);
            return {
              'examId': 'e',
              'serverNow': 123,
              'accessRecheckAt': null,
              'proCovered': false,
              'revision': 'v1',
              'profile': null,
              'performance': {
                'overall': {'correct': 1, 'answered': 2},
                'subjects': <Object?>[],
                'lessonLevelAvailable': false,
              },
            };
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    final subscription =
        container.listen(serverStudyInsightsProvider('e'), (_, __) {});
    addTearDown(subscription.close);
    final result =
        await container.read(serverStudyInsightsProvider('e').future);
    expect(result.answered, 2);
    expect(names, ['getStudyInsights']);
    expect(calls.every((c) => c['expectedUid'] == 'original'), isTrue);
    expect(calls.every((c) => c['examId'] == 'e'), isTrue);
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'lesson',
            readAt: DateTime.utc(2026, 10, 24),
          ),
        );
    final refreshed = Completer<void>();
    final refreshSubscription =
        container.listen(serverStudyInsightsProvider('e'), (_, next) {
      if (names.length >= 3 && next.hasValue && !refreshed.isCompleted) {
        refreshed.complete();
      }
    });
    addTearDown(refreshSubscription.close);
    container.read(roadmapRevisionProvider.notifier).bump();
    await container.pump();
    await refreshed.future.timeout(const Duration(seconds: 3));
    expect(names, [
      'getStudyInsights',
      'recordLessonRead',
      'getStudyInsights',
    ]);
  });
}
