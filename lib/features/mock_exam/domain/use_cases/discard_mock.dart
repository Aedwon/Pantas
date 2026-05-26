import 'package:cse_cet_reviewer/features/mock_exam/data/mock_attempt_repo.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_attempt.dart';

class DiscardMock {
  const DiscardMock({required MockAttemptRepo repo}) : _repo = repo;

  final MockAttemptRepo _repo;

  Future<MockAttempt> call({
    required String attemptId,
    required DateTime discardedAt,
  }) async {
    await _repo.discard(attemptId, discardedAt);
    return (await _repo.findById(attemptId))!;
  }
}
