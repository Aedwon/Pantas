import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/subject.dart';
import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockContent extends Mock implements ContentRepository {}

void main() {
  late _MockContent content;
  late StartQuickQuiz useCase;

  setUp(() {
    content = _MockContent();
    useCase = StartQuickQuiz(content);
  });

  Question makeQ(String id, String topicId) => Question(
        id: id,
        version: 1,
        examIds: const ['e1'],
        topicId: topicId,
        language: 'en',
        stem: 'stem $id',
        choices: const [
          Choice(id: 'a', label: 'A', text: 'x', isCorrect: true),
          Choice(id: 'b', label: 'B', text: 'y', isCorrect: false),
        ],
        explanation: 'why',
      );

  test('returns a session of `count` questions for the requested exam',
      () async {
    const exam = Exam(
      id: 'e1',
      code: 'E1',
      name: 'E1',
      shortName: 'E1',
      language: 'en',
      isActive: true,
      subjects: [Subject(id: 's1', examId: 'e1', name: 'S1', ordering: 1)],
    );
    final topics = [
      const Topic(id: 't1', subjectId: 's1', name: 'T1', ordering: 1)
    ];
    final questions = [makeQ('q1', 't1'), makeQ('q2', 't1'), makeQ('q3', 't1')];

    when(() => content.listExams()).thenAnswer((_) async => [exam]);
    when(() => content.topicsBySubject('s1')).thenAnswer((_) async => topics);
    when(() => content.questionsByTopic('t1'))
        .thenAnswer((_) async => questions);

    final session = await useCase(
      examId: 'e1',
      count: 2,
      now: DateTime.utc(2026, 5, 9),
      randomSeed: 42,
    );

    expect(session.questions, hasLength(2));
    expect(session.examId, equals('e1'));
    expect(session.currentIndex, equals(0));
  });

  test('throws StateError when no questions are available', () async {
    when(() => content.listExams()).thenAnswer((_) async => const []);
    expect(
      () => useCase(
          examId: 'e1',
          count: 10,
          now: DateTime.utc(2026, 5, 9),
          randomSeed: 1),
      throwsStateError,
    );
  });
}
