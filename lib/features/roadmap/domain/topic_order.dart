import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

final class TopicOrderResult {
  TopicOrderResult({
    required List<TopicId> order,
    required List<TopicId> ranked,
    required this.cycleDetected,
  })  : order = List.unmodifiable(order),
        ranked = List.unmodifiable(ranked);

  final List<TopicId> order;
  final List<TopicId> ranked;
  final bool cycleDetected;
}

abstract final class TopicOrder {
  static TopicOrderResult compute({
    required List<RoadmapTopic> topics,
    required Map<TopicId, RoadmapTopicScore> scores,
    required Map<TopicId, List<TopicId>> prerequisites,
    required List<RoadmapLesson> lessons,
  }) {
    final scopedIds = {for (final topic in topics) topic.id};
    var totalCorrect = 0;
    var totalAnswered = 0;
    for (final id in scopedIds) {
      final score = scores[id];
      if (score != null && score.isMeasured) {
        totalCorrect += score.correct;
        totalAnswered += score.answered;
      }
    }

    final overallAccuracy =
        totalAnswered == 0 ? 0.0 : totalCorrect / totalAnswered;
    final accuracy = <TopicId, double>{
      for (final id in scopedIds)
        id: scores[id]?.isMeasured ?? false
            ? scores[id]!.correct / scores[id]!.answered
            : overallAccuracy,
    };

    final unreadTopics = <TopicId>{};
    final firstRead = <TopicId, DateTime>{};
    for (final lesson in lessons) {
      if (!scopedIds.contains(lesson.topicId)) continue;
      final readAt = lesson.readAt;
      if (readAt == null) {
        unreadTopics.add(lesson.topicId);
      } else {
        final earliest = firstRead[lesson.topicId];
        if (earliest == null || readAt.isBefore(earliest)) {
          firstRead[lesson.topicId] = readAt;
        }
      }
    }

    final started = <TopicId, DateTime>{
      for (final id in unreadTopics)
        if (firstRead.containsKey(id)) id: firstRead[id]!,
    };
    final rankedTopics = List<RoadmapTopic>.of(topics)
      ..sort((a, b) {
        final aStarted = started[a.id];
        final bStarted = started[b.id];
        if (aStarted != null && bStarted != null) {
          final comparison = aStarted.compareTo(bStarted);
          if (comparison != 0) return comparison;
          return a.authoredIndex.compareTo(b.authoredIndex);
        }
        if (aStarted != null) return -1;
        if (bStarted != null) return 1;
        final comparison = accuracy[a.id]!.compareTo(accuracy[b.id]!);
        if (comparison != 0) return comparison;
        return a.authoredIndex.compareTo(b.authoredIndex);
      });
    final rank = <TopicId, int>{
      for (var index = 0; index < rankedTopics.length; index++)
        rankedTopics[index].id: index,
    };

    final ranked = <TopicId>[];
    final emitted = <TopicId>{};
    final visiting = <TopicId>{};
    var cycleDetected = false;

    void emit(TopicId id) {
      if (emitted.contains(id)) return;
      // Only a revisit on the current depth-first path is a cycle.
      if (!visiting.add(id)) {
        cycleDetected = true;
        return;
      }
      final requiredTopics = (prerequisites[id] ?? const <TopicId>[])
          .where((id) => scopedIds.contains(id) && unreadTopics.contains(id))
          .toList()
        ..sort((a, b) => rank[a]!.compareTo(rank[b]!));
      for (final prerequisite in requiredTopics) {
        emit(prerequisite);
      }
      visiting.remove(id);
      emitted.add(id);
      ranked.add(id);
    }

    for (final topic in rankedTopics) {
      emit(topic.id);
    }
    return TopicOrderResult(
      order: ranked.where(unreadTopics.contains).toList(),
      ranked: ranked,
      cycleDetected: cycleDetected,
    );
  }
}
