import 'package:pantas/features/mock_exam/data/mock_attempt_repo.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_sample.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_snapshot.dart';

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
        sampledQuestionsJson: const MockSessionSnapshotCodec().encodeSample(
          request.sample,
          currentPartIndex: 0,
          partStartedAtSeconds: 0,
          partsTimedSeparately: request.partsTimedSeparately,
          parts: request.parts,
        ),
        startedAt: request.startedAt,
      ),
    );
    return (await _repo.findById(request.id))!;
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
    required this.partsTimedSeparately,
    required this.parts,
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
  final bool partsTimedSeparately;
  final List<MockPersistedPart> parts;
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
