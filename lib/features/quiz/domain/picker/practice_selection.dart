import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/quiz/domain/picker/practice_index.dart';

enum PracticeCheckState { off, partial, on }

/// One thing the student picked, and the pool it draws on.
///
/// A [lessonId] of null means the whole topic. The footer's wheel gives every
/// unit the same number of questions, which is why a unit is the counting
/// grain rather than a question total.
class PracticeUnit {
  const PracticeUnit({required this.topicId, this.lessonId});

  final TopicId topicId;
  final LessonId? lessonId;

  String get key => lessonId == null ? 'topic:$topicId' : 'lesson:$lessonId';
}

/// What is ticked, and what that buys.
///
/// Immutable: every toggle returns a new selection, so the screen's state is
/// one value and the footer cannot fall out of step with the boxes.
class PracticeSelection {
  const PracticeSelection.empty()
      : _wholeTopics = const {},
        _lessons = const {};

  const PracticeSelection._(this._wholeTopics, this._lessons);

  factory PracticeSelection.fromLessonIds(
    PracticeIndex index,
    Iterable<LessonId> ids,
  ) {
    var picked = const PracticeSelection.empty();
    final wanted = ids.toSet();
    for (final topic in index.allTopics) {
      for (final lesson in topic.lessons) {
        if (lesson.questionCount > 0 && wanted.contains(lesson.id)) {
          picked = picked.toggleLesson(topic, lesson);
        }
      }
    }
    return picked;
  }

  /// Topics whose available lessons are fully picked.
  final Set<TopicId> _wholeTopics;

  /// Lessons ticked individually, keyed by topic so a lesson id colliding
  /// across topics cannot merge two selections.
  final Map<TopicId, Set<LessonId>> _lessons;

  bool get isEmpty =>
      _wholeTopics.isEmpty && _lessons.values.every((s) => s.isEmpty);

  PracticeSelection cleared() => const PracticeSelection.empty();

  PracticeCheckState topicState(PracticeTopicEntry topic) {
    if (_wholeTopics.contains(topic.id)) return PracticeCheckState.on;
    final kept = _lessons[topic.id] ?? const <LessonId>{};
    if (kept.isEmpty) return PracticeCheckState.off;
    return PracticeCheckState.partial;
  }

  bool lessonSelected(LessonId lessonId) =>
      _lessons.values.any((kept) => kept.contains(lessonId));

  /// Tapping the row. Off and partial both fill; on empties.
  PracticeSelection toggleTopic(PracticeTopicEntry topic) {
    if (!topic.hasQuestions ||
        (topic.lessons.isNotEmpty &&
            !topic.lessons.any((lesson) => lesson.questionCount > 0))) {
      return this;
    }
    if (topicState(topic) == PracticeCheckState.on) {
      return PracticeSelection._(
        {..._wholeTopics}..remove(topic.id),
        _withoutTopic(topic.id),
      );
    }
    return PracticeSelection._(
      {..._wholeTopics, topic.id},
      // Selecting a topic selects every lesson beneath it. Held explicitly so
      // unticking one afterwards leaves the rest, which is what the dash
      // means.
      {
        ..._lessons,
        topic.id: {
          for (final lesson in topic.lessons)
            if (lesson.questionCount > 0) lesson.id,
        },
      },
    );
  }

  PracticeSelection toggleLesson(
    PracticeTopicEntry topic,
    PracticeLessonEntry lesson,
  ) {
    if (lesson.questionCount == 0) return this;
    final kept = {...?_lessons[topic.id]};
    if (!kept.remove(lesson.id)) kept.add(lesson.id);

    final lessons = {..._lessons};
    if (kept.isEmpty) {
      lessons.remove(topic.id);
    } else {
      lessons[topic.id] = kept;
    }

    // Any lesson-level change drops the topic out of "whole". A topic with
    // every lesson still ticked reads as partial rather than on, which is
    // wrong, so restore "whole" when the set is complete again.
    final isWhole = topic.lessons.isNotEmpty &&
        kept.length == topic.lessons.where((l) => l.questionCount > 0).length;
    final wholeTopics = {..._wholeTopics};
    if (isWhole) {
      wholeTopics.add(topic.id);
    } else {
      wholeTopics.remove(topic.id);
    }

    return PracticeSelection._(wholeTopics, lessons);
  }

  /// The units the footer counts and the session draws from.
  ///
  /// A full topic contributes each available lesson, just as individual picks
  /// do. Untagged topic callers retain their existing topic-level fallback.
  List<PracticeUnit> units(PracticeIndex index) {
    final units = <PracticeUnit>[];
    for (final topic in index.allTopics) {
      if (_wholeTopics.contains(topic.id) && topic.lessons.isEmpty) {
        units.add(PracticeUnit(topicId: topic.id));
        continue;
      }
      for (final lesson in topic.lessons) {
        if (lesson.questionCount > 0 &&
            (_lessons[topic.id] ?? const <LessonId>{}).contains(lesson.id)) {
          units.add(PracticeUnit(topicId: topic.id, lessonId: lesson.id));
        }
      }
    }
    return units;
  }

  Set<LessonId> get selectedLessonIds =>
      Set.unmodifiable(_lessons.values.expand((ids) => ids));

  Map<TopicId, Set<LessonId>> _withoutTopic(TopicId topicId) {
    return {..._lessons}..remove(topicId);
  }
}
