import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/domain/lesson_links.dart';
import 'package:pantas/features/roadmap/domain/lesson_mastery.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

final class LessonQueue {
  LessonQueue._(
    this.lessons,
    this.withheld,
    this.prerequisiteFor,
    this.weakFor,
  );

  final List<RoadmapLesson> lessons;
  final Set<LessonId> withheld;
  final Map<LessonId, LessonId> prerequisiteFor;

  /// In depth-first order. Selection limits practice to two prerequisites.
  final Map<LessonId, LessonId> weakFor;

  // Shared named entry point used by day and week planning.
  // ignore: prefer_constructors_over_static_methods
  static LessonQueue build({
    required List<TopicId> lessonTopicOrder,
    required List<RoadmapLesson> lessons,
    LessonGraphResult? graph,
    Map<LessonId, LessonMastery> mastery = const {},
  }) {
    final ranks = {
      for (var i = 0; i < lessonTopicOrder.length; i++) lessonTopicOrder[i]: i,
    };
    final scoped = lessons.where((l) => ranks.containsKey(l.topicId)).toList();
    final byId = {for (final lesson in lessons) lesson.id: lesson};
    final links = graph ?? LessonGraph.build(const {}, byId.keys);
    scoped.sort((a, b) {
      final topic = ranks[a.topicId]!.compareTo(ranks[b.topicId]!);
      if (topic != 0) return topic;
      final order = a.ordering.compareTo(b.ordering);
      return order != 0 ? order : a.id.compareTo(b.id);
    });
    final queue = <RoadmapLesson>[];
    final emitted = <LessonId>{};
    final withheld = <LessonId>{};
    final prerequisiteFor = <LessonId, LessonId>{};
    final weakFor = <LessonId, LessonId>{};

    bool collectWeak(LessonId id, LessonId target) {
      var weak = false;
      for (final prerequisite in links.requiredOf(id)) {
        if (collectWeak(prerequisite, target)) weak = true;
        if (mastery[prerequisite]?.kind == MasteryKind.weak &&
            byId[prerequisite]?.readAt != null) {
          weakFor.putIfAbsent(prerequisite, () => target);
          weak = true;
        }
      }
      return weak;
    }

    void emit(RoadmapLesson lesson) {
      if (!emitted.add(lesson.id)) return;
      for (final id in links.helpfulOf(lesson.id)) {
        final prerequisite = byId[id];
        if (prerequisite != null &&
            prerequisite.topicId == lesson.topicId &&
            prerequisite.readAt == null) {
          emit(prerequisite);
        }
      }
      for (final id in links.requiredOf(lesson.id)) {
        final prerequisite = byId[id];
        if (prerequisite != null) {
          emit(prerequisite);
        }
      }
      if (lesson.readAt == null) queue.add(lesson);
    }

    for (final lesson in scoped) {
      for (final id in links.requiredOf(lesson.id)) {
        if (byId[id]?.readAt == null && byId.containsKey(id)) {
          prerequisiteFor.putIfAbsent(id, () => lesson.id);
        }
      }
    }
    for (final lesson in scoped) {
      if (collectWeak(lesson.id, lesson.id)) withheld.add(lesson.id);
      if (lesson.readAt == null) emit(lesson);
    }
    return LessonQueue._(
      List.unmodifiable(queue),
      Set.unmodifiable(withheld),
      Map.unmodifiable(prerequisiteFor),
      Map.unmodifiable(weakFor),
    );
  }
}
