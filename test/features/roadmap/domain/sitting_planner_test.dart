import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/quiz/domain/models/quiz_ordering.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/roadmap/domain/sitting_planner.dart';

void main() {
  group('SittingPlanner draw', () {
    test('reviews keep their given order and are drawn before new questions',
        () {
      expect(
        _next(
          reviews: ['review-b', 'review-a'],
          fresh: ['new-a', 'new-b'],
          questions: [
            _question('review-b'),
            _question('review-a'),
            _question('new-a'),
            _question('new-b'),
          ],
          sessionLength: 3,
        ),
        ['review-b', 'review-a', 'new-a'],
      );
    });

    test('read, absent and unknown lessons share tier 2 in plan order', () {
      expect(
        _next(
          fresh: ['held', 'skipped', 'unknown', 'read', 'absent'],
          lessons: ['today', 'unknown'],
          knownLessons: {'today', 'skipped', 'read'},
          readLessons: {'read'},
          questions: [
            _question('held', lessonId: 'today'),
            _question('skipped', lessonId: 'skipped'),
            _question('unknown', lessonId: 'unknown'),
            _question('read', lessonId: 'read'),
            _question('absent'),
          ],
          sessionLength: 3,
        ),
        ['unknown', 'read', 'absent'],
      );
    });

    test('known unread lessons outside today supply tier 3 in plan order', () {
      expect(
        _next(
          fresh: ['held', 'skipped-b', 'read', 'skipped-a'],
          lessons: ['today'],
          knownLessons: {'today', 'skipped', 'read'},
          readLessons: {'read'},
          questions: [
            _question('held', lessonId: 'today'),
            _question('skipped-b', lessonId: 'skipped'),
            _question('read', lessonId: 'read'),
            _question('skipped-a', lessonId: 'skipped'),
          ],
          sessionLength: 3,
        ),
        ['read', 'skipped-b', 'skipped-a'],
      );
    });

    test('today unread questions are drawn last in plan order', () {
      expect(
        _next(
          reviews: ['review'],
          fresh: ['held-b', 'skipped', 'held-a', 'read'],
          lessons: ['today'],
          knownLessons: {'today', 'skipped', 'read'},
          readLessons: {'read'},
          questions: [
            _question('review'),
            _question('held-b', lessonId: 'today'),
            _question('skipped', lessonId: 'skipped'),
            _question('held-a', lessonId: 'today'),
            _question('read', lessonId: 'read'),
          ],
        ),
        ['review', 'read', 'skipped', 'held-b', 'held-a'],
      );
    });

    test('reading today lesson moves its questions into tier 2', () {
      expect(
        _next(
          fresh: ['today', 'skipped'],
          lessons: ['today'],
          knownLessons: {'today', 'skipped'},
          readLessons: {'today'},
          questions: [
            _question('today', lessonId: 'today'),
            _question('skipped', lessonId: 'skipped'),
          ],
          sessionLength: 1,
        ),
        ['today'],
      );
    });

    test('All includes every remaining question beyond the default length', () {
      final ids = [for (var i = 0; i < 24; i++) 'q-$i'];
      expect(
        _next(
          reviews: ids.take(12).toList(),
          fresh: ids.skip(12).toList(),
          questions: [for (final id in ids) _question(id)],
          sessionLength: QuizPreferences.allDueSessionLength,
        ),
        ids,
      );
    });

    test('only questions in the remaining day are drawn', () {
      expect(
        _next(
          fresh: ['planned'],
          questions: [_question('outside'), _question('planned')],
        ),
        ['planned'],
      );
    });

    test('empty day returns an empty sitting', () {
      expect(_next(), isEmpty);
    });
  });

  group('SittingPlanner arrangement', () {
    final questions = [
      _question('b-1', topicId: 'b'),
      _question('a-1', topicId: 'a'),
      _question('b-2', topicId: 'b'),
      _question('a-2', topicId: 'a'),
      _question('c-1', topicId: 'c'),
    ];
    for (final ordering in QuizOrdering.values) {
      test('$ordering keeps exactly the drawn set', () {
        final result = _next(
          fresh: ['b-1', 'a-1', 'b-2', 'a-2', 'c-1', 'undrawn'],
          questions: [...questions, _question('undrawn')],
          rankedTopics: ['a', 'b', 'c'],
          ordering: ordering,
        );
        expect(result, unorderedEquals(['b-1', 'a-1', 'b-2', 'a-2', 'c-1']));
      });
    }

    test('blocked groups by rank and preserves order within each topic', () {
      expect(
        _next(
          fresh: ['b-1', 'a-1', 'b-2', 'a-2', 'c-1'],
          questions: questions,
          rankedTopics: ['a', 'b', 'c'],
        ),
        ['a-1', 'a-2', 'b-1', 'b-2', 'c-1'],
      );
    });

    test('interleaved tail starts with most drawn topic and mixes the rest',
        () {
      expect(
        _next(
          fresh: ['c-1', 'a-1', 'c-2', 'b-1', 'b-2', 'c-3'],
          questions: [
            _question('c-1', topicId: 'c'),
            _question('a-1', topicId: 'a'),
            _question('c-2', topicId: 'c'),
            _question('b-1', topicId: 'b'),
            _question('b-2', topicId: 'b'),
            _question('c-3', topicId: 'c'),
          ],
          rankedTopics: ['a', 'b', 'c'],
          ordering: QuizOrdering.interleavedTail,
          sessionLength: 6,
        ),
        ['c-1', 'c-2', 'c-3', 'a-1', 'b-1', 'b-2'],
      );
    });

    test('interleaved tail breaks largest-topic ties by rank', () {
      expect(
        _next(
          fresh: ['b-1', 'a-1', 'b-2', 'a-2', 'c-1'],
          questions: questions,
          rankedTopics: ['a', 'b', 'c'],
          ordering: QuizOrdering.interleavedTail,
        ),
        ['a-1', 'a-2', 'b-1', 'c-1', 'b-2'],
      );
    });

    test('fully mixed separates adjacent topics without dropping any items',
        () {
      expect(
        _next(
          fresh: ['a-1', 'a-2', 'a-3', 'b-1', 'b-2', 'c-1'],
          questions: [
            _question('a-1', topicId: 'a'),
            _question('a-2', topicId: 'a'),
            _question('a-3', topicId: 'a'),
            _question('b-1', topicId: 'b'),
            _question('b-2', topicId: 'b'),
            _question('c-1', topicId: 'c'),
          ],
          ordering: QuizOrdering.fullyMixed,
          sessionLength: 6,
        ),
        ['a-1', 'b-1', 'a-3', 'b-2', 'a-2', 'c-1'],
      );
    });

    test('fully mixed keeps vocabulary together at its first position', () {
      expect(
        _next(
          fresh: ['a-1', 'v-1', 'v-2', 'v-3', 'b-1', 'a-2'],
          questions: [
            _question('a-1', topicId: 'a'),
            _question('v-1', topicId: _vocabulary),
            _question('v-2', topicId: _vocabulary),
            _question('v-3', topicId: _vocabulary),
            _question('b-1', topicId: 'b'),
            _question('a-2', topicId: 'a'),
          ],
          ordering: QuizOrdering.fullyMixed,
          sessionLength: 6,
        ),
        ['a-1', 'v-1', 'v-3', 'v-2', 'b-1', 'a-2'],
      );
    });
  });

  group('SittingPlanner passage sets', () {
    test('a set that does not fit is skipped whole and later items fill', () {
      expect(
        _next(
          reviews: ['review'],
          fresh: ['p-1', 'p-2', 'free'],
          questions: [
            _question('review'),
            _question('p-1', passageId: 'p'),
            _question('p-2', passageId: 'p'),
            _question('free'),
          ],
          sessionLength: 2,
        ),
        ['review', 'free'],
      );
    });

    test('a fitting set keeps earlier free-standing draw priority', () {
      expect(
        _next(
          reviews: ['review'],
          fresh: ['free', 'p-1', 'p-2', 'later'],
          questions: [
            _question('review'),
            _question('free'),
            _question('p-1', passageId: 'p'),
            _question('p-2', passageId: 'p'),
            _question('later'),
          ],
          sessionLength: 4,
        ),
        ['review', 'free', 'p-1', 'p-2'],
      );
    });

    test('a passage shared by reviews and new questions is drawn whole', () {
      expect(
        _next(
          reviews: ['p-review'],
          fresh: ['free', 'p-new'],
          questions: [
            _question('p-review', passageId: 'p'),
            _question('free'),
            _question('p-new', passageId: 'p'),
          ],
          sessionLength: 2,
        ),
        ['p-review', 'p-new'],
      );
    });

    test('All includes passage sets larger than a normal sitting', () {
      final ids = [for (var i = 0; i < 12; i++) 'p-$i'];
      expect(
        _next(
          fresh: ids,
          questions: [for (final id in ids) _question(id, passageId: 'p')],
          sessionLength: QuizPreferences.allDueSessionLength,
        ),
        ids,
      );
    });

    test('fully mixed regroups a passage after mixing its topic', () {
      expect(
        _next(
          fresh: ['p-1', 'p-2', 'b-1', 'b-2'],
          questions: [
            _question('p-1', topicId: 'a', passageId: 'p'),
            _question('p-2', topicId: 'a', passageId: 'p'),
            _question('b-1', topicId: 'b'),
            _question('b-2', topicId: 'b'),
          ],
          ordering: QuizOrdering.fullyMixed,
        ),
        ['p-1', 'p-2', 'b-1', 'b-2'],
      );
    });
  });
}

const _vocabulary = 'topic_upcat_vocabulary';

List<QuestionId> _next({
  List<QuestionId> reviews = const [],
  List<QuestionId> fresh = const [],
  List<LessonId> lessons = const [],
  Set<LessonId> knownLessons = const {},
  Set<LessonId> readLessons = const {},
  List<RoadmapQuestion> questions = const [],
  int sessionLength = 5,
  QuizOrdering ordering = QuizOrdering.blocked,
  List<TopicId> rankedTopics = const ['topic'],
}) =>
    SittingPlanner.next(
      remaining: DayPlan(
        day: DateTime(2026, 10),
        lessonIds: lessons,
        reviewQuestionIds: reviews,
        newQuestionIds: fresh,
        isMockDay: false,
        advancedIds: const {},
      ),
      knownLessonIds: knownLessons,
      readLessonIds: readLessons,
      questionsById: {for (final question in questions) question.id: question},
      sessionLength: sessionLength,
      ordering: ordering,
      vocabularyTopicId: _vocabulary,
      rankedTopics: rankedTopics,
    );

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
