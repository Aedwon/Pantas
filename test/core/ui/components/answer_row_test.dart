import 'package:cse_cet_reviewer/core/ui/components/answer_row.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(Widget child) =>
    MaterialApp(theme: buildLightTheme(), home: Scaffold(body: child));

void main() {
  testWidgets('selected row fills with board tint and border',
      (tester) async {
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
    expect(decoration.borderRadius, BorderRadius.circular(5));
  });

  testWidgets('plain row has no fill and a faint bottom rule',
      (tester) async {
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

  testWidgets('tap fires callback and row meets 44px', (tester) async {
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
      greaterThanOrEqualTo(44),
    );
  });
}
