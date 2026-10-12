import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';

void main() {
  test('reader gets the selected lesson in the original day order', () {
    final context = LessonDayContext(
      date: DateTime(2026, 10, 12),
      lessonIds: const ['cell-biology', 'stoichiometry', 'circles'],
      index: 1,
    );

    expect(context.date, DateTime(2026, 10, 12));
    expect(context.lessonIds, ['cell-biology', 'stoichiometry', 'circles']);
    expect(context.index, 1);
    expect(context.lessonIds[context.index], 'stoichiometry');
  });

  test('day context keeps its lesson order after the caller changes its list',
      () {
    final lessons = ['first', 'second'];
    final context = LessonDayContext(
      date: DateTime(2026, 10, 12),
      lessonIds: lessons,
      index: 1,
    );

    lessons
      ..clear()
      ..add('different');
    expect(context.lessonIds, ['first', 'second']);
    expect(() => context.lessonIds.add('third'), throwsUnsupportedError);
  });

  test('a day context cannot select a lesson outside its day', () {
    for (final index in [-1, 2]) {
      expect(
        () => LessonDayContext(
          date: DateTime(2026, 10, 12),
          lessonIds: const ['first', 'second'],
          index: index,
        ),
        throwsRangeError,
      );
    }
  });

  test('a reader context needs a lesson', () {
    expect(
      () => LessonDayContext(
        date: DateTime(2026, 10, 12),
        lessonIds: const [],
        index: 0,
      ),
      throwsRangeError,
    );
  });
}
