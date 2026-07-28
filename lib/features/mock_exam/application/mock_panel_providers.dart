import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/mock_exam/application/mock_availability_provider.dart';
import 'package:cse_cet_reviewer/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_attempt.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_availability.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/widgets/mock_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The most recent completed or forfeited attempt for this exam, which is the
/// one the panel's figures describe.
///
/// `lastCooldownAttempt` is exactly this query: newest first, filtered to the
/// two statuses that end an attempt. It is named for the cooldown because that
/// was its first caller, not because it is narrower.
final lastSubmittedMockProvider =
    FutureProvider.family<MockAttempt?, MockAvailabilityRequest>(
  (ref, request) => ref
      .watch(mockAttemptRepoProvider)
      .lastCooldownAttempt(request.userId, request.examId),
);

final customMockSummaryProvider = FutureProvider.family<CustomMockSummary?, ExamId>((ref, examId) async {
  final repo = CustomBlueprintRepository(ref.watch(appDatabaseProvider));
  final row = await repo.read(examId);
  if (row == null) return null;
  return CustomMockSummary(
    questions: row.totalQuestions,
    minutes: row.totalMinutes,
  );
});
