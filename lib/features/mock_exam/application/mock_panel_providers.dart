import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_availability.dart';

/// The most recent completed or forfeited attempt for this exam, which is the
/// one the panel's figures describe.
///
/// `lastCooldownAttempt` is exactly this query: newest first, filtered to the
/// two statuses that end an attempt. It is named for the cooldown because that
/// was its first caller, not because it is narrower.
final lastSubmittedMockProvider =
    FutureProvider.family<MockAttempt?, MockAvailabilityRequest>(
  (ref, request) async {
    if (ref.watch(mockUsesServerProvider)) {
      final reply = await ref
          .watch(serverMockAvailabilityProvider(request.examId).future);
      final id = reply['lastMockId'];
      if (id == null) return null;
      final result =
          await ref.watch(serverMockResultProvider(id as String).future);
      return serverMockHistoryEntry(
        result,
        ref.read(serverMockIdentityProvider)!,
      ).attempt;
    }
    return ref
        .watch(mockAttemptRepoProvider)
        .lastCooldownAttempt(request.userId, request.examId);
  },
);

final customMockSummaryProvider =
    FutureProvider.family<CustomMockSummary?, ExamId>((ref, examId) async {
  final repo = CustomBlueprintRepository(ref.watch(appDatabaseProvider));
  final row = await repo.read(examId);
  if (row == null) return null;
  return CustomMockSummary(
    questions: row.totalQuestions,
    minutes: row.totalMinutes,
  );
});

/// Sends the settings of a custom exam again, once, when the server has no
/// paper for it but this browser does. That happens when an earlier send was
/// refused or never left the browser. When the send is done the server's
/// status is read again.
///
/// The provider keeps its result, so a rebuild, a re-read or a failed send
/// never starts a second send in the same session. A failure leaves the saved
/// paper on screen: the student can change it, and that save sends again.
final customMockRepairProvider = FutureProvider.family<void, ExamId>((
  ref,
  examId,
) async {
  final publication =
      await ref.read(studySettingsCaptureProvider)(examId: examId);
  await publication();
  await publication.settled;
  ref.invalidate(serverMockAvailabilityProvider(examId));
});
