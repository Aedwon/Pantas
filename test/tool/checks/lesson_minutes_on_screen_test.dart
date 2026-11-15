import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/lesson_minutes_on_screen.dart';

void main() {
  test('a widget that reads estimatedMinutes fails', () {
    final found = findLessonMinutesOnScreen(
      'lib/features/lesson/presentation/widgets/row.dart',
      r"final t = Text('${lesson.estimatedMinutes} min');",
    );
    expect(found.single.where, endsWith('row.dart:1'));
    expect(found.single.message, contains('estimatedMinutes'));
    expect(found.single.acceptedBecause, isNull);
  });

  test('so does the summed minutes left to read', () {
    final found = findLessonMinutesOnScreen(
      'lib/features/lesson/presentation/study_page.dart',
      '\n\nfinal n = map.minutesLeftToRead;',
    );
    expect(found.single.where, endsWith('study_page.dart:3'));
  });

  test('a comment or code outside presentation passes', () {
    expect(
      findLessonMinutesOnScreen(
        'lib/features/lesson/presentation/row.dart',
        '// the old estimatedMinutes label was removed',
      ),
      isEmpty,
    );
    expect(
      findLessonMinutesOnScreen(
        'lib/core/content/remote/content_mirror.dart',
        'final m = lesson.estimatedMinutes;',
      ),
      isEmpty,
    );
  });

  test('the practice session length is a known exception', () {
    final found = findLessonMinutesOnScreen(
      'lib/features/quiz/presentation/practice_picker_screen.dart',
      'final m = summary.estimatedMinutes;',
    );
    expect(found.single.acceptedBecause, isNotNull);
  });
}
