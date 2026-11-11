import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/roadmap/domain/lesson_links.dart';
import 'package:pantas/features/roadmap/domain/lesson_mastery.dart';

void main() {
  const required = LinkStrength.required;
  const helpful = LinkStrength.helpful;
  test('scopes links and drops cycle-closing edges deterministically', () {
    final links = {
      'b': [const LessonLink(lessonId: 'a', strength: helpful)],
      'a': [
        const LessonLink(lessonId: 'b', strength: required),
        const LessonLink(lessonId: 'outside', strength: required),
      ],
    };
    final graph = LessonGraph.build(links, ['b', 'a']);
    expect(graph.cycleDetected, isTrue);
    expect(graph.requiredOf('a'), ['b']);
    expect(graph.helpfulOf('b'), isEmpty);
    expect(graph.requiredOf('outside'), isEmpty);
    final reordered = LessonGraph.build(
      {'a': links['a']!, 'b': links['b']!},
      ['a', 'b'],
    );
    expect(reordered.requiredOf('a'), graph.requiredOf('a'));
    expect(reordered.helpfulOf('b'), graph.helpfulOf('b'));
    expect(graph.requiredOf('a').clear, throwsUnsupportedError);
  });

  test('shared prerequisites are not cycles and helpful links stay separate',
      () {
    final graph = LessonGraph.build({
      'a': [
        const LessonLink(lessonId: 'c', strength: required),
        const LessonLink(lessonId: 'b', strength: helpful),
      ],
      'b': [const LessonLink(lessonId: 'c', strength: required)],
    }, [
      'a',
      'b',
      'c',
    ]);
    expect(graph.cycleDetected, isFalse);
    expect(graph.requiredOf('a'), ['c']);
    expect(graph.helpfulOf('a'), ['b']);
  });

  test('first unmet walks deepest required links and ignores helpful links',
      () {
    final graph = LessonGraph.build({
      't': [
        const LessonLink(lessonId: 'r1', strength: required),
        const LessonLink(lessonId: 'h', strength: helpful),
      ],
      'r1': [const LessonLink(lessonId: 'r2', strength: required)],
    }, [
      't',
      'r1',
      'r2',
      'h',
    ]);
    LessonMastery mastery(String id, MasteryKind kind) => LessonMastery(
          id: id,
          kind: kind,
          answered: 5,
          recentAccuracy: 1,
          recall: null,
        );
    final states = {
      'r1': mastery('r1', MasteryKind.weak),
      'r2': mastery('r2', MasteryKind.weak),
      'h': mastery('h', MasteryKind.unseen),
    };
    expect(LessonGraph.firstUnmet('t', graph, states), 'r2');
    states['r2'] = mastery('r2', MasteryKind.solid);
    expect(LessonGraph.firstUnmet('t', graph, states), 'r1');
    states['r1'] = mastery('r1', MasteryKind.learning);
    expect(LessonGraph.firstUnmet('t', graph, states), isNull);
    states['r1'] = mastery('r1', MasteryKind.unseen);
    expect(LessonGraph.firstUnmet('t', graph, states), 'r1');
  });
}
