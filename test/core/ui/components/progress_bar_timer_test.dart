import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_tag.dart';
import 'package:pantas/core/ui/components/pantas_timer.dart';
import 'package:pantas/core/ui/components/progress_bar.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/ds_matrix.dart';

PantasColors _palette(DsCell cell) =>
    cell.dark ? PantasColors.dark : PantasColors.light;

void main() {
  dsMatrix(
    'progress bar: 5 px track, accent fill, label row',
    (context) => const SizedBox(
      width: 280,
      child: Column(
        children: [
          PantasProgressBar(
            value: .5,
            label: 'Question 3 of 6',
            valueText: 'Step 3 of 6',
          ),
          SizedBox(height: 8),
          PantasProgressBar(value: .25, warning: true),
        ],
      ),
    ),
    check: (tester, cell) async {
      final palette = _palette(cell);
      final fills = find.byKey(const ValueKey('progress-bar-fill'));
      expect(fills, findsNWidgets(2));
      Color colorOf(Finder f) =>
          (tester.widget<DecoratedBox>(f).decoration as BoxDecoration).color!;
      expect(colorOf(fills.first), palette.accent);
      expect(colorOf(fills.last), palette.warningText);
      expect(tester.getSize(fills.first).width, closeTo(140, .5));
      expect(tester.getSize(fills.first).height, 5);
      expect(find.text('Question 3 of 6'), findsOneWidget);
      expect(find.text('Step 3 of 6'), findsOneWidget);
    },
  );

  for (final state in PantasTimerState.values) {
    dsMatrix(
      'timer $state: time color, 120 by 5 bar, visible tag',
      (context) => PantasTimer(
        timeText: '4:32',
        fractionLeft: .1,
        state: state,
      ),
      check: (tester, cell) async {
        final palette = _palette(cell);
        final time =
            tester.widget<Text>(find.byKey(const ValueKey('timer-time')));
        expect(
          time.style!.color,
          switch (state) {
            PantasTimerState.running => palette.textPrimary,
            PantasTimerState.warning => palette.warningText,
            PantasTimerState.paused => palette.textSecondary,
          },
        );
        expect(time.style!.fontSize, 17);
        expect(time.style!.fontWeight, FontWeight.w700);
        expect(
          find.byType(PantasTag),
          state == PantasTimerState.running ? findsNothing : findsOneWidget,
        );
        expect(
          find.text(
            switch (state) {
              PantasTimerState.warning => '5 min left',
              PantasTimerState.paused => 'Paused',
              PantasTimerState.running => 'none',
            },
          ),
          state == PantasTimerState.running ? findsNothing : findsOneWidget,
        );
        final bar = find.byType(PantasProgressBar);
        expect(tester.getSize(bar).width, 120);
        final fill = tester.widget<DecoratedBox>(
          find.byKey(const ValueKey('progress-bar-fill')),
        );
        expect(
          (fill.decoration as BoxDecoration).color,
          state == PantasTimerState.warning
              ? palette.warningText
              : palette.accent,
        );
      },
    );
  }
}
