import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/features/roadmap/domain/build_roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

/// Following the plan every day reads every lesson and sees every question
/// before the review-only stretch begins (spec, Part 2 Section 9).
void main() {
  test('following the plan covers everything before review-only days', () {
    for (var seed = 0; seed < 200; seed++) {
      final random = Random(seed);
      final topicCount = 5 + random.nextInt(21);
      final topics = [
        for (var t = 0; t < topicCount; t++)
          RoadmapTopic(id: 't$t', authoredIndex: t, name: 'T$t'),
      ];
      final lessons = <RoadmapLesson>[];
      final questions = <RoadmapQuestion>[];
      for (final topic in topics) {
        final lessonCount = random.nextInt(13);
        for (var l = 0; l < lessonCount; l++) {
          lessons.add(
            RoadmapLesson(
              id: '${topic.id}_l$l',
              topicId: topic.id,
              ordering: l,
            ),
          );
        }
        final questionCount = random.nextInt(61);
        for (var q = 0; q < questionCount; q++) {
          final hasLesson = lessonCount > 0 && random.nextInt(5) > 0;
          questions.add(
            RoadmapQuestion(
              id: '${topic.id}_q$q',
              topicId: topic.id,
              lessonId: hasLesson
                  ? '${topic.id}_l${random.nextInt(lessonCount)}'
                  : null,
              passageId:
                  random.nextInt(10) == 0 ? '${topic.id}_p${q ~/ 4}' : null,
            ),
          );
        }
      }

      final start = DateTime(2026, 10);
      final distance = 1 + random.nextInt(200);
      final exam = ExamDate.onDay(
        DateTime(start.year, start.month, start.day + distance),
      );

      final read = <String, DateTime>{};
      final seen = <String>{};
      DateTime? anchor;
      DateTime? reviewOnlyFrom;
      var day = start;
      while (day.isBefore(exam.day!)) {
        final roadmap = BuildRoadmap.call(
          RoadmapInputs(
            today: day,
            examId: 'e',
            examDate: exam,
            topics: topics,
            prerequisites: const {},
            lessons: [
              for (final lesson in lessons)
                RoadmapLesson(
                  id: lesson.id,
                  topicId: lesson.topicId,
                  ordering: lesson.ordering,
                  readAt: read[lesson.id],
                ),
            ],
            questions: questions,
            seenQuestionIds: seen,
            dueReviews: const [],
            scores: const {},
            answeredPerActiveDay: const [],
            mock:
                const RoadmapMockFacts(examHasMock: false, proIsActive: false),
            assessmentCompleted: true,
            contentRevision: 'r',
            anchoredReviewOnlyFrom: anchor,
          ),
        );
        anchor ??= roadmap.reviewOnlyFrom;
        reviewOnlyFrom ??= roadmap.reviewOnlyFrom;
        for (final id in roadmap.today.lessonIds) {
          read[id] = day;
        }
        seen.addAll(roadmap.today.newQuestionIds);
        day = DateTime(day.year, day.month, day.day + 1);
        if (!day.isBefore(reviewOnlyFrom!)) break;
      }

      final unread = lessons.where((l) => !read.containsKey(l.id)).length;
      final unseen = questions.where((q) => !seen.contains(q.id)).length;
      expect(
        (unread, unseen),
        (0, 0),
        reason: 'seed $seed: $distance days, review-only from '
            '$reviewOnlyFrom, ${localDaysBetween(start, reviewOnlyFrom!)} '
            'working days',
      );
    }
  });
}
