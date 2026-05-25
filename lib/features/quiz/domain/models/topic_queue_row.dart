import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';

enum TopicQueueStatus { ready, caughtUp }

class TopicQueueInput {
  const TopicQueueInput({required this.topicId, required this.topicName});

  final TopicId topicId;
  final String topicName;
}

class TopicQueueRow {
  const TopicQueueRow({
    required this.topicId,
    required this.topicName,
    required this.dueCount,
    required this.weaknessCount,
    required this.newCount,
    required this.isRecommended,
  });

  final TopicId topicId;
  final String topicName;
  final int dueCount;
  final int weaknessCount;
  final int newCount;
  final bool isRecommended;

  int get totalCount => dueCount + weaknessCount + newCount;

  TopicQueueStatus get status =>
      totalCount == 0 ? TopicQueueStatus.caughtUp : TopicQueueStatus.ready;
}
