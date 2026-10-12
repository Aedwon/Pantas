import 'dart:convert';

import 'package:pantas/features/mock_exam/data/mock_attempt_repo.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';

class SubmitMock {
  const SubmitMock({required MockAttemptRepo repo}) : _repo = repo;

  final MockAttemptRepo _repo;

  Future<MockAttempt> call({
    required String attemptId,
    required MockResults results,
    required DateTime submittedAt,
    MockAttemptStatus status = MockAttemptStatus.completed,
  }) async {
    await _repo.submit(
      attemptId: attemptId,
      status: status,
      results: results,
      sectionResultsJson: _sectionResultsJson(results),
      submittedAt: submittedAt,
    );
    return (await _repo.findById(attemptId))!;
  }

  String _sectionResultsJson(MockResults results) {
    return jsonEncode({
      'sections': [
        for (final section in results.sections)
          {
            'sectionId': section.sectionId,
            'name': section.name,
            'correct': section.correct,
            'wrong': section.wrong,
            'blank': section.blank,
            'total': section.total,
            'retiredCount': section.retiredCount,
            'timeSeconds': section.timeSeconds,
          },
      ],
    });
  }
}
