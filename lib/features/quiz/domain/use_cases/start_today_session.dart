import 'dart:async';

import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/telemetry/telemetry.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_ordering.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_preferences.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/question_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/today_interleaved_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/today_topic_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
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
  }) async {
    final allQuestions = topicId == null
        ? await _questionsByExam(examId)
        : await _content.questionsByTopic(topicId);
    final requestedLength =
        preferences.sessionLength == QuizPreferences.allDueSessionLength
            ? allQuestions.length
            : preferences.sessionLength;
    final context = PickContext(
      allQuestions: allQuestions,
      newQuestions: allQuestions,
      requestedLength: requestedLength,
      topicId: topicId,
    );
    final origin = preferences.ordering != QuizOrdering.blocked
        ? SessionOrigin.todayInterleaved
        : SessionOrigin.todayTopic;
    final picked = preferences.ordering != QuizOrdering.blocked
        ? _interleavedPicker.pick(context)
        : _topicPicker.pick(context);

    if (picked.isEmpty) {
      return const StartTodaySessionNoQuestions(
        'No questions are available for today.',
      );
    }

    final session = QuizSession.start(
      sessionId: _uuid.v4(),
      examId: examId,
      questions: picked,
      startedAt: now,
      origin: origin,
      topicId: preferences.ordering == QuizOrdering.blocked ? topicId : null,
    );
    await _sessions.create(
      sessionId: session.sessionId,
      userId: userId,
      examId: examId,
      origin: origin,
      topicId: session.topicId,
      questionIds: picked.map((question) => question.id).toList(),
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

  Future<List<Question>> _questionsByExam(ExamId examId) async {
    final topics = await _content.topicsByExam(examId);
    final questions = <Question>[];
    for (final topic in topics) {
      questions.addAll(await _content.questionsByTopic(topic.id));
    }
    return questions;
  }
}
