import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/answer_row.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

Widget harness(Widget child) =>
    MaterialApp(theme: buildLightTheme(), home: Scaffold(body: child));

void main() {
  testWidgets('selected row fills with board tint and border', (tester) async {
    await tester.pumpWidget(
      harness(
        AnswerRow(
          letter: 'B',
          text: 'Manila',
          onTap: () {},
          state: AnswerRowState.selected,
        ),
      ),
    );
    final box = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(AnswerRow),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = box.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.light.boardTint);
    expect(decoration.border!.top.color, AppColors.light.board);
    expect(decoration.borderRadius, BorderRadius.circular(14));
  });

  testWidgets('plain row has no fill and a faint bottom rule', (tester) async {
    await tester.pumpWidget(
      harness(AnswerRow(letter: 'A', text: 'Cebu', onTap: () {})),
    );
    final box = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(AnswerRow),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = box.decoration! as BoxDecoration;
    expect(decoration.color, isNull);
    expect(decoration.border!.bottom.color, AppColors.light.ruleFaint);
  });

  testWidgets('graded states show glyphs, never emoji', (tester) async {
    for (final (state, glyph) in [
      (AnswerRowState.correct, '✓'),
      (AnswerRowState.incorrect, '✕'),
      (AnswerRowState.correctMissed, '✓'),
    ]) {
      await tester.pumpWidget(
        harness(
          AnswerRow(letter: 'C', text: 'Davao', onTap: () {}, state: state),
        ),
      );
      expect(find.text(glyph), findsOneWidget);
      expect(find.textContaining('✅'), findsNothing);
      expect(find.textContaining('❌'), findsNothing);
      expect(find.textContaining('💡'), findsNothing);
    }
  });

  testWidgets('tap fires callback and row meets 48dp', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      harness(
        AnswerRow(letter: 'D', text: 'Iloilo', onTap: () => tapped = true),
      ),
    );
    await tester.tap(find.byType(AnswerRow));
    expect(tapped, isTrue);
    expect(
      tester.getSize(find.byType(AnswerRow)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('selection and graded result are exposed once', (tester) async {
    await tester.pumpWidget(
      harness(
        AnswerRow(
          letter: 'B',
          text: 'Manila',
          onTap: () {},
          state: AnswerRowState.selected,
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('B. Manila')),
      matchesSemantics(
        label: 'B. Manila',
        value: 'Selected',
        hasSelectedState: true,
        isSelected: true,
        hasEnabledState: true,
        isEnabled: true,
        isButton: true,
        hasTapAction: true,
      ),
    );

    await tester.pumpWidget(
      harness(
        AnswerRow(
          letter: 'B',
          text: 'Manila',
          onTap: () {},
          state: AnswerRowState.incorrect,
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('B. Manila')),
      matchesSemantics(
        label: 'B. Manila',
        value: 'Incorrect, your answer',
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isButton: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('a choice carrying maths renders it rather than its dollars',
      (tester) async {
    // 645 of the 2,000 questions in the bank carry maths in a choice, and
    // every choice reached the screen through a plain Text.
    await tester.pumpWidget(
      harness(
        AnswerRow(
          letter: 'A',
          text: r'$x^2$',
          onTap: () {},
        ),
      ),
    );

    expect(find.byType(Math), findsOneWidget);
    expect(find.textContaining(r'$'), findsNothing);
  });
}
