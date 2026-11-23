import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The "Part 2 of 9 · 3 questions" lesson label and its shortened forms
/// ("Part 2 of 9", "3 questions", "Topic · Part 2 of 9"). Aedwon, Nov 23:
/// "the labels are unnecessary information that the user does not need to
/// know". "Quiz yourself, 3 questions" is a button, not this label.
final RegExp partLabelPattern = RegExp(
  r'(^|\s)Part \d+ of \d+|^\d+ questions?$|· \d+ questions?$',
);

/// Fails if any text on screen reads like the lesson part label.
void expectNoPartLabel() {
  final shown = <String>[
    for (final w in find.byType(Text).evaluate().map((e) => e.widget as Text))
      w.data ?? w.textSpan?.toPlainText() ?? '',
    for (final w
        in find.byType(RichText).evaluate().map((e) => e.widget as RichText))
      w.text.toPlainText(),
  ];
  expect(
    shown.where(partLabelPattern.hasMatch),
    isEmpty,
    reason: 'the part label must not appear on any screen',
  );
}
