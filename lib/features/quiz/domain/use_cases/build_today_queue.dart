import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/topic_queue_row.dart';

abstract final class BuildTodayQueue {
  static List<TopicQueueRow> call({
    required List<TopicQueueInput> topics,
    required Map<TopicId, int> dueCounts,
    required Map<TopicId, int> weaknessCounts,
    required Map<TopicId, int> newCounts,
    bool newCardCapReached = false,
  }) {
    final rows = [
      for (final topic in topics)
        TopicQueueRow(
          topicId: topic.topicId,
          topicName: topic.topicName,
          dueCount: dueCounts[topic.topicId] ?? 0,
          weaknessCount: weaknessCounts[topic.topicId] ?? 0,
          newCount: newCardCapReached ? 0 : newCounts[topic.topicId] ?? 0,
          isRecommended: false,
        ),
    ]..sort((a, b) {
        final totalOrder = b.totalCount.compareTo(a.totalCount);
        if (totalOrder != 0) return totalOrder;
        return a.topicName.compareTo(b.topicName);
      });

    if (rows.isEmpty || rows.first.totalCount == 0) return rows;
    return [
      rows.first._recommended(),
      ...rows.skip(1),
    ];
  }
}

extension on TopicQueueRow {
  TopicQueueRow _recommended() => TopicQueueRow(
        topicId: topicId,
        topicName: topicName,
        dueCount: dueCount,
        weaknessCount: weaknessCount,
        newCount: newCount,
        isRecommended: true,
      );
}
