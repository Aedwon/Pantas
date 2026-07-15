import 'package:cse_cet_reviewer/core/ui/components/pennant_mark.dart';
import 'package:cse_cet_reviewer/core/ui/components/question_grid_sheet.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/widgets/mock_question_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MockGridPart part(
    String name,
    int count, {
    required int startIndex,
    bool isOpen = true,
  }) {
    return MockGridPart(
      name: name,
      startIndex: startIndex,
      count: count,
      isOpen: isOpen,
    );
  }

  Widget harness({
    required List<MockGridPart> parts,
    int currentIndex = 0,
    Set<int> answered = const {},
    Set<int> flagged = const {},
    ValueChanged<int>? onTap,
  }) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: MockQuestionGrid(
            parts: parts,
            currentIndex: currentIndex,
            answeredIndexes: answered,
            flaggedIndexes: flagged,
            onTap: onTap ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('six columns', (tester) async {
    await tester.pumpWidget(
      harness(parts: [part('Reading', 12, startIndex: 0)]),
    );

    expect(
      tester.widgetList<QuestionGridSheet>(find.byType(QuestionGridSheet)).first
          .columns,
      6,
    );
  });

  testWidgets('each part heading carries its count', (tester) async {
    await tester.pumpWidget(
      harness(
        parts: [
          part('Reading', 40, startIndex: 0),
          part('Maths', 30, startIndex: 40),
        ],
      ),
    );

    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('40'), findsWidgets);
    expect(find.text('Maths'), findsOneWidget);
    expect(find.text('30'), findsWidgets);
  });

  testWidgets('answered and flagged shows both marks', (tester) async {
    await tester.pumpWidget(
      harness(
        parts: [part('Reading', 6, startIndex: 0)],
        answered: {0},
        flagged: {0},
      ),
    );

    expect(find.byKey(const ValueKey('mock-cell-dot')), findsOneWidget);
    expect(find.byType(PennantMark), findsOneWidget);
  });

  testWidgets('no cell ever shows an outcome', (tester) async {
    await tester.pumpWidget(
      harness(
        parts: [part('Reading', 12, startIndex: 0)],
        answered: {0, 1, 2, 3},
        flagged: {2},
      ),
    );

    expect(find.text('✓'), findsNothing);
    expect(find.text('✕'), findsNothing);
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      expect(t.style?.color, isNot(AppColors.light.rust));
      expect(t.style?.color, isNot(AppColors.light.board));
    }
  });

  testWidgets('an unopened part is dimmed and untappable', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(
      harness(
        parts: [
          part('Reading', 40, startIndex: 0),
          part('Maths', 6, startIndex: 40, isOpen: false),
        ],
        onTap: taps.add,
      ),
    );

    await tester.tap(find.text('41'), warnIfMissed: false);
    expect(taps, isEmpty);
    expect(find.text('Opens when this part starts.'), findsOneWidget);
  });

  testWidgets('a cell in an open part reports its index', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(
      harness(
        parts: [part('Reading', 12, startIndex: 0)],
        onTap: taps.add,
      ),
    );

    await tester.tap(find.text('7'));
    // The grid counts from one and the session pages from zero.
    expect(taps, [6]);
  });
}
