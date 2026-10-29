import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/features/roadmap/domain/build_roadmap.dart';
import 'package:pantas/features/roadmap/domain/lesson_links.dart';
import 'package:pantas/features/roadmap/domain/lesson_mastery.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

final day = DateTime(2026, 10);
const requiredLink = LinkStrength.required;

Roadmap plan({
  required List<RoadmapLesson> lessons,
  LessonLinks links = const {},
  List<QuestionHistory> history = const [],
  Map<String, double> recall = const {},
  Set<String> seen = const {},
  Map<String, RoadmapTopicScore> scores = const {},
  List<RoadmapReview> reviews = const [],
}) =>
    BuildRoadmap.call(
      RoadmapInputs(
        today: day,
        examId: 'e',
        examDate: ExamDate.onDay(DateTime(2026, 11)),
        topics: const [
          RoadmapTopic(id: 't', authoredIndex: 0, name: 'T'),
          RoadmapTopic(id: 'u', authoredIndex: 1, name: 'U'),
        ],
        lessons: lessons,
        questions: [
          for (final lesson in lessons)
            for (var i = 0; i < 7; i++)
              RoadmapQuestion(
                id: '${lesson.id}_q$i',
                topicId: lesson.topicId,
                lessonId: lesson.id,
              ),
        ],
        lessonLinks: links,
        history: history,
        recall: recall,
        seenQuestionIds: seen,
        dueReviews: reviews,
        scores: scores,
        answeredPerActiveDay: const [1],
        mock: const RoadmapMockFacts(examHasMock: false, proIsActive: false),
        assessmentCompleted: true,
        contentRevision: 'r',
      ),
    );

LessonLink link(String id, [LinkStrength strength = requiredLink]) =>
    LessonLink(lessonId: id, strength: strength);
RoadmapLesson lesson(
  String id,
  int order, {
  bool read = false,
  String topic = 't',
}) =>
    RoadmapLesson(
      id: id,
      topicId: topic,
      ordering: order,
      readAt: read ? day : null,
    );
QuestionHistory weak(String id) => QuestionHistory(
      id: '${id}_q0',
      answered: 5,
      recent: const [false, false, false],
      lastWrongChoiceId: '${id}_q0_a',
    );

void main() {
  test('unseen required lesson in a later topic comes first with a reason', () {
    final result = plan(
      lessons: [
        lesson('a', 0),
        lesson('b', 1, topic: 'u'),
      ],
      links: {
        'a': [link('b')],
      },
    );
    expect(result.today.lessonIds, ['b']);
    expect(
      result.today.reasons['b'],
      const PlanReason(kind: PlanReasonKind.prerequisite, forLessonId: 'a'),
    );
  });
  test('deepest weak prerequisite gets practice before its dependent', () {
    final result = plan(
      lessons: [
        lesson('a', 0),
        lesson('b', 1, read: true),
        lesson('c', 2, read: true),
      ],
      links: {
        'a': [link('b')],
        'b': [link('c')],
      },
      history: [weak('b'), weak('c')],
      seen: {'c_q0'},
    );
    expect(result.today.lessonIds, isEmpty);
    expect(result.today.reviewQuestionIds.first, 'c_q0');
    expect(result.today.newQuestionIds.first, 'c_q1');
    expect(
      result.today.reasons['c_q0'],
      const PlanReason(kind: PlanReasonKind.followUp, forLessonId: 'b'),
    );
    expect(result.weeksAhead.expand((w) => w.topicIds), contains('t'));
  });
  test('structural detour without misses keeps prerequisite reason', () {
    final result = plan(
      lessons: [lesson('a', 0), lesson('b', 1, read: true)],
      links: {
        'a': [link('b')],
      },
      history: [
        QuestionHistory(
          id: 'b_q0',
          answered: 5,
          recent: const [true, true, true],
        ),
      ],
      recall: {'b_q0': 0.2},
      seen: {'b_q0'},
    );
    expect(
      result.today.reasons['b_q0'],
      const PlanReason(kind: PlanReasonKind.prerequisite, forLessonId: 'a'),
    );
  });
  test('solid deep prerequisite leaves the nearer weak prerequisite first', () {
    final result = plan(
      lessons: [
        lesson('a', 0),
        lesson('b', 1, read: true),
        lesson('c', 2, read: true),
      ],
      links: {
        'a': [link('b')],
        'b': [link('c')],
      },
      history: [
        weak('b'),
        QuestionHistory(
          id: 'c_q0',
          answered: 5,
          recent: const [true, true, true],
        ),
      ],
      seen: {'b_q0'},
    );
    expect(result.today.reviewQuestionIds.first, 'b_q0');
    expect(result.today.lessonIds, isEmpty);
  });
  test('unread ancestor comes first through a read prerequisite', () {
    final result = plan(
      lessons: [
        lesson('a', 0),
        lesson('b', 1, read: true),
        lesson('c', 2),
      ],
      links: {
        'a': [link('b')],
        'b': [link('c')],
      },
    );
    expect(result.today.lessonIds, ['c']);
  });
  test('solid prerequisite leaves lessons and reviews unchanged', () {
    final lessons = [lesson('a', 0), lesson('b', 1, read: true)];
    final history = [
      QuestionHistory(
        id: 'b_q0',
        answered: 5,
        recent: const [true, true, true],
      ),
    ];
    final reviews = [
      RoadmapReview(id: 'b_q0', due: day, retrievability: 0.9),
    ];
    final baseline = plan(lessons: lessons, history: history, reviews: reviews);
    final linked = plan(
      lessons: lessons,
      history: history,
      reviews: reviews,
      links: {
        'a': [link('b')],
      },
    );
    expect(linked.today, baseline.today);
    expect(linked.weeksAhead, baseline.weeksAhead);
  });
  test('helpful same-topic lesson goes first without withholding', () {
    final result = plan(
      lessons: [
        lesson('a', 0),
        lesson('b', 1),
      ],
      links: {
        'a': [link('b', LinkStrength.helpful)],
      },
    );
    expect(result.today.lessonIds, ['b']);
    expect(result.today.reasons['b']?.kind, PlanReasonKind.nextUp);
  });
  test('lesson reasons use measured topic accuracy below seventy percent', () {
    final result = plan(
      lessons: [
        lesson('a', 0),
      ],
      scores: {
        't': const RoadmapTopicScore(id: 't', correct: 2, answered: 3),
      },
    );
    expect(result.today.reasons['a']?.kind, PlanReasonKind.weakTopic);
  });
  test('detour practice is extra and does not duplicate due reviews', () {
    final result = plan(
      lessons: [
        lesson('a', 0),
        lesson('b', 1, read: true),
      ],
      links: {
        'a': [link('b')],
      },
      history: [
        weak('b'),
      ],
      seen: {
        'b_q0',
        'b_q1',
      },
      recall: {
        'b_q0': 0.1,
        'b_q1': 0.2,
      },
      reviews: [
        RoadmapReview(id: 'b_q0', due: day, retrievability: 0.1),
        RoadmapReview(id: 'other', due: day, retrievability: 0.9),
      ],
    );
    expect(result.today.reviewQuestionIds, ['b_q0', 'b_q1', 'other']);
    expect(result.today.newQuestionIds.take(3), ['b_q2', 'b_q3', 'b_q4']);
    expect(result.today.newQuestionIds.length, greaterThan(3));
  });
}
