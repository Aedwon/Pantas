import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/features/roadmap/domain/build_roadmap.dart';
import 'package:pantas/features/roadmap/domain/lesson_links.dart';
import 'package:pantas/features/roadmap/domain/lesson_mastery.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

final day = DateTime(2026, 10);
RoadmapInputs fixture({
  bool read = true,
  bool readTarget = true,
  LinkStrength strength = LinkStrength.helpful,
  List<bool> recent = const [false, false, false],
  int answered = 5,
  bool tagged = true,
}) =>
    RoadmapInputs(
      today: day,
      examId: 'exam',
      examDate: ExamDate.onDay(DateTime(2026, 11)),
      topics: const [RoadmapTopic(id: 't', authoredIndex: 0, name: 'T')],
      lessons: [
        RoadmapLesson(
          id: 'l',
          topicId: 't',
          ordering: 0,
          readAt: readTarget ? day : null,
        ),
        RoadmapLesson(
          id: 'p',
          topicId: 't',
          ordering: 1,
          readAt: read ? day : null,
        ),
      ],
      questions: const [
        RoadmapQuestion(id: 'lq', topicId: 't', lessonId: 'l'),
        RoadmapQuestion(id: 'pq', topicId: 't', lessonId: 'p'),
      ],
      seenQuestionIds: {'lq', if (read) 'pq'},
      dueReviews: [RoadmapReview(id: 'lq', due: day, retrievability: 0.9)],
      scores: const {},
      answeredPerActiveDay: const [],
      mock: const RoadmapMockFacts(examHasMock: false, proIsActive: false),
      assessmentCompleted: true,
      contentRevision: 'r',
      lessonLinks: {
        'l': [LessonLink(lessonId: 'p', strength: strength)],
      },
      gapTags: {if (tagged) 'lq_a': 'p'},
      history: [
        QuestionHistory(
          id: 'lq',
          answered: 1,
          recent: const [false],
          lastWrongChoiceId: 'lq_a',
        ),
        if (read) QuestionHistory(id: 'pq', answered: answered, recent: recent),
      ],
    );
void main() {
  test('tagged weak helpful prerequisite uses detour practice before reviews',
      () {
    final today = BuildRoadmap.call(fixture()).today;
    expect(today.reviewQuestionIds, ['pq', 'lq']);
    expect(
      today.reasons['pq'],
      const PlanReason(kind: PlanReasonKind.followUp, forLessonId: 'l'),
    );
  });
  test('unseen tagged prerequisite is pulled before other unread lessons', () {
    final original = fixture(read: false);
    final inputs = RoadmapInputs(
      today: original.today,
      examId: original.examId,
      examDate: original.examDate,
      topics: original.topics,
      lessons: [
        original.lessons.first,
        const RoadmapLesson(id: 'other', topicId: 't', ordering: 0),
        original.lessons.last,
      ],
      questions: original.questions,
      seenQuestionIds: original.seenQuestionIds,
      dueReviews: original.dueReviews,
      scores: original.scores,
      answeredPerActiveDay: original.answeredPerActiveDay,
      mock: original.mock,
      assessmentCompleted: true,
      contentRevision: 'r',
      lessonLinks: original.lessonLinks,
      history: original.history,
      gapTags: original.gapTags,
    );
    final today = BuildRoadmap.call(inputs).today;
    expect(today.lessonIds, ['p']);
    expect(today.reasons['p']?.kind, PlanReasonKind.followUp);
  });

  test('an answered target that was never opened still gets its traced fix',
      () {
    final today = BuildRoadmap.call(fixture(readTarget: false)).today;
    expect(today.reviewQuestionIds.first, 'pq');
    expect(today.reasons['pq']?.kind, PlanReasonKind.followUp);
  });
  test('untagged weak required prerequisite gets a follow-up reason', () {
    final today = BuildRoadmap.call(
      fixture(tagged: false, strength: LinkStrength.required),
    ).today;
    expect(today.reviewQuestionIds, ['pq', 'lq']);
    expect(today.reasons['pq']?.kind, PlanReasonKind.followUp);
  });
  test('solid or learning tagged prerequisites cause no detour', () {
    for (final inputs in [
      fixture(recent: [true, true, true]),
      fixture(answered: 4),
    ]) {
      final today = BuildRoadmap.call(inputs).today;
      expect(today.reviewQuestionIds, ['lq']);
      expect(today.reasons, isEmpty);
    }
  });
  test('untagged helpful prerequisite causes no detour', () {
    expect(
      BuildRoadmap.call(fixture(tagged: false)).today.reviewQuestionIds,
      ['lq'],
    );
  });
}
