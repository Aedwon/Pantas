import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/new_design/passage_card.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';

import '../../../helpers/accessibility.dart';

/// Gaps the golden sheets found between the app's components and the system
/// READMEs (EmptyState, ErrorState, ProgressRing, Passage, Field).
void main() {
  for (final brightness in Brightness.values) {
    group('$brightness', () {
      testWidgets('Try Again is a rounded rectangle, not a pill',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          StateView(message: 'Something went wrong.', onRetry: () {}),
          brightness: brightness,
          disableAnimations: true,
        );
        final button = tester.widget<PantasButton>(find.byType(PantasButton));
        expect(
          button.radius == null || button.radius! < PantasRadius.full,
          true,
        );
      });

      testWidgets('a full ring is replaced by the done disc at its own size',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          const ProgressRing(fraction: 1, size: 44),
          brightness: brightness,
          disableAnimations: true,
        );
        expect(
          tester.getSize(find.byKey(const ValueKey('check-mark-circle'))),
          const Size.square(44),
        );
      });

      testWidgets('an empty ring has a `divider` track in light',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          const ProgressRing(fraction: 0),
          brightness: brightness,
          disableAnimations: true,
        );
        final colors = tester
            .element(find.byKey(const ValueKey('progress-ring-paint')))
            .colors;
        final expected = brightness == Brightness.light
            ? colors.divider
            : colors.iconChevron;
        expect(
          find.byKey(const ValueKey('progress-ring-paint')),
          paints..circle(color: expected),
        );
      });

      testWidgets('a passage is a surface-card with a Passage label',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          const PassageCard(title: 'The river', text: 'It bent twice.'),
          brightness: brightness,
          disableAnimations: true,
        );
        final colors = tester.element(find.byType(PassageCard)).colors;
        expect(find.text('PASSAGE'), findsOneWidget);
        final surface = tester
            .widgetList<DecoratedBox>(
              find.descendant(
                of: find.byType(PassageCard),
                matching: find.byType(DecoratedBox),
              ),
            )
            .map((box) => box.decoration)
            .whereType<BoxDecoration>()
            .firstWhere((d) => d.color == colors.surfaceCard);
        expect(surface.borderRadius, isNotNull);
      });

      testWidgets('the error state icon is the system alert triangle',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          StateView(message: 'Something went wrong.', onRetry: () {}),
          brightness: brightness,
          disableAnimations: true,
        );
        final icon = tester.widget<Icon>(
          find.descendant(
            of: find.byKey(const ValueKey('state-mark')),
            matching: find.byType(Icon),
          ),
        );
        expect(icon.icon, PantasIcons.alert);
      });

      testWidgets('help text carries an icon, as the error line does',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          const PantasFieldMessage('We use it to plan your weeks.'),
          brightness: brightness,
        );
        expect(
          find.descendant(
            of: find.byType(PantasFieldMessage),
            matching: find.byType(Icon),
          ),
          findsOneWidget,
        );
      });
    });
  }
}
