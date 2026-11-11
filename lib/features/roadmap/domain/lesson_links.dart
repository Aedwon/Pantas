import 'package:meta/meta.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/domain/lesson_mastery.dart';

enum LinkStrength { required, helpful }

@immutable
final class LessonLink {
  const LessonLink({required this.lessonId, required this.strength});

  final LessonId lessonId;
  final LinkStrength strength;

  @override
  bool operator ==(Object other) =>
      other is LessonLink &&
      lessonId == other.lessonId &&
      strength == other.strength;

  @override
  int get hashCode => Object.hash(lessonId, strength);
}

typedef LessonLinks = Map<LessonId, List<LessonLink>>;

final class LessonGraphResult {
  LessonGraphResult._(LessonLinks links, {required this.cycleDetected})
      : _links = Map.unmodifiable({
          for (final entry in links.entries)
            entry.key: List<LessonLink>.unmodifiable(entry.value),
        });

  final LessonLinks _links;
  final bool cycleDetected;

  List<LessonId> requiredOf(LessonId id) => _of(id, LinkStrength.required);
  List<LessonId> helpfulOf(LessonId id) => _of(id, LinkStrength.helpful);

  List<LessonId> _of(LessonId id, LinkStrength strength) => List.unmodifiable([
        for (final link in _links[id] ?? const <LessonLink>[])
          if (link.strength == strength) link.lessonId,
      ]);
}

abstract final class LessonGraph {
  static LessonGraphResult build(LessonLinks links, Iterable<LessonId> scoped) {
    final ids = scoped.toSet();
    final sorted = ids.toList()..sort();
    final visiting = <LessonId>{};
    final visited = <LessonId>{};
    final accepted = <LessonId, List<LessonLink>>{};
    var cycleDetected = false;

    void visit(LessonId id) {
      if (visited.contains(id)) return;
      visiting.add(id);
      final candidates = (links[id] ?? const <LessonLink>[])
          .where((link) => ids.contains(link.lessonId))
          .toList()
        ..sort((a, b) {
          final order = a.lessonId.compareTo(b.lessonId);
          return order != 0
              ? order
              : a.strength.index.compareTo(b.strength.index);
        });
      final kept = <LessonLink>[];
      for (final link in candidates) {
        if (visiting.contains(link.lessonId)) {
          cycleDetected = true;
          continue;
        }
        visit(link.lessonId);
        if (!kept.contains(link)) kept.add(link);
      }
      accepted[id] = kept;
      visiting.remove(id);
      visited.add(id);
    }

    for (final id in sorted) {
      visit(id);
    }
    return LessonGraphResult._(accepted, cycleDetected: cycleDetected);
  }

  static LessonId? firstUnmet(
    LessonId target,
    LessonGraphResult graph,
    Map<LessonId, LessonMastery> mastery,
  ) {
    for (final id in graph.requiredOf(target)) {
      final deeper = firstUnmet(id, graph, mastery);
      if (deeper != null) return deeper;
      final kind = mastery[id]?.kind;
      if (kind == MasteryKind.unseen || kind == MasteryKind.weak) return id;
    }
    return null;
  }
}
