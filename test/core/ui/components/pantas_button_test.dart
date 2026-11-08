import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_parts.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../../../helpers/ds_matrix.dart';

PantasColors _colors(DsCell cell) =>
    cell.dark ? PantasColors.dark : PantasColors.light;

ButtonStyle _style(WidgetTester tester, [int index = 0]) =>
    tester.widget<TextButton>(find.byType(TextButton).at(index)).style!;

Color _bg(WidgetTester tester, int i, [Set<WidgetState> s = const {}]) =>
    _style(tester, i).backgroundColor!.resolve(s)!;
Color _fg(WidgetTester tester, int i, [Set<WidgetState> s = const {}]) =>
    _style(tester, i).foregroundColor!.resolve(s)!;

void main() {
  group('kind by tone', () {
    // Order: primary, primary critical, secondary, secondary critical,
    // neutral, tertiary, tertiary accent, tertiary critical, white.
    dsMatrix(
      'every pair reads its roles at rest and under hover',
      (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PantasButton(
            label: 'Save',
            kind: PantasButtonKind.primary,
            fullWidth: false,
            onPressed: () {},
          ),
          PantasButton(
            label: 'Delete',
            kind: PantasButtonKind.primary,
            tone: PantasButtonTone.critical,
            fullWidth: false,
            onPressed: () {},
          ),
          PantasButton(
            label: 'Maybe',
            kind: PantasButtonKind.secondary,
            fullWidth: false,
            onPressed: () {},
          ),
          PantasButton(
            label: 'Remove',
            kind: PantasButtonKind.secondary,
            tone: PantasButtonTone.critical,
            fullWidth: false,
            onPressed: () {},
          ),
          PantasButton(
            label: 'Later',
            kind: PantasButtonKind.neutral,
            fullWidth: false,
            onPressed: () {},
          ),
          PantasButton(
            label: 'Cancel',
            kind: PantasButtonKind.tertiary,
            fullWidth: false,
            onPressed: () {},
          ),
          PantasButton(
            label: 'Edit',
            kind: PantasButtonKind.tertiary,
            tone: PantasButtonTone.accent,
            fullWidth: false,
            onPressed: () {},
          ),
          PantasButton(
            label: 'Clear',
            kind: PantasButtonKind.tertiary,
            tone: PantasButtonTone.critical,
            fullWidth: false,
            onPressed: () {},
          ),
          PantasButton(
            label: 'Share',
            kind: PantasButtonKind.white,
            fullWidth: false,
            onPressed: () {},
          ),
        ],
      ),
      check: (tester, cell) async {
        final c = _colors(cell);
        const hover = {WidgetState.hovered};
        // On a phone there is no hover: the wash shows only when the layout
        // is wide, or while the button is pressed.
        const press = {WidgetState.pressed};
        final states = cell.width >= 1024 ? hover : press;
        // Primary.
        expect(_bg(tester, 0), c.accentFill);
        expect(_fg(tester, 0), c.onAccent);
        expect(_bg(tester, 0, states), c.accentFillHover);
        // Primary critical.
        expect(_bg(tester, 1), c.dangerFill);
        expect(_fg(tester, 1), c.onDanger);
        expect(_bg(tester, 1, states), c.dangerFillHover);
        // Secondary.
        expect(_bg(tester, 2), c.accentTint);
        expect(_fg(tester, 2), c.accentTintText);
        expect(_bg(tester, 2, states), c.accentTintHover);
        expect(_fg(tester, 2, states), c.accentHover);
        // Secondary critical: transparent, a 1.5 px danger ring.
        expect(_bg(tester, 3), Colors.transparent);
        expect(_fg(tester, 3), c.dangerText);
        expect(_style(tester, 3).side!.resolve({})!.color, c.danger);
        expect(_style(tester, 3).side!.resolve({})!.width, 1.5);
        expect(_fg(tester, 3, states), c.dangerTextHover);
        // Neutral: the fill, washed with the label at 8 percent.
        expect(_bg(tester, 4), c.fill);
        expect(_fg(tester, 4), c.textPrimary);
        expect(
          _bg(tester, 4, states),
          Color.alphaBlend(c.textPrimary.withValues(alpha: .08), c.fill),
        );
        // Tertiary: gray text, then accent, then critical.
        expect(_bg(tester, 5), Colors.transparent);
        expect(_fg(tester, 5), c.textSecondary);
        expect(_fg(tester, 5, states), c.textPrimary);
        expect(
          _bg(tester, 5, states),
          Color.alphaBlend(
            c.textPrimary.withValues(alpha: .08),
            Colors.transparent,
          ),
        );
        expect(_fg(tester, 6), c.accent);
        expect(_fg(tester, 6, states), c.accentHover);
        expect(_fg(tester, 7), c.dangerText);
        expect(_fg(tester, 7, states), c.dangerTextHover);
        // White: the card surface with a 1 px control ring.
        expect(_bg(tester, 8), c.surfaceCard);
        expect(_bg(tester, 8, states), c.surfaceHover);
        expect(_style(tester, 8).side!.resolve({})!.color, c.borderControl);
        // Every pair is a button of at least 44.
        for (var i = 0; i < 9; i++) {
          expect(
            tester.getSize(find.byType(TextButton).at(i)).height,
            greaterThanOrEqualTo(44),
          );
        }
      },
    );

    test('neutral and white take no tone', () {
      expect(
        () => PantasButton(
          label: 'x',
          kind: PantasButtonKind.neutral,
          tone: PantasButtonTone.accent,
        ),
        throwsAssertionError,
      );
      expect(
        () => PantasButton(
          label: 'x',
          kind: PantasButtonKind.white,
          tone: PantasButtonTone.critical,
        ),
        throwsAssertionError,
      );
      expect(pantasButtonPairAllowed(PantasButtonKind.neutral, null), isTrue);
      expect(
        pantasButtonPairAllowed(
          PantasButtonKind.neutral,
          PantasButtonTone.critical,
        ),
        isFalse,
      );
      expect(
        pantasButtonPairAllowed(
          PantasButtonKind.tertiary,
          PantasButtonTone.critical,
        ),
        isTrue,
      );
    });

    dsMatrix(
      'the older variants keep working as a kind by tone pair',
      (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final v in PantasButtonVariant.values)
            PantasButton(
              label: v.name,
              variant: v,
              fullWidth: false,
              onPressed: () {},
            ),
        ],
      ),
      check: (tester, cell) async {
        final c = _colors(cell);
        expect(_bg(tester, 0), c.accentFill); // primary
        expect(_bg(tester, 1), c.accentTint); // secondary
        expect(_fg(tester, 2), cell.width >= 1024 ? c.textSecondary : c.accent);
        expect(_bg(tester, 3), c.dangerFill); // destructive
        expect(_bg(tester, 4), cell.width >= 1024 ? c.surfaceCard : c.fill);
      },
    );
  });

  group('size classes', () {
    final cases = <(PantasButtonSize, PantasButtonKind, double, bool, double)>[
      // size, kind, height, pill, radius when not a pill
      (PantasButtonSize.xs, PantasButtonKind.primary, 36, false, 8),
      (PantasButtonSize.standard, PantasButtonKind.primary, 44, false, 12),
      (PantasButtonSize.sm, PantasButtonKind.primary, 42, false, 12),
      (PantasButtonSize.lg, PantasButtonKind.primary, 50, false, 14),
      (PantasButtonSize.bar, PantasButtonKind.primary, 46, true, 0),
      (PantasButtonSize.bar, PantasButtonKind.secondary, 46, true, 0),
      (PantasButtonSize.bar, PantasButtonKind.tertiary, 46, false, 14),
      (PantasButtonSize.dialog, PantasButtonKind.neutral, 46, true, 0),
      (PantasButtonSize.dialog, PantasButtonKind.tertiary, 46, false, 14),
      (PantasButtonSize.notice, PantasButtonKind.primary, 44, false, 12),
      (PantasButtonSize.pillSm, PantasButtonKind.secondary, 44, true, 0),
      (PantasButtonSize.pillSm, PantasButtonKind.tertiary, 44, false, 12),
      (PantasButtonSize.phone, PantasButtonKind.primary, 52, false, 14),
    ];
    for (final (size, kind, height, pill, radius) in cases) {
      test('$size $kind: height $height, ${pill ? 'pill' : 'radius $radius'}',
          () {
        final m = pantasButtonMetrics(size, kind);
        expect(m.height, height);
        expect(m.pill, pill);
        if (!pill) expect(m.radius, radius);
        expect(m.shape() is StadiumBorder, pill);
      });
    }

    test('the radius follows the height', () {
      expect(pantasButtonRadiusForHeight(36), 8);
      expect(pantasButtonRadiusForHeight(40), 12);
      expect(pantasButtonRadiusForHeight(44), 12);
      expect(pantasButtonRadiusForHeight(46), 14);
      expect(pantasButtonRadiusForHeight(52), 14);
      final taller = pantasButtonMetrics(
        PantasButtonSize.standard,
        PantasButtonKind.primary,
        heightOverride: 48,
      );
      expect(taller.radius, 14);
    });

    test('a bar button beside a key hint pads 22 and 14', () {
      final plain =
          pantasButtonMetrics(PantasButtonSize.bar, PantasButtonKind.primary);
      final hinted = pantasButtonMetrics(
        PantasButtonSize.bar,
        PantasButtonKind.primary,
        keyHint: true,
      );
      expect((plain.padLeft, plain.padRight), (22, 22));
      expect((hinted.padLeft, hinted.padRight), (22, 14));
    });

    dsMatrix(
      'a wide button draws its size class and wraps at large text',
      (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in PantasButtonSize.values)
            SizedBox(
              width: 260,
              child: WebButton(
                // The test font is wide, so the one-line label is short.
                label: 'Save',
                size: s,
                expand: true,
                onPressed: () {},
              ),
            ),
        ],
      ),
      check: (tester, cell) async {
        final minimums = [36, 44, 42, 50, 46, 46, 44, 44, 52];
        for (var i = 0; i < PantasButtonSize.values.length; i++) {
          final h = tester.getSize(find.byType(TextButton).at(i)).height;
          // The height is a minimum: it grows when the label wraps.
          expect(h, greaterThanOrEqualTo(minimums[i]));
          if (cell.scale == 1) expect(h, minimums[i]);
        }
      },
    );
  });

  group('states', () {
    Future<void> mount(WidgetTester tester, Widget child, {DsCell? cell}) =>
        pumpDs(
          tester,
          cell ?? dsCells[4],
          Padding(padding: const EdgeInsets.all(24), child: child),
        );

    testWidgets('pressed scales to 0.97 down over 120 ms and back over 180 ms',
        (tester) async {
      await mount(tester, WebButton(label: 'Save', onPressed: () {}));
      double scale() => tester
          .widget<Transform>(
            find
                .descendant(
                  of: find.byType(PressScale),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform
          .entry(0, 0);
      expect(scale(), 1);
      final press =
          await tester.startGesture(tester.getCenter(find.text('Save')));
      await tester.pump();
      await tester.pump(PantasDurations.short1 * 2);
      expect(scale(), closeTo(.97, .001));
      await press.up();
      await tester.pump();
      await tester.pump(PantasDurations.short3 * 2);
      expect(scale(), 1);
    });

    testWidgets('a phone button scales the same and holds still when reduced',
        (tester) async {
      await mount(
        tester,
        PantasButton(label: 'Save', fullWidth: false, onPressed: () {}),
        cell: dsCells[0],
      );
      final key = find.byKey(const ValueKey('pantas-button-scale'));
      final press =
          await tester.startGesture(tester.getCenter(find.text('Save')));
      await tester.pump(PantasDurations.short1 * 2);
      final down = tester.widget<AnimatedScale>(key);
      expect(down.scale, .97);
      expect(down.duration, PantasDurations.short1);
      await press.up();
      await tester.pump();
      expect(
        tester.widget<AnimatedScale>(key).duration,
        PantasDurations.short3,
      );
      await tester.pumpAndSettle();

      await mount(
        tester,
        MediaQuery(
          data: MediaQueryData.fromView(tester.view)
              .copyWith(disableAnimations: true),
          child:
              PantasButton(label: 'Save', fullWidth: false, onPressed: () {}),
        ),
        cell: dsCells[0],
      );
      final still =
          await tester.startGesture(tester.getCenter(find.text('Save')));
      await tester.pump();
      expect(tester.widget<AnimatedScale>(key).scale, 1);
      await still.up();
    });

    testWidgets('disabled is the fill with the disabled label, no press',
        (tester) async {
      await mount(
        tester,
        const Column(
          children: [
            WebButton(label: 'Save'),
            WebButton(label: 'Back', variant: WebButtonVariant.tertiary),
          ],
        ),
      );
      const c = PantasColors.light;
      expect(_bg(tester, 0), c.fill);
      expect(_fg(tester, 0), c.textDisabled);
      // Hover changes nothing on a disabled button.
      expect(_bg(tester, 0, {WidgetState.hovered}), c.fill);
      // Tertiary keeps a transparent ground.
      expect(_bg(tester, 1), Colors.transparent);
      expect(_fg(tester, 1), c.textDisabled);
      expect(
        tester.widget<TextButton>(find.byType(TextButton).first).onPressed,
        isNull,
      );
    });

    testWidgets('busy shows the spinner, ignores taps and holds its width',
        (tester) async {
      var calls = 0;
      final busy = ValueNotifier<bool>(false);
      await mount(
        tester,
        ValueListenableBuilder<bool>(
          valueListenable: busy,
          builder: (context, isBusy, _) => WebButton(
            label: isBusy ? 'Saving' : 'Save Changes',
            busy: isBusy,
            onPressed: () => calls++,
          ),
        ),
      );
      final rest = tester.getSize(find.byType(TextButton)).width;
      expect(find.byType(PantasSpinner), findsNothing);
      busy.value = true;
      await tester.pump();
      expect(find.byType(PantasSpinner), findsOneWidget);
      // The busy button keeps its primary look and never shrinks.
      expect(_bg(tester, 0), PantasColors.light.accentFill);
      expect(
        tester.getSize(find.byType(TextButton)).width,
        greaterThanOrEqualTo(rest),
      );
      await tester.tap(find.byType(TextButton));
      expect(calls, 0);
      busy.value = false;
      await tester.pump();
      expect(find.byType(PantasSpinner), findsNothing);
    });

    testWidgets('the spinner turns once in 900 ms and stops when reduced',
        (tester) async {
      await mount(
        tester,
        WebButton(label: 'Saving', busy: true, onPressed: () {}),
      );
      RotationTransition turn() => tester.widget<RotationTransition>(
            find.descendant(
              of: find.byType(PantasSpinner),
              matching: find.byType(RotationTransition),
            ),
          );
      final a = turn().turns.value;
      await tester.pump(const Duration(milliseconds: 300));
      expect(turn().turns.value, closeTo((a + 1 / 3) % 1, .02));
      await mount(
        tester,
        MediaQuery(
          data: MediaQueryData.fromView(tester.view)
              .copyWith(disableAnimations: true),
          child: WebButton(label: 'Saving', busy: true, onPressed: () {}),
        ),
      );
      final b = turn().turns.value;
      await tester.pump(const Duration(milliseconds: 300));
      expect(turn().turns.value, b);
    });

    testWidgets('keyboard focus shows a 2 px accent ring, 2 px outside',
        (tester) async {
      var calls = 0;
      resetWebKeyboardFocus();
      await mount(tester, WebButton(label: 'Save', onPressed: () => calls++));
      expect(find.byKey(const ValueKey('focus-ring')), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final ring = find.byKey(const ValueKey('focus-ring'));
      expect(ring, findsOneWidget);
      final box = tester.widget<DecoratedBox>(ring).decoration as BoxDecoration;
      expect(box.border!.top.width, 2);
      expect(box.border!.top.color, PantasColors.light.accent);
      expect(
        tester.getRect(ring),
        tester.getRect(find.byType(TextButton)).inflate(4),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(calls, 1);
    });

    testWidgets('a filled bar button rings as a pill, a tertiary one does not',
        (tester) async {
      await mount(
        tester,
        Column(
          children: [
            WebButton(
              label: 'Next',
              size: PantasButtonSize.bar,
              onPressed: () {},
            ),
            WebButton(
              label: 'Skip',
              size: PantasButtonSize.bar,
              variant: WebButtonVariant.tertiary,
              onPressed: () {},
            ),
          ],
        ),
      );
      final shapes = tester
          .widgetList<TextButton>(find.byType(TextButton))
          .map((b) => b.style!.shape!.resolve({}))
          .toList();
      expect(shapes[0], isA<StadiumBorder>());
      expect(shapes[1], isA<RoundedRectangleBorder>());
      expect(
        (shapes[1]! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(14),
      );
    });

    testWidgets('hover shows the wash on a wide layout only', (tester) async {
      await mount(
        tester,
        PantasButton(
          label: 'Cancel',
          kind: PantasButtonKind.tertiary,
          fullWidth: false,
          onPressed: () {},
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byType(TextButton)));
      await tester.pumpAndSettle();
      expect(
        _bg(tester, 0, {WidgetState.hovered}),
        Color.alphaBlend(
          PantasColors.light.textPrimary.withValues(alpha: .08),
          Colors.transparent,
        ),
      );
    });

    testWidgets('a key hint on a primary button sits on the on-fill chip',
        (tester) async {
      await mount(
        tester,
        WebButton(label: 'Check', keyHint: 'Enter', onPressed: () {}),
      );
      const c = PantasColors.light;
      final chip = tester.widget<Container>(
        find
            .ancestor(of: find.text('Enter'), matching: find.byType(Container))
            .first,
      );
      expect((chip.decoration! as BoxDecoration).color, c.kbdOnFill);
      expect(tester.widget<Text>(find.text('Enter')).style!.color, c.onAccent);
    });
  });

  group('pairs', () {
    dsMatrix(
      'a pair puts the secondary first, equal halves, and stacks at 2.0',
      (context) => SizedBox(
        width: 340,
        child: ButtonPair(
          secondary: PantasButton(
            label: 'Cancel',
            kind: PantasButtonKind.neutral,
            onPressed: () {},
          ),
          primary: PantasButton(
            label: 'Delete Account',
            kind: PantasButtonKind.primary,
            tone: PantasButtonTone.critical,
            onPressed: () {},
          ),
        ),
      ),
      check: (tester, cell) async {
        final a = tester.getRect(find.text('Cancel'));
        final b = tester.getRect(find.text('Delete Account'));
        if (cell.scale > 1) {
          expect(b.top, lessThan(a.top));
        } else {
          expect(a.left, lessThan(b.left));
        }
      },
    );
  });
}
