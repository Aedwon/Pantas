import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/picker/inline_lesson_picker.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';
import 'package:pantas/features/quiz/domain/picker/question_picker.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/selectors/subtopic_filter.dart';
import 'package:uuid/uuid.dart';

sealed class StartInlineLessonQuizResult {
  const StartInlineLessonQuizResult();
}

class StartInlineLessonQuizStarted extends StartInlineLessonQuizResult {
  const StartInlineLessonQuizStarted(this.session);

  final QuizSession session;
}

class StartInlineLessonQuizNoQuestions extends StartInlineLessonQuizResult {
  const StartInlineLessonQuizNoQuestions(this.message);

  final String message;
}

class StartInlineLessonQuiz {
  StartInlineLessonQuiz({
    required ContentRepository content,
    required QuizSessionRepository sessions,
    QuestionPicker? picker,
    Uuid? uuid,
  })  : _content = content,
        _sessions = sessions,
        _picker = picker ?? InlineLessonPicker(),
        _uuid = uuid ?? const Uuid();

  final ContentRepository _content;
  final QuizSessionRepository _sessions;
  final QuestionPicker _picker;
  final Uuid _uuid;

  Future<StartInlineLessonQuizResult> call({
    required String userId,
    required ExamId examId,
    required LessonId lessonId,
    required DateTime now,
  }) async {
    final lesson = await _content.lessonById(lessonId);
    if (lesson == null) {
      return const StartInlineLessonQuizNoQuestions('Lesson not found.');
    }

    final allQuestions = await _content.questionsByTopic(lesson.topicId);
    final picked = _picker.pick(
      PickContext(
        allQuestions: allQuestions,
        subtopicCandidates: [
          for (final question in allQuestions)
            SubtopicQuestion(question: question, subtopicId: null),
        ],
        requestedLength: 5,
        topicId: lesson.topicId,
        subtopicId: lesson.subtopicId,
      ),
    );
    if (picked.isEmpty) {
      return const StartInlineLessonQuizNoQuestions(
        'No questions are available for this lesson.',
      );
    }

    final session = QuizSession.start(
      sessionId: _uuid.v4(),
      examId: examId,
      questions: picked,
      startedAt: now,
      origin: SessionOrigin.inline,
      topicId: lesson.topicId,
      subtopicId: lesson.subtopicId,
      lessonId: lessonId,
    );
    await _sessions.create(
      sessionId: session.sessionId,
      userId: userId,
      examId: examId,
      origin: SessionOrigin.inline,
      topicId: lesson.topicId,
      subtopicId: lesson.subtopicId,
      lessonId: lessonId,
      questionIds: picked.map((question) => question.id).toList(),
      startedAt: now,
    );
    return StartInlineLessonQuizStarted(session);
  }
}
