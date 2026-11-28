import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/first_run/data/first_run_store.dart';
import 'package:pantas/features/first_run/domain/first_run_content.dart';
import 'package:pantas/features/first_run/domain/first_run_progress.dart';

final firstRunStoreProvider = Provider<FirstRunStore>(
  (ref) => FirstRunStore(ref.watch(appPreferencesRepositoryProvider)),
);

/// The account id the run belongs to, or null when nobody is signed in.
final _firstRunUidProvider = FutureProvider<String?>((ref) async {
  final state = await ref.watch(authStateProvider.future);
  return switch (state) {
    SignedInAuthState(:final user) => user.uid,
    AnonymousAuthState(:final uid) => uid,
    _ => null,
  };
});

/// The open run for this account and exam, or null when none is open. The
/// router reads it: while it is non-null, Home opens the run instead.
final firstRunPendingProvider = FutureProvider<FirstRunProgress?>((ref) async {
  final uid = await ref.watch(_firstRunUidProvider.future);
  final focus = await ref.watch(activeExamFocusProvider.future);
  final exam = focus.exam;
  if (uid == null || exam == null) return null;
  return ref.watch(firstRunStoreProvider).load(uid: uid, examId: exam.id);
});

/// Called when setup ends. Opens the run and returns true when the exam has a
/// fixed lesson and no assessment result; otherwise returns false and the
/// caller goes to Home as before (plan rulings 1 and 2).
final firstRunOpenerProvider = Provider<Future<bool> Function()>(
  (ref) => () async {
    final uid = await ref.read(_firstRunUidProvider.future);
    final exam = (await ref.read(activeExamFocusProvider.future)).exam;
    if (uid == null || exam == null) return false;
    if (firstRunContentFor(exam.id) == null) return false;
    final assessed = await ref
        .read(assessmentRepositoryProvider)
        .hasCompletedForExam(exam.id);
    if (assessed) return false;
    await ref.read(firstRunStoreProvider).open(uid: uid, examId: exam.id);
    ref.invalidate(firstRunPendingProvider);
    await ref.read(firstRunPendingProvider.future);
    return true;
  },
);

/// Done or Skip: ends the run so Home opens as Home.
final firstRunFinisherProvider = Provider<Future<void> Function()>(
  (ref) => () async {
    await ref.read(firstRunStoreProvider).clear();
    ref.invalidate(firstRunPendingProvider);
    await ref.read(firstRunPendingProvider.future);
  },
);
