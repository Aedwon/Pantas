import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/roadmap/domain/build_roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

void main() {
  final sept30 = DateTime(2026, 9, 30);
  final dec7 = ExamDate.onDay(DateTime(2026, 12, 7));

  RoadmapInputs inputs({
    DateTime? today,
    ExamDate? examDate,
    bool examDateMissing = false,
    int lessonCount = 120,
    int questionCount = 900,
    bool assessed = true,
    bool hasMock = false,
    List<RoadmapReview> due = const [],
    DateTime? anchor,
    Set<String> seen = const {},
    StudyDays studyDays = StudyDays.all,
  }) =>
      RoadmapInputs(
        today: today ?? sept30,
        examId: 'exam_upcat',
        studyDays: studyDays,
        examDate: examDateMissing ? null : (examDate ?? dec7),
        topics: const [RoadmapTopic(id: 't', authoredIndex: 0, name: 'T')],
        prerequisites: const {},
        lessons: [
          for (var i = 0; i < lessonCount; i++)
            RoadmapLesson(
              id: 'l${i.toString().padLeft(3, '0')}',
              topicId: 't',
              ordering: i,
            ),
        ],
        questions: [
          for (var i = 0; i < questionCount; i++)
            RoadmapQuestion(
              id: 'q${i.toString().padLeft(3, '0')}',
              topicId: 't',
            ),
        ],
        seenQuestionIds: seen,
        dueReviews: due,
        scores: const {},
        answeredPerActiveDay: const [],
        mock: RoadmapMockFacts(examHasMock: hasMock, proIsActive: true),
        assessmentCompleted: assessed,
        contentRevision: 'rev2',
        anchoredReviewOnlyFrom: anchor,
      );

  test('exam-day warm-up uses at most ten actual easiest ordered due reviews',
      () {
    final due = [
      for (var i = 0; i < 25; i++)
        RoadmapReview(
          id: 'q${i.toString().padLeft(3, '0')}',
          due: sept30,
          retrievability: .1 + i * .01,
        ),
    ];
    final result =
        BuildRoadmap.call(inputs(examDate: ExamDate.onDay(sept30), due: due));
    expect(
      result.today.reviewQuestionIds,
      [for (var i = 24; i >= 15; i--) 'q${i.toString().padLeft(3, '0')}'],
    );
    expect(result.today.lessonIds, isEmpty);
    expect(result.today.newQuestionIds, isEmpty);
  });
  test('exam-day optional warm-up also exists on a scheduled rest weekday', () {
    final result = BuildRoadmap.call(
      inputs(
        examDate: ExamDate.onDay(sept30),
        studyDays: StudyDays(const [DateTime.monday]),
        due: [RoadmapReview(id: 'q000', due: sept30, retrievability: .9)],
      ),
    );
    expect(result.today.reviewQuestionIds, ['q000']);
    expect(result.today.isRestDay, isTrue);
  });
  test('exam-day warm-up never pads sparse or absent membership', () {
    for (final count in [0, 3]) {
      final due = [
        for (var i = 0; i < count; i++)
          RoadmapReview(
            id: 'q${i.toString().padLeft(3, '0')}',
            due: sept30,
            retrievability: .9,
          ),
      ];
      final result =
          BuildRoadmap.call(inputs(examDate: ExamDate.onDay(sept30), due: due));
      expect(result.today.reviewQuestionIds, hasLength(count));
    }
  });
  test('the worked example gives two lessons and fifteen new questions', () {
    final roadmap = BuildRoadmap.call(inputs());

    expect(roadmap.state, RoadmapState.planning);
    expect(roadmap.today.lessonIds, hasLength(2));
    expect(roadmap.today.newQuestionIds, hasLength(15));
    expect(roadmap.reviewOnlyFrom, DateTime(2026, 11, 30));
    expect(roadmap.examDay, DateTime(2026, 12, 7));
  });

  test('no assessment yet means no plan', () {
    final roadmap = BuildRoadmap.call(inputs(assessed: false));
    expect(roadmap.state, RoadmapState.needsAssessment);
    expect(roadmap.today.questionCount, 0);
  });

  test('no content means no plan', () {
    final roadmap = BuildRoadmap.call(inputs(lessonCount: 0, questionCount: 0));
    expect(roadmap.state, RoadmapState.noContent);
  });

  test('the exam today, a passed exam or no date give reviews only', () {
    final due = [RoadmapReview(id: 'q000', due: sept30, retrievability: 0.8)];
    for (final roadmap in [
      BuildRoadmap.call(
        inputs(examDate: ExamDate.onDay(sept30), due: due),
      ),
      BuildRoadmap.call(
        inputs(examDate: ExamDate.onDay(DateTime(2026, 9)), due: due),
      ),
      BuildRoadmap.call(inputs(examDateMissing: true, due: due)),
    ]) {
      expect(roadmap.today.lessonIds, isEmpty);
      expect(roadmap.today.newQuestionIds, isEmpty);
      expect(roadmap.today.reviewQuestionIds, ['q000']);
    }
  });

  test('inside the review-only stretch, leftovers spread to the exam', () {
    final roadmap = BuildRoadmap.call(
      inputs(
        today: DateTime(2026, 12, 3),
        anchor: DateTime(2026, 11, 30),
        lessonCount: 8,
        questionCount: 40,
      ),
    );

    expect(roadmap.state, RoadmapState.reviewOnly);
    expect(roadmap.today.lessonIds, hasLength(2));
    expect(roadmap.today.newQuestionIds, hasLength(10));
  });

  test('the anchored review-only date is kept as the exam nears', () {
    final roadmap = BuildRoadmap.call(
      inputs(today: DateTime(2026, 11, 25), anchor: DateTime(2026, 11, 30)),
    );
    expect(roadmap.reviewOnlyFrom, DateTime(2026, 11, 30));
  });

  test('everything covered keeps reviews and says so', () {
    final roadmap = BuildRoadmap.call(
      inputs(
        lessonCount: 0,
        questionCount: 1,
        seen: {'q000'},
        due: [RoadmapReview(id: 'q000', due: sept30, retrievability: 0.9)],
      ),
    );
    expect(roadmap.state, RoadmapState.allCovered);
    expect(roadmap.today.reviewQuestionIds, ['q000']);
  });

  test('the mock day is flagged on its day only', () {
    final early = BuildRoadmap.call(inputs(hasMock: true));
    expect(early.mockDay, DateTime(2026, 12));
    expect(early.today.isMockDay, isFalse);

    final onTheDay = BuildRoadmap.call(
      inputs(
        hasMock: true,
        today: DateTime(2026, 12),
        anchor: DateTime(2026, 11, 30),
      ),
    );
    expect(onTheDay.today.isMockDay, isTrue);
  });

  test('weeks ahead name topics only and stop before review-only days', () {
    final roadmap = BuildRoadmap.call(inputs());
    expect(roadmap.weeksAhead, isNotEmpty);
    expect(
      roadmap.weeksAhead
          .every((w) => w.weekStart.isBefore(DateTime(2026, 11, 30))),
      isTrue,
    );
    expect(roadmap.weeksAhead.first.topicIds, ['t']);
  });
}
