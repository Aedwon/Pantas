import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

import '../../../helpers/ds_matrix.dart';

void main() {
  dsMatrix(
    'ErrorState fits every width, theme and text scale',
    (context) => StateView(
      message: 'We could not load this',
      detail: 'Check your connection and try again.',
      onRetry: () {},
    ),
    check: (tester, cell) async {
      final colors = tester.element(find.byType(StateView)).colors;
      // A 40 point muted icon, never red.
      expect(
        tester.getSize(find.byKey(const ValueKey('state-mark'))),
        const Size(40, 40),
      );
      final mark = tester
          .widget<IconTheme>(find.byKey(const ValueKey('state-icon-theme')));
      expect(mark.data.color, colors.iconMuted);
      final title = tester.widget<Text>(find.text('We could not load this'));
      final wide = cell.width >= 1024;
      expect(
        title.style!.fontSize,
        (wide ? PantasType.webH3 : PantasType.phoneTitle3).fontSize,
      );
      expect(title.style!.color, colors.textPrimary);
      final line = tester
          .widget<Text>(find.text('Check your connection and try again.'));
      expect(line.style!.color, colors.textSecondary);
      expect(
        tester.getSize(find.text('Check your connection and try again.')).width,
        lessThanOrEqualTo(PantasLayout.colListMax),
      );
      // One 44 high tonal action. It fills the phone width up to the text
      // measure and keeps its natural width on a wide screen.
      final action = tester.widget<PantasButton>(find.byType(PantasButton));
      expect(action.variant, PantasButtonVariant.secondary);
      expect(action.height, PantasSize.btn);
      expect(
        tester.getSize(find.byType(PantasButton)).height,
        greaterThanOrEqualTo(PantasSize.btn),
      );
      expect(action.fullWidth, !wide);
    },
  );

  dsMatrix(
    'EmptyState keeps its natural-width action centered',
    (context) => StateView(
      message: 'No bookmarks yet',
      detail: 'Tap the flag on a question to keep it here.',
      icon: Icon(PantasIcons.bookmark),
      actionLabel: 'Browse Questions',
      onRetry: () {},
    ),
    check: (tester, cell) async {
      final action = tester.widget<PantasButton>(find.byType(PantasButton));
      expect(action.fullWidth, isFalse);
      final state = tester.getRect(find.byType(StateView));
      final button = tester.getRect(find.byType(PantasButton));
      expect((button.center.dx - state.center.dx).abs(), lessThan(1));
    },
  );

  testWidgets('ErrorState action is reachable by keyboard', (tester) async {
    var retries = 0;
    await pumpDs(
      tester,
      dsCells.first,
      StateView(
        message: 'Failed',
        detail: 'Try again.',
        onRetry: () => retries++,
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(retries, 1);
  });

  for (final cell in dsCells) {
    testWidgets('Full-screen error state ($cell)', (tester) async {
      await pumpDs(
        tester,
        cell,
        StateView.fullScreen(onRetry: () {}),
        scroll: false,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Try Again'), findsOneWidget);
    });
  }
}
