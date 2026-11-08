import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/components/exam_name_line.dart';
import 'package:pantas/core/ui/components/score_breakdown_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/ds_matrix.dart';

void main() {
  dsMatrix(
    'StatRow: 16/400 name, 16/600 value, 12 padding, 8 gap, 5 high bar',
    (context) => const SizedBox(
      width: 360,
      child: Column(
        children: [
          ScoreBreakdownRow(
            name: 'Algebra',
            correct: 3,
            total: 4,
            divider: true,
          ),
          ScoreBreakdownRow(
            name: 'Geometry',
            correct: 1,
            total: 4,
            divider: false,
          ),
        ],
      ),
    ),
    check: (tester, cell) async {
      final c = tester.element(find.byType(ScoreBreakdownRow).first).colors;
      final name = tester.widget<Text>(find.text('Algebra'));
      expect(name.style!.fontSize, 16);
      expect(name.style!.fontWeight, FontWeight.w400);
      expect(name.style!.color, c.textPrimary);
      final percent = tester.widget<Text>(find.text('75%'));
      expect(percent.style!.fontSize, 16);
      expect(percent.style!.fontWeight, FontWeight.w600);
      final count = tester.widget<Text>(find.text('3 / 4'));
      expect(count.style!.color, c.textSecondary);
      final fills = find.byKey(const ValueKey('accuracy-bar-fill'));
      expect(fills, findsNWidgets(2));
      // The rule sits under the first row only.
      final first = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ScoreBreakdownRow).first,
              matching: find.byType(Container),
            )
            .first,
      );
      final border = (first.decoration! as BoxDecoration).border! as Border;
      expect(border.bottom.width, 0.5);
      expect(border.bottom.color, c.divider);
      final last = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ScoreBreakdownRow).last,
              matching: find.byType(Container),
            )
            .first,
      );
      expect((last.decoration! as BoxDecoration).border, isNull);
    },
  );

  dsMatrix(
    'StatRow stacks the values under the name at large text',
    (context) => const SizedBox(
      width: 360,
      child: ScoreBreakdownRow(
        name: 'Algebra',
        correct: 3,
        total: 4,
        divider: false,
      ),
    ),
    check: (tester, cell) async {
      final name = tester.getRect(find.text('Algebra'));
      final count = tester.getRect(find.text('3 / 4'));
      if (cell.scale > 1) {
        expect(count.top, greaterThanOrEqualTo(name.bottom - 1));
      } else {
        expect((count.center.dy - name.center.dy).abs(), lessThan(8));
      }
    },
  );

  dsMatrix(
    'an entrance clock fills the bar with the accuracy step color',
    (context) => const SizedBox(
      width: 360,
      child: ScoreBreakdownRow(
        name: 'Algebra',
        correct: 4,
        total: 4,
        divider: false,
        animatedAccuracy: .5,
      ),
    ),
    check: (tester, cell) async {
      final c = tester.element(find.byType(ScoreBreakdownRow)).colors;
      final fill = tester.widget<ColoredBox>(
        find.byKey(const ValueKey('accuracy-bar-fill')),
      );
      expect(fill.color, c.chart5);
      expect(
        tester.getSize(find.byKey(const ValueKey('accuracy-bar-fill'))).height,
        5,
      );
    },
  );

  dsMatrix(
    'Avatar letter: accent-tint circle, accent-tint-text initial',
    (context) => const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Avatar(name: 'Ada', size: Avatar.small),
        SizedBox(width: 8),
        Avatar(name: 'Bea', size: Avatar.large),
      ],
    ),
    check: (tester, cell) async {
      final c = tester.element(find.byType(Avatar).first).colors;
      for (final letter in ['A', 'B']) {
        final text = tester.widget<Text>(find.text(letter));
        expect(text.style!.color, c.accentTintText);
        expect(text.style!.fontWeight, FontWeight.w700);
      }
      final first = tester.getSize(find.byType(Avatar).first);
      final second = tester.getSize(find.byType(Avatar).last);
      if (cell.width < 1024) {
        expect(first, const Size(30, 30));
        expect(second, const Size(44, 44));
        expect(tester.widget<Text>(find.text('A')).style!.fontSize, 14);
        expect(tester.widget<Text>(find.text('B')).style!.fontSize, 20);
      } else {
        // Wide screens always draw the 44 circle with the 20 initial.
        expect(first, const Size(44, 44));
        expect(tester.widget<Text>(find.text('A')).style!.fontSize, 20);
      }
      final circle = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Avatar).first,
              matching: find.byType(Container),
            )
            .first,
      );
      expect(circle.color, c.accentTint);
    },
  );

  dsMatrix(
    'ExamChip: 42 wide tile, radius 8, name 13/700, days left 13/400',
    (context) => const ExamChip(
      name: 'UPCAT',
      day: '14',
      month: 'Dec',
      daysLeft: '36 days left',
    ),
    check: (tester, cell) async {
      final c = tester.element(find.byType(ExamChip)).colors;
      final tile = tester.getSize(find.byKey(const ValueKey('exam-chip-tile')));
      expect(tile.width, closeTo(42 * cell.scale, .5));
      expect(tile.height, greaterThanOrEqualTo(36));
      final day = tester.widget<Text>(find.text('14'));
      expect(day.style!.fontSize, 14);
      expect(day.style!.fontWeight, FontWeight.w700);
      final month = tester.widget<Text>(find.text('DEC'));
      expect(month.style!.fontSize, 11);
      expect(month.style!.color, c.textSecondary);
      final name = tester.widget<Text>(find.text('UPCAT'));
      expect(name.style!.fontSize, 13);
      expect(name.style!.fontWeight, FontWeight.w700);
      final days = tester.widget<Text>(find.text('36 days left'));
      expect(days.style!.fontSize, 13);
      expect(days.style!.color, c.textSecondary);
    },
  );

  dsMatrix(
    'empty ExamChip shows a dashed tile with "--" and "DATE"',
    (context) => const ExamChip.empty(trailing: Text('Add Date')),
    check: (tester, cell) async {
      expect(find.text('--'), findsOneWidget);
      expect(find.text('DATE'), findsOneWidget);
      expect(find.text('Add Date'), findsOneWidget);
    },
  );
}
