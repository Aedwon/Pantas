import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/domain/day_selection.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

void main() {
  group('DaySelector.select lessons', () {
    test('walks topics then ordering and id, skipping read lessons', () {
      final result = _select(
        lessonTopicOrder: ['second', 'first'],
        lessons: [
          _lesson('first', topicId: 'first'),
          _lesson('z', topicId: 'second', ordering: 1),
          _lesson('b', topicId: 'second'),
          _lesson('a', topicId: 'second'),
          _lesson('read', topicId: 'second', readAt: DateTime(2026, 9, 29)),
        ],
        lessonsToday: 3,
      );

      expect(result.lessonIds, ['a', 'b', 'z']);
    });

    test('returns remaining unread lessons when the quota exceeds them', () {
      final result = _select(
        lessons: [_lesson('a')],
        lessonsToday: 10,
      );

      expect(result.lessonIds, ['a']);
    });

    test('a zero lesson quota selects none', () {
      expect(_select(lessons: [_lesson('a')]).lessonIds, isEmpty);
    });
  });

  group('DaySelector.select new questions', () {
    test('read lessons come first by read time then question id', () {
      final result = _select(
        lessons: [
          _lesson('recent', readAt: DateTime(2026, 9, 29)),
          _lesson('old-b', readAt: DateTime(2026, 9, 28)),
          _lesson('old-a', readAt: DateTime(2026, 9, 28)),
          _lesson('today'),
        ],
        questions: [
          _question('a-recent', lessonId: 'recent'),
          _question('z-old', lessonId: 'old-a'),
          _question('b-old', lessonId: 'old-b'),
          _question('a-today', lessonId: 'today'),
          _question('a-seen', lessonId: 'old-a'),
        ],
        seenQuestionIds: {'a-seen'},
        lessonsToday: 1,
        newToday: 3,
      );

      expect(result.newQuestionIds, ['b-old', 'z-old', 'a-recent']);
    });

    test('today lessons precede other questions in today lesson order', () {
      final result = _select(
        lessons: [
          _lesson('later', ordering: 1),
          _lesson('today'),
          _lesson('skipped', ordering: 2),
        ],
        questions: [
          _question('a-skipped', lessonId: 'skipped'),
          _question('a-later', lessonId: 'later'),
          _question('z-today', lessonId: 'today'),
          _question('b-today', lessonId: 'today'),
        ],
        lessonsToday: 2,
        newToday: 3,
      );

      expect(result.newQuestionIds, ['b-today', 'z-today', 'a-later']);
    });

    test('tier three walks ranked topics and groups by lesson order', () {
      final result = _select(
        lessonTopicOrder: ['first', 'second'],
        rankedTopics: ['second', 'first', 'empty'],
        lessons: [
          _lesson('second-z', topicId: 'second', ordering: 1),
          _lesson('second-b', topicId: 'second'),
          _lesson('second-a', topicId: 'second'),
          _lesson('first', topicId: 'first'),
        ],
        questions: [
          _question('a-no-lesson', topicId: 'second'),
          _question('a-last-lesson', topicId: 'second', lessonId: 'second-z'),
          _question('z-first-lesson', topicId: 'second', lessonId: 'second-a'),
          _question('b-first-lesson', topicId: 'second', lessonId: 'second-a'),
          _question('a-second-lesson', topicId: 'second', lessonId: 'second-b'),
          _question('first', topicId: 'first', lessonId: 'first'),
          _question('empty', topicId: 'empty'),
        ],
        newToday: 7,
      );

      expect(result.newQuestionIds, [
        'b-first-lesson',
        'z-first-lesson',
        'a-second-lesson',
        'a-last-lesson',
        'a-no-lesson',
        'first',
        'empty',
      ]);
    });

    test('skipped lessons still supply questions so the pace holds', () {
      final result = _select(
        lessons: [_lesson('today'), _lesson('skipped', ordering: 1)],
        questions: [
          _question('today', lessonId: 'today'),
          _question('skipped-b', lessonId: 'skipped'),
          _question('skipped-a', lessonId: 'skipped'),
        ],
        lessonsToday: 1,
        newToday: 3,
      );

      expect(result.lessonIds, ['today']);
      expect(result.newQuestionIds, ['today', 'skipped-a', 'skipped-b']);
    });

    test('fills all three tiers without selecting a question twice', () {
      final result = _select(
        lessons: [
          _lesson('read', readAt: DateTime(2026, 9, 29)),
          _lesson('today'),
          _lesson('skipped', ordering: 1),
        ],
        questions: [
          _question('a-skipped', lessonId: 'skipped'),
          _question('b-today', lessonId: 'today'),
          _question('z-read', lessonId: 'read'),
        ],
        lessonsToday: 1,
        newToday: 10,
      );

      expect(result.newQuestionIds, ['z-read', 'b-today', 'a-skipped']);
    });

    test('seen questions are omitted from today and fallback tiers', () {
      final result = _select(
        lessons: [_lesson('today'), _lesson('skipped', ordering: 1)],
        questions: [
          _question('seen-today', lessonId: 'today'),
          _question('seen-skipped', lessonId: 'skipped'),
          _question('seen-no-lesson'),
          _question('unseen', lessonId: 'skipped'),
        ],
        seenQuestionIds: {'seen-today', 'seen-skipped', 'seen-no-lesson'},
        lessonsToday: 1,
        newToday: 10,
      );

      expect(result.newQuestionIds, ['unseen']);
    });

    test('passage brings unseen siblings immediately across priority tiers',
        () {
      final result = _select(
        rankedTopics: ['topic', 'other'],
        lessons: [_lesson('read', readAt: DateTime(2026, 9, 29))],
        questions: [
          _question('a-trigger', lessonId: 'read', passageId: 'passage'),
          _question('b-unrelated', lessonId: 'read'),
          _question('z-sibling', topicId: 'other', passageId: 'passage'),
          _question('c-sibling', passageId: 'passage'),
          _question('d-seen', passageId: 'passage'),
        ],
        seenQuestionIds: {'d-seen'},
        newToday: 4,
      );

      expect(result.newQuestionIds, [
        'a-trigger',
        'c-sibling',
        'z-sibling',
        'b-unrelated',
      ]);
    });

    test('only the final passage remainder may overflow the quota', () {
      final result = _select(
        questions: [
          _question('z-first-sibling', passageId: 'first'),
          _question('a-first', passageId: 'first'),
          _question('y-second-sibling', passageId: 'second'),
          _question('b-second', passageId: 'second'),
          _question('x-second-sibling', passageId: 'second'),
          _question('c-third', passageId: 'third'),
          _question('w-third-sibling', passageId: 'third'),
        ],
        newToday: 3,
      );

      expect(result.newQuestionIds, [
        'a-first',
        'z-first-sibling',
        'b-second',
        'x-second-sibling',
        'y-second-sibling',
      ]);
    });

    test('a passage does not start when the quota has already been filled', () {
      final result = _select(
        questions: [
          _question('a'),
          _question('b', passageId: 'passage'),
          _question('c', passageId: 'passage'),
        ],
        newToday: 1,
      );

      expect(result.newQuestionIds, ['a']);
    });

    test('zero new quota does not introduce a passage', () {
      final result = _select(
        questions: [_question('a', passageId: 'passage')],
      );

      expect(result.newQuestionIds, isEmpty);
    });
  });

  group('DaySelector.capacity', () {
    test('zero history days means no cap', () {
      expect(DaySelector.capacity([]), isNull);
    });

    test('one day of new answers gives a positive capacity', () {
      expect(DaySelector.capacity([12]), 12);
      expect(DaySelector.capacity([1]), 1);
      expect(DaySelector.capacity([0]), 1);
    });

    test('seven history days use the sorted middle count', () {
      expect(DaySelector.capacity([100, 2, 1, 5, 9, 4, 3]), 4);
    });

    test('even history counts use the lower middle integer', () {
      expect(DaySelector.capacity([9, 1, 8, 2]), 2);
      expect(DaySelector.capacity([0, 8]), 1);
    });

    test('does not reorder the supplied history', () {
      final history = [9, 1, 4];
      DaySelector.capacity(history);
      expect(history, [9, 1, 4]);
    });
  });

  group('DaySelector.select reviews', () {
    test('orders by retrievability descending, due ascending, then id', () {
      final result = _select(
        dueReviews: [
          _review('low', 0.1, dueDay: 1),
          _review('z-high', 0.9, dueDay: 28),
          _review('a-high', 0.9, dueDay: 28),
          _review('older-high', 0.9, dueDay: 27),
          _review('middle', 0.5, dueDay: 20),
        ],
      );

      expect(result.reviewQuestionIds, [
        'older-high',
        'a-high',
        'z-high',
        'middle',
        'low',
      ]);
      expect(result.dueCount, 5);
      expect(result.backlogCapped, isFalse);
    });

    test('caps the sorted backlog and retains the full due count', () {
      final result = _select(
        dueReviews: [_review('low', 0.1), _review('high', 0.9)],
        answeredPerActiveDay: [1],
      );

      expect(result.reviewQuestionIds, ['high']);
      expect(result.dueCount, 2);
      expect(result.backlogCapped, isTrue);
    });

    test('due count at or below capacity includes all without a cap flag', () {
      for (final history in [
        [2],
        [3],
      ]) {
        final result = _select(
          dueReviews: [_review('low', 0.1), _review('high', 0.9)],
          answeredPerActiveDay: history,
        );

        expect(result.reviewQuestionIds, ['high', 'low']);
        expect(result.backlogCapped, isFalse);
      }
    });

    test('a large backlog leaves the new material unchanged', () {
      final lessons = [_lesson('today')];
      final questions = [
        _question('new-a', lessonId: 'today'),
        _question('new-b', lessonId: 'today'),
        _question('new-c', lessonId: 'today'),
      ];
      final withoutBacklog = _select(
        lessons: lessons,
        questions: questions,
        lessonsToday: 1,
        newToday: 3,
      );
      final result = _select(
        lessons: lessons,
        questions: questions,
        lessonsToday: 1,
        newToday: 3,
        dueReviews: [for (var i = 0; i < 100; i++) _review('due-$i', 0.5)],
        answeredPerActiveDay: [2],
      );

      expect(result.lessonIds, withoutBacklog.lessonIds);
      expect(result.newQuestionIds, ['new-a', 'new-b', 'new-c']);
      expect(result.newQuestionIds, withoutBacklog.newQuestionIds);
      expect(result.reviewQuestionIds, hasLength(2));
      expect(result.dueCount, 100);
      expect(result.backlogCapped, isTrue);
    });

    test('empty input returns an empty uncapped selection', () {
      final result = _select(answeredPerActiveDay: [1]);
      expect(result.lessonIds, isEmpty);
      expect(result.newQuestionIds, isEmpty);
      expect(result.reviewQuestionIds, isEmpty);
      expect(result.dueCount, 0);
      expect(result.backlogCapped, isFalse);
    });
  });
}

DaySelection _select({
  List<TopicId> lessonTopicOrder = const ['topic'],
  List<TopicId> rankedTopics = const ['topic'],
  List<RoadmapLesson> lessons = const [],
  List<RoadmapQuestion> questions = const [],
  Set<QuestionId> seenQuestionIds = const {},
  List<RoadmapReview> dueReviews = const [],
  List<int> answeredPerActiveDay = const [],
  int lessonsToday = 0,
  int newToday = 0,
}) =>
    DaySelector.select(
      lessonTopicOrder: lessonTopicOrder,
      rankedTopics: rankedTopics,
      lessons: lessons,
      questions: questions,
      seenQuestionIds: seenQuestionIds,
      dueReviews: dueReviews,
      answeredPerActiveDay: answeredPerActiveDay,
      lessonsToday: lessonsToday,
      newToday: newToday,
    );

RoadmapLesson _lesson(
  LessonId id, {
  TopicId topicId = 'topic',
  int ordering = 0,
  DateTime? readAt,
}) =>
    RoadmapLesson(id: id, topicId: topicId, ordering: ordering, readAt: readAt);

RoadmapQuestion _question(
  QuestionId id, {
  TopicId topicId = 'topic',
  LessonId? lessonId,
  PassageId? passageId,
}) =>
    RoadmapQuestion(
      id: id,
      topicId: topicId,
      lessonId: lessonId,
      passageId: passageId,
    );

RoadmapReview _review(
  QuestionId id,
  double retrievability, {
  int dueDay = 29,
}) =>
    RoadmapReview(
      id: id,
      due: DateTime(2026, 9, dueDay),
      retrievability: retrievability,
    );
