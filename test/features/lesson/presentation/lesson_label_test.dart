import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/lesson_label.dart';

import '../../../helpers/no_part_label.dart';
import '../../../helpers/pump_app.dart';

void main() {
  group('quizButtonLabel', () {
    test('says the count the quiz will serve', () {
      expect(quizButtonLabel(3), 'Quiz yourself, 3 questions');
      expect(quizButtonLabel(1), 'Quiz yourself, 1 question');
    });

    test('says only "Quiz yourself" until the count is known', () {
      expect(quizButtonLabel(null), 'Quiz yourself');
      expect(quizButtonLabel(0), 'Quiz yourself');
    });
  });

  group('partLabelPattern', () {
    test('catches the label and its shortened forms', () {
      for (final text in [
        'Part 2 of 9 · 3 questions',
        'Part 2 of 9',
        '5 questions',
        '1 question',
        'Geometry · Part 2 of 9 · 3 questions',
        'Geometry · 3 questions',
      ]) {
        expect(partLabelPattern.hasMatch(text), isTrue, reason: text);
      }
    });

    test('leaves the quiz button and other copy alone', () {
      for (final text in [
        'Quiz yourself, 5 questions',
        'New questions',
        'Up next · Chemistry',
        'Geometry',
      ]) {
        expect(partLabelPattern.hasMatch(text), isFalse, reason: text);
      }
    });
  });

  group('lessonTopicFooter', () {
    testWidgets('is nothing without a topic', (tester) async {
      Widget? footer = const SizedBox();
      await tester.pumpApp(
        Builder(
          builder: (context) {
            footer = lessonTopicFooter(context, null);
            return const SizedBox();
          },
        ),
      );
      expect(footer, isNull);
    });

    testWidgets('is the topic alone, with no part or count', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) =>
              lessonTopicFooter(context, 'Philippine Constitution')!,
        ),
      );
      expect(find.text('Philippine Constitution'), findsOneWidget);
      expectNoPartLabel();
    });
  });
}
