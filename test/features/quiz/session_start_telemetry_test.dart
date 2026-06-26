import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';
import 'package:cse_cet_reviewer/core/telemetry/telemetry.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_ordering.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_preferences.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_today_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('StartTodaySession emits sessionStarted telemetry event', () async {
    final sink = RecordingTelemetrySink();
    final content = FakeContentRepository();
    final sessions = FakeQuizSessionRepository();
    final useCase = StartTodaySession(
      content: content,
      sessions: sessions,
      telemetry: sink,
    );

    final result = await useCase(
      userId: 'u1',
      examId: 'cse_prof',
      preferences: QuizPreferences(
        ordering: QuizOrdering.blocked,
        sessionLength: 10,
        newCardCap: 20,
      ),
      now: DateTime(2026, 8, 4),
      topicId: 't1',
    );

    expect(result, isA<StartTodaySessionStarted>());
    expect(sink.loggedEvents, [TelemetryEvent.sessionStarted]);
    expect(sink.loggedProperties, [
      {'origin': SessionOrigin.todayTopic.storageValue},
    ]);
  });
}

class FakeContentRepository implements ContentRepository {
  @override
  Future<List<Question>> questionsByTopic(TopicId topicId) async {
    return [
      Question(
        id: 'q1',
        topicId: topicId,
        stem: 'Question stem',
        choices: const [],
        examIds: const ['cse_prof'],
        language: 'en',
        version: 1,
        explanation: 'exp',
      ),
    ];
  }

  @override
  Future<List<Topic>> topicsByExam(ExamId examId) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeQuizSessionRepository implements QuizSessionRepository {
  @override
  Future<void> create({
    required String sessionId,
    required String userId,
    required ExamId examId,
    required SessionOrigin origin,
    required List<QuestionId> questionIds,
    required DateTime startedAt,
    TopicId? topicId,
    SubtopicId? subtopicId,
    LessonId? lessonId,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class RecordingTelemetrySink implements Telemetry {
  final loggedEvents = <TelemetryEvent>[];
  final loggedProperties = <Map<String, Object>?>[];

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    loggedEvents.add(event);
    loggedProperties.add(properties);
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}
