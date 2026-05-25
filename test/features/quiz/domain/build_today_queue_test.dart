import 'package:cse_cet_reviewer/features/quiz/domain/models/topic_queue_row.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/build_today_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('topic queue shows due weakness and new counts per topic', () {
    final rows = BuildTodayQueue.call(
      topics: const [
        TopicQueueInput(topicId: 'vocab', topicName: 'Vocabulary'),
      ],
      dueCounts: const {'vocab': 2},
      weaknessCounts: const {'vocab': 3},
      newCounts: const {'vocab': 1},
    );

    expect(rows.single.totalCount, equals(6));
    expect(rows.single.dueCount, equals(2));
    expect(rows.single.weaknessCount, equals(3));
    expect(rows.single.newCount, equals(1));
  });

  test('caught up topics remain visible with zero counts', () {
    final rows = BuildTodayQueue.call(
      topics: const [
        TopicQueueInput(topicId: 'clerical', topicName: 'Clerical')
      ],
      dueCounts: const {},
      weaknessCounts: const {},
      newCounts: const {},
    );

    expect(rows.single.status, TopicQueueStatus.caughtUp);
  });

  test('recommended topic is the largest backlog', () {
    final rows = BuildTodayQueue.call(
      topics: const [
        TopicQueueInput(topicId: 'vocab', topicName: 'Vocabulary'),
        TopicQueueInput(topicId: 'math', topicName: 'Math'),
      ],
      dueCounts: const {'vocab': 1, 'math': 4},
      weaknessCounts: const {'vocab': 1, 'math': 1},
      newCounts: const {'vocab': 1, 'math': 0},
    );

    expect(rows.first.topicId, equals('math'));
    expect(rows.first.isRecommended, isTrue);
  });

  test('new-card cap reached reports zero new cards', () {
    final rows = BuildTodayQueue.call(
      topics: const [
        TopicQueueInput(topicId: 'vocab', topicName: 'Vocabulary')
      ],
      dueCounts: const {},
      weaknessCounts: const {'vocab': 2},
      newCounts: const {'vocab': 5},
      newCardCapReached: true,
    );

    expect(rows.single.newCount, equals(0));
    expect(rows.single.totalCount, equals(2));
  });
}
