// ignore_for_file: sort_unnamed_constructors_first
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/passage_set_filler.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';

part 'quiz_session.freezed.dart';

@freezed
abstract class AnswerOutcome with _$AnswerOutcome {
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
abstract class QuizSession with _$QuizSession {
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
        // Every session is built through here, so this is the one place
        // that can promise a passage is read once. Patching each use case
        // missed four of them.
        //
        // Safe only because a session starts with no outcomes: those are
        // indexed by position, so reordering a session that already holds
        // answers would attach them to the wrong questions. `resume` builds
        // its session directly and keeps the stored order.
        questions: groupPassageSets(questions),
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

  /// Records the answer and stays on the question.
  ///
  /// The reveal is the point of a practice quiz: the student sees what the
  /// answer was and why before moving. Advancing here is what made the
  /// session skip straight past it.
  QuizSession record(AnswerOutcome o) => copyWith(outcomes: [...outcomes, o]);

  /// Moves to the next question once the student has read the reveal.
  QuizSession advance() => currentIndex + 1 >= questions.length
      ? this
      : copyWith(currentIndex: currentIndex + 1);

  /// The outcome for the question on screen, or null while it is unanswered.
  AnswerOutcome? get currentOutcome =>
      currentIndex < outcomes.length ? outcomes[currentIndex] : null;

  bool get isOnLastQuestion => currentIndex == questions.length - 1;
}
