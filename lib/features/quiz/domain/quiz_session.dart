// ignore_for_file: sort_unnamed_constructors_first
import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_session.freezed.dart';

@freezed
class AnswerOutcome with _$AnswerOutcome {
  const AnswerOutcome._();

  const factory AnswerOutcome({
    required QuestionId questionId,
    required int questionVersion,
    required ChoiceId chosenChoiceId,
    required ChoiceId correctChoiceId,
    required int responseMs,
    @Default(Rating.good) Rating derivedRating,
    @Default(1) int nextReviewIntervalDays,
  }) = _AnswerOutcome;

  bool get isCorrect => chosenChoiceId == correctChoiceId;
}

@freezed
class QuizSession with _$QuizSession {
  const QuizSession._();

  const factory QuizSession({
    required String sessionId,
    required ExamId examId,
    required List<Question> questions,
    required int currentIndex,
    required List<AnswerOutcome> outcomes,
    required DateTime startedAt,
    @Default(SessionOrigin.todayTopic) SessionOrigin origin,
    TopicId? topicId,
    SubtopicId? subtopicId,
    LessonId? lessonId,
  }) = _QuizSession;

  factory QuizSession.start({
    required String sessionId,
    required ExamId examId,
    required List<Question> questions,
    required DateTime startedAt,
    SessionOrigin origin = SessionOrigin.todayTopic,
    TopicId? topicId,
    SubtopicId? subtopicId,
    LessonId? lessonId,
  }) =>
      QuizSession(
        sessionId: sessionId,
        examId: examId,
        questions: questions,
        currentIndex: 0,
        outcomes: const [],
        startedAt: startedAt,
        origin: origin,
        topicId: topicId,
        subtopicId: subtopicId,
        lessonId: lessonId,
      );

  Question get currentQuestion => questions[currentIndex];

  bool get isComplete => outcomes.length == questions.length;

  (int correct, int total) get score {
    final correct = outcomes.where((o) => o.isCorrect).length;
    return (correct, outcomes.length);
  }

  QuizSession record(AnswerOutcome o) => copyWith(
        outcomes: [...outcomes, o],
        currentIndex: currentIndex + 1,
      );
}
