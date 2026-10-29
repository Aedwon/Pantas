import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/data/topic_prerequisites.dart';
import 'package:pantas/features/roadmap/domain/lesson_links.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

abstract final class TopicLinks {
  static Map<TopicId, List<TopicId>> derive(
    LessonGraphResult graph,
    List<RoadmapLesson> lessons,
  ) {
    final topics = {for (final lesson in lessons) lesson.id: lesson.topicId};
    final links = <TopicId, Set<TopicId>>{};
    for (final lesson in lessons) {
      for (final id in graph.requiredOf(lesson.id)) {
        final topic = topics[id];
        if (topic != null && topic != lesson.topicId) {
          (links[lesson.topicId] ??= {}).add(topic);
        }
      }
    }
    return Map.unmodifiable({
      for (final id in links.keys.toList()..sort())
        id: List<TopicId>.unmodifiable(links[id]!.toList()..sort()),
    });
  }

  static Map<TopicId, List<TopicId>> mergeLegacy(
    Map<TopicId, List<TopicId>> derived,
  ) {
    // UPCAT lesson links are incomplete. Add required links in content, then
    // delete the legacy topic map and this merge.
    final merged = <TopicId, Set<TopicId>>{
      for (final entry in topicPrerequisites.entries)
        entry.key: entry.value.toSet(),
    };
    for (final entry in derived.entries) {
      (merged[entry.key] ??= {}).addAll(entry.value);
    }
    return Map.unmodifiable({
      for (final id in merged.keys.toList()..sort())
        id: List<TopicId>.unmodifiable(merged[id]!.toList()..sort()),
    });
  }
}
