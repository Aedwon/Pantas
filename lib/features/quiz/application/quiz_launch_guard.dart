import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

/// Retains the original owner across content and UI waits.
Future<Future<bool> Function()> captureQuizLaunchGuard(
  Ref ref, {
  required String examId,
  required bool Function() isAlive,
}) async {
  if (!isAlive()) {
    throw StateError('Quiz controller is unavailable');
  }
  final db = ref.read(appDatabaseProvider);
  final preparer = ref.read(todayQuizPreparerProvider);
  final lifetime = preparer.accountLifetimeToken;
  final auth = ref.read(authStateProvider).unwrapPrevious().asData?.value;
  final uid = switch (auth) {
    AnonymousAuthState(:final uid) => uid,
    SignedInAuthState(:final user) => user.uid,
    _ => null,
  };
  bool current() =>
      isAlive() &&
      lifetime != null &&
      uid != null &&
      identical(ref.read(appDatabaseProvider), db) &&
      identical(ref.read(todayQuizPreparerProvider), preparer) &&
      preparer.accountLifetimeToken == lifetime &&
      ref.read(authStateProvider).unwrapPrevious().asData?.value == auth &&
      ref
              .read(activeExamFocusProvider)
              .unwrapPrevious()
              .asData
              ?.value
              .exam
              ?.id ==
          examId;
  if (!current()) throw StateError('Quiz account is unavailable');
  final contexts = SyncActiveContextStore(db);
  final original = await contexts.readSnapshot();
  if (!current() ||
      (original?.context != null && original!.context!.uid != uid)) {
    throw StateError('Quiz account changed');
  }
  return () async {
    if (!current()) return false;
    final snapshot = await contexts.readSnapshot();
    return current() && snapshot?.token == original?.token;
  };
}
