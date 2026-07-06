import 'dart:async';

import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/telemetry/telemetry.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_ordering.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_preferences.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/question_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/today_interleaved_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/today_topic_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:uuid/uuid.dart';

sealed class StartTodaySessionResult {
  const StartTodaySessionResult();
}

class StartTodaySessionStarted extends StartTodaySessionResult {
  const StartTodaySessionStarted(this.session);

  final QuizSession session;
}

class StartTodaySessionNoQuestions extends StartTodaySessionResult {
  const StartTodaySessionNoQuestions(this.message);

  final String message;
}

class StartTodaySession {
  StartTodaySession({
    required ContentRepository content,
    required QuizSessionRepository sessions,
    QuestionPicker? topicPicker,
    QuestionPicker? interleavedPicker,
    Uuid? uuid,
    Telemetry telemetry = const DisabledTelemetry(),
  })  : _content = content,
        _sessions = sessions,
        _topicPicker = topicPicker ?? TodayTopicPicker(),
        _interleavedPicker = interleavedPicker ?? TodayInterleavedPicker(),
        _uuid = uuid ?? const Uuid(),
        _telemetry = telemetry;

  final ContentRepository _content;
  final QuizSessionRepository _sessions;
  final QuestionPicker _topicPicker;
  final QuestionPicker _interleavedPicker;
  final Uuid _uuid;
  final Telemetry _telemetry;

  Future<StartTodaySessionResult> call({
    required String userId,
    required ExamId examId,
    required QuizPreferences preferences,
    required DateTime now,
    TopicId? topicId,
    TodaySessionPlan? plan,
  }) async {
    final resolved = plan ??
        await _planFromContent(
          examId: examId,
          preferences: preferences,
          topicId: topicId,
        );

    if (resolved.isEmpty) {
      return const StartTodaySessionNoQuestions(
        'No questions are available for today.',
      );
    }

    final origin = preferences.ordering != QuizOrdering.blocked
        ? SessionOrigin.todayInterleaved
        : SessionOrigin.todayTopic;
    // The named topic is recorded whatever the ordering. Under the interleaved
    // tail the session is still named after one topic, and the tab's
    // "Still going" state has to be able to say which.
    final namedTopicId = resolved.topicId ?? topicId;

    final session = QuizSession.start(
      sessionId: _uuid.v4(),
      examId: examId,
      questions: resolved.questions,
      startedAt: now,
      origin: origin,
      topicId: namedTopicId,
    );
    await _sessions.create(
      sessionId: session.sessionId,
      userId: userId,
      examId: examId,
      origin: origin,
      topicId: namedTopicId,
      questionIds: resolved.questions.map((question) => question.id).toList(),
      startedAt: now,
    );
    unawaited(
      _telemetry.log(
        TelemetryEvent.sessionStarted,
        properties: {'origin': origin.storageValue},
      ),
    );
    return StartTodaySessionStarted(session);
  }

  /// The fallback for callers that have not gathered a plan, which is
  /// `QuizController.startToday`. It picks from content alone, so it has no
  /// review states to work from and the session is composed of unseen
  /// questions. The Quiz tab always supplies a plan.
  Future<TodaySessionPlan> _planFromContent({
    required ExamId examId,
    required QuizPreferences preferences,
    TopicId? topicId,
  }) async {
    final allQuestions = topicId == null
        ? await _questionsByExam(examId)
        : await _content.questionsByTopic(topicId);
    return BuildTodayPlan.call(
      due: const [],
      weakness: const [],
      fresh: allQuestions,
      allQuestions: allQuestions,
      preferences: preferences,
      topicId: topicId,
      topicPicker: _topicPicker,
      interleavedPicker: _interleavedPicker,
    );
  }

  Future<List<Question>> _questionsByExam(ExamId examId) async {
    final topics = await _content.topicsByExam(examId);
    final questions = <Question>[];
    for (final topic in topics) {
      questions.addAll(await _content.questionsByTopic(topic.id));
    }
    return questions;
  }
}
