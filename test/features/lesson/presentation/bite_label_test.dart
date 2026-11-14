import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/lesson_label.dart';
import 'package:pantas/features/lesson/application/lesson_bite_label.dart';
import 'package:pantas/features/quiz/application/quiz_starts.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('biteLabelText', () {
    test('split lesson reads "Part 2 of 9 · 3 questions"', () {
      expect(
        biteLabelText(part: 2, partCount: 9, questions: 3),
        'Part 2 of 9 · 3 questions',
      );
    });

    test('unsplit lesson reads "5 questions" only', () {
      expect(
        biteLabelText(part: null, partCount: null, questions: 5),
        '5 questions',
      );
    });

    test('one question is singular', () {
      expect(
        biteLabelText(part: 1, partCount: 2, questions: 1),
        'Part 1 of 2 · 1 question',
      );
    });

    test('no questions leaves the part alone, or nothing', () {
      expect(
        biteLabelText(part: 2, partCount: 9, questions: 0),
        'Part 2 of 9',
      );
      expect(biteLabelText(part: null, partCount: null, questions: 0), isNull);
    });
  });

  group('LessonBiteLabel', () {
    Future<void> pump(
      WidgetTester tester, {
      int? part,
      int? partCount,
      int count = 3,
    }) async {
      await tester.pumpAppWithProviders(
        Scaffold(
          body: SizedBox(
            width: 390,
            child: LessonBiteLabel(
              lessonId: 'l1',
              part: part,
              partCount: partCount,
            ),
          ),
        ),
        overrides: [
          lessonQuizCountProvider('l1').overrideWith((_) async => count),
        ],
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('shows the count from the quiz-count provider', (tester) async {
      await pump(tester, part: 2, partCount: 9);
      expect(find.text('Part 2 of 9 · 3 questions'), findsOneWidget);
    });

    testWidgets('unsplit lesson shows only the count', (tester) async {
      await pump(tester, count: 5);
      expect(find.text('5 questions'), findsOneWidget);
    });

    testWidgets('never shows minutes', (tester) async {
      await pump(tester, part: 2, partCount: 9);
      expect(find.textContaining('min'), findsNothing);
    });
  });

  testWidgets('the header shows the part before the count arrives',
      (tester) async {
    final gate = Completer<int>();
    await tester.pumpAppWithProviders(
      const Scaffold(
        body: LessonBiteLabel(
          lessonId: 'l1',
          part: 2,
          partCount: 9,
          prefix: 'Philippine Constitution',
        ),
      ),
      overrides: [
        lessonQuizCountProvider('l1').overrideWith((_) => gate.future),
      ],
    );
    expect(find.text('Philippine Constitution · Part 2 of 9'), findsOneWidget);
    gate.complete(3);
    await tester.pump();
    await tester.pump();
    expect(
      find.text('Philippine Constitution · Part 2 of 9 · 3 questions'),
      findsOneWidget,
    );
  });
}
