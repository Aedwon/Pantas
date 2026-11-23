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

  group('part label', () {
    test('the label builder fails anywhere in lib', () {
      final found = findPartLabelOnScreen(
        'lib/features/lesson/presentation/widgets/row.dart',
        'footer: LessonBiteLabel(lessonId: id, part: 2, partCount: 9),',
      );
      expect(found.single.where, endsWith('row.dart:1'));
      expect(found.single.message, contains('LessonBiteLabel'));
      expect(
        findPartLabelOnScreen(
          'lib/core/ui/components/lesson_label.dart',
          'final s = biteLabelText(part: 1, partCount: 2, questions: 3);',
        ),
        isNotEmpty,
      );
    });

    test('a string that spells the label on a lesson screen fails', () {
      for (final code in [
        r"final t = 'Part $part of $partCount';",
        r"final t = 'Part ${l.part} of ${l.partCount} · $n questions';",
        r"final t = '$count questions';",
        r"final t = '$topic · $count questions';",
      ]) {
        expect(
          findPartLabelOnScreen(
            'lib/features/home/presentation/widgets/home_row.dart',
            code,
          ),
          isNotEmpty,
          reason: code,
        );
      }
    });

    test('the quiz button, mock parts and comments pass', () {
      expect(
        findPartLabelOnScreen(
          'lib/features/lesson/presentation/widgets/reader_gap.dart',
          'final t = quizButtonLabel(count);',
        ),
        isEmpty,
      );
      expect(
        findPartLabelOnScreen(
          'lib/features/mock_exam/presentation/pages/mock_session_page.dart',
          r"final t = 'Part $part of ${names.length} · ';",
        ),
        isEmpty,
      );
      expect(
        findPartLabelOnScreen(
          'lib/features/lesson/presentation/row.dart',
          '// was LessonBiteLabel, "Part 2 of 9"',
        ),
        isEmpty,
      );
    });
  });
}
