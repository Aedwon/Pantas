import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/study_api.dart';
import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  test('authoritative insight reader sends original account and exact exam',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await SyncActiveContextStore(db).clearStable();
    final calls = <Map<String, Object?>>[];
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'original')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        studyApiProvider.overrideWithValue(
          StudyApi((name, data) async {
            calls.add(data);
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
    expect(calls.single['expectedUid'], 'original');
    expect(calls.single['examId'], 'e');
  });
}
