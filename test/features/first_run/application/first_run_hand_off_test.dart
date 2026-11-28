import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/first_run/application/first_run_providers.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

Future<(ProviderContainer, AppDatabase)> _container({
  required String examId,
  AuthState? auth,
}) async {
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      authStateProvider.overrideWith(
        (ref) => Stream.value(
          auth ??
              const AuthState.signedIn(
                user: AuthUser(uid: 'u1', email: '', displayName: ''),
              ),
        ),
      ),
      activeExamFocusProvider.overrideWith(
        (ref) async => ActiveExamFocus.selected(buildExam(id: examId)),
      ),
    ],
  );
  addTearDown(container.dispose);
  await container.read(authStateProvider.future);
  return (container, db);
}

void main() {
  test('opens the run for an exam with a fixed lesson and no assessment',
      () async {
    final (c, _) = await _container(examId: 'exam_upcat');
    expect(await c.read(firstRunOpenerProvider)(), isTrue);
    final pending = await c.read(firstRunPendingProvider.future);
    expect(pending, isNotNull);
    expect(pending!.examId, 'exam_upcat');
    expect(pending.uid, 'u1');
  });

  test('an exam with no fixed lesson goes straight to Home', () async {
    final (c, _) = await _container(examId: 'exam_dost_sei');
    expect(await c.read(firstRunOpenerProvider)(), isFalse);
    expect(await c.read(firstRunPendingProvider.future), isNull);
  });

  test('a learner who already has an assessment result is not offered it',
      () async {
    final (c, db) = await _container(examId: 'exam_upcat');
    await AssessmentRepository(db).saveResult(
      'exam_upcat',
      DateTime(2026, 11, 25),
      const [TopicScore(topicId: 't', correct: 1, total: 2)],
    );
    expect(await c.read(firstRunOpenerProvider)(), isFalse);
    expect(await c.read(firstRunPendingProvider.future), isNull);
  });

  test('a signed-out device opens no run', () async {
    final (c, _) = await _container(
      examId: 'exam_upcat',
      auth: const AuthState.signedOut(),
    );
    expect(await c.read(firstRunOpenerProvider)(), isFalse);
  });

  test('finishing clears the run', () async {
    final (c, _) = await _container(examId: 'exam_upcat');
    await c.read(firstRunOpenerProvider)();
    await c.read(firstRunFinisherProvider)();
    expect(await c.read(firstRunPendingProvider.future), isNull);
  });
}
