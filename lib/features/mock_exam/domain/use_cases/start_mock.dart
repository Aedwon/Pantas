import 'dart:convert';

import 'package:cse_cet_reviewer/features/mock_exam/data/mock_attempt_repo.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_attempt.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_sample.dart';

class StartMock {
  const StartMock({required MockAttemptRepo repo}) : _repo = repo;

  final MockAttemptRepo _repo;

  Future<MockAttempt> call(MockStartRequest request) async {
    if (!request.availability.isAvailable) {
      throw MockStartBlockedException(request.availability.blockedReason!);
    }

    await _repo.insertStart(
      MockAttemptStart(
        id: request.id,
        userId: request.userId,
        examId: request.examId,
        blueprintId: request.blueprintId,
        blueprintName: request.blueprintName,
        durationMinutes: request.durationMinutes,
        strictMode: request.strictMode,
        sampledQuestionsJson: _sampleToJson(request.sample),
        startedAt: request.startedAt,
      ),
    );
    return (await _repo.findById(request.id))!;
  }

  String _sampleToJson(MockSample sample) {
    return jsonEncode([
      for (final section in sample.sections)
        {
          'sectionId': section.sectionId,
          'name': section.name,
          'questionIds': section.questionIds,
        },
    ]);
  }
}

class MockStartRequest {
  const MockStartRequest({
    required this.id,
    required this.userId,
    required this.examId,
    required this.blueprintId,
    required this.blueprintName,
    required this.durationMinutes,
    required this.strictMode,
    required this.sample,
    required this.startedAt,
    this.availability = const MockStartAvailability(),
  });

  final String id;
  final String userId;
  final String examId;
  final String blueprintId;
  final String blueprintName;
  final int durationMinutes;
  final bool strictMode;
  final MockSample sample;
  final DateTime startedAt;
  final MockStartAvailability availability;
}

class MockStartAvailability {
  const MockStartAvailability({this.blockedReason});

  final String? blockedReason;

  bool get isAvailable => blockedReason == null;
}

class MockStartBlockedException implements Exception {
  const MockStartBlockedException(this.reason);

  final String reason;

  @override
  String toString() => 'MockStartBlockedException: $reason';
}
