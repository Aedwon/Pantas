import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/roadmap/data/topic_prerequisites.dart';
import 'package:pantas/features/roadmap/domain/lesson_links.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/roadmap/domain/topic_links.dart';

void main() {
  final topics = {
    ...topicPrerequisites.keys,
    ...topicPrerequisites.values.expand((ids) => ids),
  };
  final lessons = [
    for (final topic in topics)
      RoadmapLesson(id: 'lesson_$topic', topicId: topic, ordering: 0),
  ];
  test('no lesson links preserves the old topic map', () {
    final derived = TopicLinks.derive(
      LessonGraph.build(const {}, lessons.map((l) => l.id)),
      lessons,
    );
    expect(TopicLinks.mergeLegacy(derived), topicPrerequisites);
  });
  test('four required UPCAT lesson links derive exactly the old map', () {
    final links = {
      for (final entry in topicPrerequisites.entries)
        'lesson_${entry.key}': [
          for (final target in entry.value)
            LessonLink(
              lessonId: 'lesson_$target',
              strength: LinkStrength.required,
            ),
        ],
    };
    final derived = TopicLinks.derive(
      LessonGraph.build(links, lessons.map((l) => l.id)),
      lessons,
    );
    expect(derived, topicPrerequisites);
    expect(TopicLinks.mergeLegacy(derived), topicPrerequisites);
  });
  test('adds CSE links once and excludes helpful and same-topic links', () {
    const cseLessons = [
      RoadmapLesson(id: 'a', topicId: 'cse_algebra', ordering: 0),
      RoadmapLesson(id: 'b', topicId: 'cse_arithmetic', ordering: 0),
      RoadmapLesson(id: 'c', topicId: 'cse_arithmetic', ordering: 1),
      RoadmapLesson(id: 'd', topicId: 'cse_other', ordering: 0),
    ];
    final graph = LessonGraph.build(
      {
        'a': [
          const LessonLink(lessonId: 'b', strength: LinkStrength.required),
          const LessonLink(lessonId: 'c', strength: LinkStrength.required),
          const LessonLink(lessonId: 'd', strength: LinkStrength.helpful),
        ],
        'c': [const LessonLink(lessonId: 'b', strength: LinkStrength.required)],
      },
      cseLessons.map((l) => l.id),
    );
    expect(TopicLinks.mergeLegacy(TopicLinks.derive(graph, cseLessons)), {
      ...topicPrerequisites,
      'cse_algebra': ['cse_arithmetic'],
    });
  });
}
