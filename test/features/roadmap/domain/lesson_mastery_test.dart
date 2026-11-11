import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/roadmap/domain/lesson_mastery.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

void main() {
  LessonMastery compute({
    int answered = 0,
    List<bool> recent = const [],
    double? recall,
    bool read = false,
  }) =>
      Mastery.compute(
        lessons: [
          RoadmapLesson(
            id: 'l',
            topicId: 't',
            ordering: 0,
            readAt: read ? DateTime(2026) : null,
          ),
        ],
        questions: const [
          RoadmapQuestion(id: 'q', topicId: 't', lessonId: 'l'),
        ],
        history: [QuestionHistory(id: 'q', answered: answered, recent: recent)],
        recall: {if (recall != null) 'q': recall},
      )['l']!;

  test('unread with no answers is unseen; reading or answering starts learning',
      () {
    expect(compute().kind, MasteryKind.unseen);
    expect(compute(read: true).kind, MasteryKind.learning);
    expect(compute(answered: 4, recent: [false]).kind, MasteryKind.learning);
  });
  test('five answers uses the 70 percent threshold and recall', () {
    expect(
      compute(answered: 5, recent: [true], recall: .69).kind,
      MasteryKind.weak,
    );
    expect(
      compute(answered: 5, recent: [true], recall: .70).kind,
      MasteryKind.solid,
    );
    expect(
      compute(answered: 5, recent: [false], recall: 1).kind,
      MasteryKind.weak,
    );
    expect(compute(answered: 5, recent: [true]).kind, MasteryKind.solid);
  });
  test('pools recent outcomes, all-time counts, and only available recalls',
      () {
    final result = Mastery.compute(
      lessons: const [RoadmapLesson(id: 'l', topicId: 't', ordering: 0)],
      questions: [
        for (var i = 0; i < 10; i++)
          RoadmapQuestion(id: 'q$i', topicId: 't', lessonId: 'l'),
        const RoadmapQuestion(id: 'other', topicId: 't', lessonId: 'outside'),
      ],
      history: [
        for (var i = 0; i < 10; i++)
          QuestionHistory(id: 'q$i', answered: 5, recent: [i < 7]),
        QuestionHistory(id: 'other', answered: 100, recent: const [false]),
      ],
      recall: const {'q0': .6, 'q1': .8, 'other': 0},
    )['l']!;
    expect(result.answered, 50);
    expect(result.recentAccuracy, .7);
    expect(result.recall, closeTo(.7, .00001));
    expect(result.kind, MasteryKind.solid);
  });
  test('history owns the last three outcomes oldest to newest', () {
    final recent = [false, true, false, true];
    final history = QuestionHistory(
      id: 'q',
      answered: 9,
      recent: recent,
      lastWrongChoiceId: 'q_a',
    );
    recent.clear();
    expect(history.recent, [true, false, true]);
    expect(history.recent.clear, throwsUnsupportedError);
    expect(
      history,
      QuestionHistory(
        id: 'q',
        answered: 9,
        recent: const [true, false, true],
        lastWrongChoiceId: 'q_a',
      ),
    );
    expect(
      history.hashCode,
      QuestionHistory(
        id: 'q',
        answered: 9,
        recent: const [true, false, true],
        lastWrongChoiceId: 'q_a',
      ).hashCode,
    );
    expect(
      compute(answered: 9, recent: [false, true, true, true]).recentAccuracy,
      1,
    );
  });
  test('no-question lesson is learning after reading and never weak', () {
    final result = Mastery.compute(
      lessons: [
        const RoadmapLesson(id: 'unread', topicId: 't', ordering: 0),
        RoadmapLesson(
          id: 'read',
          topicId: 't',
          ordering: 1,
          readAt: DateTime(2026),
        ),
      ],
      questions: const [],
      history: const [],
      recall: const {},
    );
    expect(result['unread']!.kind, MasteryKind.unseen);
    expect(result['read']!.kind, MasteryKind.learning);
    expect(result['read']!.recentAccuracy, isNull);
    expect(result['read']!.recall, isNull);
  });
}
