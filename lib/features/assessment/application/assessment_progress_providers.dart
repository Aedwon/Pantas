import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/assessment/data/assessment_progress_store.dart';
import 'package:pantas/features/assessment/domain/models/assessment_progress.dart';

final assessmentProgressStoreProvider = Provider<AssessmentProgressStore>(
  (ref) => AssessmentProgressStore(ref.watch(appPreferencesRepositoryProvider)),
);

/// Who owns saved assessment progress on this device: the account that owns
/// the local data, or `local` before any account is known.
Future<String> assessmentProgressOwner(AppDatabase db) async {
  final snapshot = await SyncActiveContextStore(db).readSnapshot();
  return snapshot?.context?.uid ?? snapshot?.rememberedContext?.uid ?? 'local';
}

final assessmentProgressOwnerProvider =
    FutureProvider.autoDispose<String>((ref) {
  // A sign in or out changes who owns the local data.
  ref.watch(authStateProvider);
  return assessmentProgressOwner(ref.watch(appDatabaseProvider));
});

/// The assessment this learner left part way through for the exam, limited to
/// questions still in the bank. Null when nothing is saved or none of the
/// saved questions remains, so every surface falls back to "Start".
///
/// The assessment page invalidates it on each save, on leaving and when the
/// result saves.
final assessmentProgressProvider = FutureProvider.autoDispose
    .family<AssessmentProgress?, ExamId>((ref, examId) async {
  final uid = await ref.watch(assessmentProgressOwnerProvider.future);
  final saved =
      await ref.watch(assessmentProgressStoreProvider).load(uid, examId);
  if (saved == null) return null;
  final active = await ref
      .watch(contentRepositoryProvider)
      .activeQuestionIdsAmong(saved.questionIds);
  return saved.keepOnly(active);
});
