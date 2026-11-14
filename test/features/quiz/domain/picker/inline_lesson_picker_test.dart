import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/picker/inline_lesson_picker.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';

Question _q(String id, {int? keyPoint}) => Question(
      id: id,
      version: 1,
      examIds: const ['exam'],
      topicId: 'topic',
      lessonId: 'lesson',
      keyPoint: keyPoint,
      language: 'en',
      stem: id,
      choices: const [
        Choice(id: 'a', label: 'A', text: 'a', isCorrect: true),
        Choice(id: 'b', label: 'B', text: 'b', isCorrect: false),
      ],
      explanation: id,
    );

List<Question> _pick(
  List<Question> pool,
  int size, {
  Set<String> seen = const {},
  int seed = 1,
}) =>
    InlineLessonPicker().pick(
      PickContext(
        allQuestions: pool,
        requestedLength: size,
        excludedQuestionIds: seen,
        shuffleSeed: seed,
      ),
    );

void main() {
  test('size follows the requested length', () {
    final pool = [for (var i = 0; i < 12; i++) _q('q$i', keyPoint: i % 4)];
    expect(_pick(pool, 4), hasLength(4));
    expect(_pick(pool, 6), hasLength(6));
    expect(_pick(pool, 2), hasLength(2));
  });

  test('unsplit lesson with five requested gives five', () {
    final pool = [for (var i = 0; i < 9; i++) _q('q$i')];
    expect(_pick(pool, 5), hasLength(5));
  });

  test('short pool gives the whole pool', () {
    final pool = [for (var i = 0; i < 3; i++) _q('q$i', keyPoint: i)];
    expect(_pick(pool, 5), hasLength(3));
  });

  test('K=2 and size 4 covers both key points, for every seed', () {
    final pool = [
      for (var i = 0; i < 5; i++) _q('a$i', keyPoint: 0),
      for (var i = 0; i < 5; i++) _q('b$i', keyPoint: 1),
    ];
    for (var seed = 0; seed < 30; seed++) {
      final picked = _pick(pool, 4, seed: seed);
      expect(picked, hasLength(4));
      expect(picked.map((q) => q.keyPoint).toSet(), {0, 1});
    }
  });

  test('one per key point comes before any repeat', () {
    final pool = [
      for (var i = 0; i < 6; i++) _q('a$i', keyPoint: 0),
      for (var i = 0; i < 2; i++) _q('b$i', keyPoint: 1),
      for (var i = 0; i < 2; i++) _q('c$i', keyPoint: 2),
    ];
    for (var seed = 0; seed < 30; seed++) {
      final picked = _pick(pool, 3, seed: seed);
      expect(picked.map((q) => q.keyPoint).toSet(), {0, 1, 2});
    }
  });

  test('fresh before seen, within a key point and in the fill', () {
    final pool = [
      for (var i = 0; i < 3; i++) _q('a$i', keyPoint: 0),
      for (var i = 0; i < 3; i++) _q('b$i', keyPoint: 1),
    ];
    final seen = {'a0', 'a1', 'b0'};
    for (var seed = 0; seed < 30; seed++) {
      final picked = _pick(pool, 4, seen: seen, seed: seed);
      final ids = picked.map((q) => q.id).toSet();
      expect(ids, containsAll(['a2', 'b1', 'b2']));
      expect(ids.where(seen.contains), hasLength(1));
    }
  });

  test('a key point with no questions is skipped and the fill covers it', () {
    final pool = [
      for (var i = 0; i < 4; i++) _q('a$i', keyPoint: 0),
      for (var i = 0; i < 4; i++) _q('c$i', keyPoint: 2),
    ];
    final picked = _pick(pool, 4);
    expect(picked, hasLength(4));
    expect(picked.map((q) => q.keyPoint).toSet(), {0, 2});
  });
}
