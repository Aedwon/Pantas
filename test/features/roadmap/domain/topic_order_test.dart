import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/roadmap/domain/topic_order.dart';

void main() {
  group('TopicOrder.compute', () {
    test('ranks measured topics weakest first', () {
      final result = _compute(
        ['strong', 'weak', 'middle'],
        scores: {
          'strong': _score('strong', 4, 5),
          'weak': _score('weak', 1, 5),
          'middle': _score('middle', 3, 5),
        },
      );

      expect(result.order, ['weak', 'middle', 'strong']);
      expect(result.ranked, ['weak', 'middle', 'strong']);
      expect(result.cycleDetected, isFalse);
    });

    test('two answers rank at overall measured accuracy, not their own', () {
      final result = _compute(
        ['strong', 'unmeasured', 'weak'],
        scores: {
          'strong': _score('strong', 4, 5),
          'unmeasured': _score('unmeasured', 0, 2),
          'weak': _score('weak', 2, 5),
        },
      );

      // Measured answers total 6 / 10, between 2 / 5 and 4 / 5.
      expect(result.order, ['weak', 'unmeasured', 'strong']);
    });

    test('overall accuracy weights measured topics by answered count', () {
      final result = _compute(
        ['strong', 'middle', 'unmeasured', 'weak'],
        scores: {
          'strong': _score('strong', 3, 3),
          'middle': _score('middle', 3, 5),
          'unmeasured': _score('unmeasured', 1, 1),
          'weak': _score('weak', 4, 10),
        },
      );

      // 10 / 18 is below 3 / 5. The mean of topic accuracies is above it.
      expect(result.order, ['weak', 'unmeasured', 'middle', 'strong']);
    });

    test('a missing score ranks at overall measured accuracy', () {
      final result = _compute(
        ['strong', 'missing', 'weak'],
        scores: {
          'strong': _score('strong', 4, 5),
          'weak': _score('weak', 2, 5),
        },
      );

      expect(result.order, ['weak', 'missing', 'strong']);
    });

    test('out-of-scope scores do not change overall accuracy', () {
      final result = _compute(
        ['strong', 'missing', 'weak'],
        scores: {
          'strong': _score('strong', 4, 5),
          'weak': _score('weak', 2, 5),
          'excluded': _score('excluded', 0, 100),
        },
      );

      expect(result.order, ['weak', 'missing', 'strong']);
    });

    test('no scores uses authored indexes even with shuffled input', () {
      final result = TopicOrder.compute(
        topics: [_topic('third', 2), _topic('first', 0), _topic('second', 1)],
        scores: const {},
        prerequisites: const {},
        lessons: [_lesson('third'), _lesson('first'), _lesson('second')],
      );

      expect(result.order, ['first', 'second', 'third']);
    });

    test('no measured topics uses authored order despite partial scores', () {
      final result = _compute(
        ['first', 'second', 'third'],
        scores: {
          'first': _score('first', 2, 2),
          'second': _score('second', 0, 2),
          'third': _score('third', 0, 0),
        },
      );

      expect(result.order, ['first', 'second', 'third']);
    });

    test('accuracy ties use authored index', () {
      final result = _compute(
        ['first', 'unmeasured', 'last'],
        scores: {
          'first': _score('first', 1, 3),
          'unmeasured': _score('unmeasured', 0, 2),
          'last': _score('last', 2, 6),
        },
      );

      expect(result.order, ['first', 'unmeasured', 'last']);
    });

    test('a started topic comes before a weaker untouched topic', () {
      final result = _compute(
        ['weak', 'started'],
        scores: {
          'weak': _score('weak', 0, 5),
          'started': _score('started', 5, 5),
        },
        lessons: [
          _lesson('weak'),
          _lesson('started', suffix: 'read', readAt: DateTime(2026, 9, 29)),
          _lesson('started'),
        ],
      );

      expect(result.order, ['started', 'weak']);
      expect(result.ranked, ['started', 'weak']);
    });

    test('started topics use their earliest read time, not lesson order', () {
      final result = _compute(
        ['weak', 'later', 'earlier'],
        scores: {
          'weak': _score('weak', 0, 5),
          'later': _score('later', 1, 5),
          'earlier': _score('earlier', 5, 5),
        },
        lessons: [
          _lesson('weak'),
          _lesson('later', suffix: 'read', readAt: DateTime(2026, 9, 28)),
          _lesson('later'),
          _lesson('earlier', suffix: 'recent', readAt: DateTime(2026, 9, 29)),
          _lesson('earlier', suffix: 'first', readAt: DateTime(2026, 9, 27)),
          _lesson('earlier'),
        ],
      );

      expect(result.order, ['earlier', 'later', 'weak']);
    });

    test('pulls a stronger prerequisite before its dependent', () {
      final result = _compute(
        ['dependent', 'other', 'prerequisite'],
        scores: {
          'dependent': _score('dependent', 0, 5),
          'other': _score('other', 2, 5),
          'prerequisite': _score('prerequisite', 5, 5),
        },
        prerequisites: {
          'dependent': ['prerequisite'],
        },
      );

      expect(result.order, ['prerequisite', 'dependent', 'other']);
      expect(result.ranked, ['prerequisite', 'dependent', 'other']);
      expect(result.cycleDetected, isFalse);
    });

    test('prerequisites also precede a started dependent', () {
      final result = _compute(
        ['dependent', 'prerequisite'],
        prerequisites: {
          'dependent': ['prerequisite'],
        },
        lessons: [
          _lesson('dependent', suffix: 'read', readAt: DateTime(2026, 9, 29)),
          _lesson('dependent'),
          _lesson('prerequisite'),
        ],
      );

      expect(result.order, ['prerequisite', 'dependent']);
    });

    test('walks nested prerequisites depth first in their own rank order', () {
      final result = _compute(
        ['dependent', 'strong', 'weaker', 'root'],
        prerequisites: {
          'dependent': ['strong', 'weaker'],
          'weaker': ['root'],
        },
        scores: {
          'dependent': _score('dependent', 0, 5),
          'strong': _score('strong', 4, 5),
          'weaker': _score('weaker', 2, 5),
          'root': _score('root', 5, 5),
        },
      );

      expect(result.order, ['root', 'weaker', 'strong', 'dependent']);
      expect(result.cycleDetected, isFalse);
    });

    test('ignores an out-of-scope prerequisite and its dependencies', () {
      final result = _compute(
        ['dependent', 'other'],
        prerequisites: {
          'dependent': ['excluded'],
          'excluded': ['other'],
        },
      );

      expect(result.order, ['dependent', 'other']);
      expect(result.ranked, ['dependent', 'other']);
      expect(result.cycleDetected, isFalse);
    });

    test('a prerequisite with no lessons never blocks', () {
      final result = _compute(
        ['dependent', 'other', 'empty'],
        prerequisites: {
          'dependent': ['empty'],
          'empty': ['other'],
        },
        lessons: [_lesson('dependent'), _lesson('other')],
      );

      expect(result.order, ['dependent', 'other']);
      expect(result.ranked, ['dependent', 'other', 'empty']);
      expect(result.cycleDetected, isFalse);
    });

    test('a covered prerequisite is not pulled forward or emitted in order',
        () {
      final result = _compute(
        ['dependent', 'other', 'covered'],
        prerequisites: {
          'dependent': ['covered'],
        },
        lessons: [
          _lesson('dependent'),
          _lesson('other'),
          _lesson('covered', readAt: DateTime(2026, 9, 29)),
        ],
      );

      expect(result.order, ['dependent', 'other']);
      expect(result.ranked, ['dependent', 'other', 'covered']);
      expect(result.cycleDetected, isFalse);
    });

    test('ranked retains covered topics in their ranked position', () {
      final result = _compute(
        ['covered', 'unread'],
        lessons: [
          _lesson('covered', readAt: DateTime(2026, 9, 29)),
          _lesson('unread'),
        ],
      );

      expect(result.order, ['unread']);
      expect(result.ranked, ['covered', 'unread']);
    });

    test('shared prerequisites emit once without reporting a cycle', () {
      final result = _compute(
        ['first', 'second', 'shared'],
        prerequisites: {
          'first': ['shared'],
          'second': ['shared'],
        },
      );

      expect(result.order, ['shared', 'first', 'second']);
      expect(result.ranked, ['shared', 'first', 'second']);
      expect(result.cycleDetected, isFalse);
    });

    test('a prerequisite cycle terminates and is flagged', () {
      final result = _compute(
        ['first', 'second', 'other'],
        prerequisites: {
          'first': ['second'],
          'second': ['first'],
        },
      );

      expect(result.order, ['second', 'first', 'other']);
      expect(result.ranked, ['second', 'first', 'other']);
      expect(result.cycleDetected, isTrue);
    });

    test('a self prerequisite terminates and is flagged', () {
      final result = _compute(
        ['self'],
        prerequisites: {
          'self': ['self'],
        },
      );

      expect(result.order, ['self']);
      expect(result.ranked, ['self']);
      expect(result.cycleDetected, isTrue);
    });

    test('empty scope has no order and ignores unrelated input', () {
      final result = _compute(
        [],
        scores: {'excluded': _score('excluded', 3, 3)},
        prerequisites: {
          'excluded': ['excluded'],
        },
        lessons: [_lesson('excluded')],
      );

      expect(result.order, isEmpty);
      expect(result.ranked, isEmpty);
      expect(result.cycleDetected, isFalse);
    });
  });
}

TopicOrderResult _compute(
  List<TopicId> authoredIds, {
  Map<TopicId, RoadmapTopicScore> scores = const {},
  Map<TopicId, List<TopicId>> prerequisites = const {},
  List<RoadmapLesson>? lessons,
}) =>
    TopicOrder.compute(
      topics: [
        for (var index = 0; index < authoredIds.length; index++)
          _topic(authoredIds[index], index),
      ],
      scores: scores,
      prerequisites: prerequisites,
      lessons: lessons ?? [for (final id in authoredIds) _lesson(id)],
    );

RoadmapTopic _topic(TopicId id, int authoredIndex) =>
    RoadmapTopic(id: id, authoredIndex: authoredIndex, name: id);

RoadmapTopicScore _score(TopicId id, int correct, int answered) =>
    RoadmapTopicScore(id: id, correct: correct, answered: answered);

RoadmapLesson _lesson(
  TopicId topicId, {
  String suffix = 'unread',
  DateTime? readAt,
}) =>
    RoadmapLesson(
      id: '${topicId}_$suffix',
      topicId: topicId,
      ordering: 0,
      readAt: readAt,
    );
