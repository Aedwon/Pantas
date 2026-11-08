import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button_parts.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_keyboard_hints.dart';

import '../../../helpers/ds_matrix.dart';

PantasColors _colors(DsCell cell) =>
    cell.dark ? PantasColors.dark : PantasColors.light;

final _chevron = PantasIcons.bold(PantasIcons.back);
const _arrowRight = IconData(0xe06c, fontFamily: 'Phosphor');

Color _fg(
  WidgetTester tester,
  Finder button, [
  Set<WidgetState> s = const {},
]) =>
    tester.widget<TextButton>(button).style!.foregroundColor!.resolve(s)!;

void main() {
  group('TextLink', () {
    dsMatrix(
      'is accent text with a 16 px Bold arrow, 6 px apart, no box',
      (context) => WebTextLink(label: 'See All Questions', onPressed: () {}),
      check: (tester, cell) async {
        final c = _colors(cell);
        final button = find.byType(TextButton);
        expect(_fg(tester, button), c.accent);
        expect(_fg(tester, button, {WidgetState.hovered}), isNotNull);
        final text = tester.widget<Text>(find.text('See All Questions'));
        expect(text.style, isNull);
        final arrow = find.byIcon(PantasIcons.bold(_arrowRight));
        expect(tester.widget<Icon>(arrow).size, 16);
        expect(tester.widget<Icon>(arrow).color, c.accent);
        expect(tester.widget<Icon>(arrow).icon!.fontFamily, 'PhosphorBold');
        final gap = tester.getTopLeft(arrow).dx -
            tester.getTopRight(find.text('See All Questions')).dx;
        expect(gap, 6);
        // Never a box: the button paints no fill and no ring.
        final style = tester.widget<TextButton>(button).style!;
        expect(style.backgroundColor?.resolve({}), isNull);
        expect(style.side!.resolve({})!.width, 0);
        // The focus and press shape is a 5 px rounded rectangle.
        expect(
          (style.shape!.resolve({})! as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(5),
        );
        // A touched layout reaches a 44 px target.
        if (cell.width < 1024) {
          expect(
            tester.getSize(find.byType(WebTextLink)).height,
            greaterThanOrEqualTo(44),
          );
        }
      },
    );

    testWidgets('hover turns it accent-hover; the label is a link style',
        (tester) async {
      await pumpDs(
        tester,
        dsCells[4],
        WebTextLink(label: 'View Plan', onPressed: () {}),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byType(WebTextLink)));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Icon>(find.byType(Icon)).color,
        PantasColors.light.accentHover,
      );
      final style = DefaultTextStyle.of(
        tester.element(find.text('View Plan')),
      ).style;
      expect(style.fontSize, 15);
      expect(style.fontWeight, FontWeight.w600);
    });

    testWidgets('keyboard focus rings the link with radius-xs', (tester) async {
      resetWebKeyboardFocus();
      var calls = 0;
      await pumpDs(
        tester,
        dsCells[4],
        WebTextLink(label: 'View Plan', onPressed: () => calls++),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final ring = find.byKey(const ValueKey('focus-ring'));
      expect(ring, findsOneWidget);
      expect(
        (tester.widget<DecoratedBox>(ring).decoration as BoxDecoration)
            .borderRadius,
        BorderRadius.circular(5 + 4),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(calls, 1);
    });

    testWidgets('an arrowless link is just the label', (tester) async {
      await pumpDs(
        tester,
        dsCells[4],
        WebTextLink(label: 'View Plan', arrow: false, onPressed: () {}),
      );
      expect(find.byType(Icon), findsNothing);
    });
  });

  group('BackLink', () {
    dsMatrix(
      'is a Bold chevron and a 17 px accent label, 40 px tall',
      (context) => Padding(
        padding: const EdgeInsets.only(left: 24),
        child: WebBackLink(label: 'Study', onPressed: () {}),
      ),
      check: (tester, cell) async {
        final c = _colors(cell);
        final button = find.byType(TextButton);
        final icon = tester.widget<Icon>(find.byIcon(_chevron));
        expect(icon.size, 20);
        expect(icon.icon!.fontFamily, 'PhosphorBold');
        expect(_fg(tester, button), c.accent);
        expect(_fg(tester, button, {WidgetState.hovered}), c.accentHover);
        expect(
          DefaultTextStyle.of(tester.element(find.text('Study')))
              .style
              .fontSize,
          17,
        );
        expect(
          DefaultTextStyle.of(tester.element(find.text('Study')))
              .style
              .fontWeight,
          FontWeight.w400,
        );
        // 2 px between the chevron and the label.
        expect(
          tester.getTopLeft(find.text('Study')).dx -
              tester.getTopRight(find.byIcon(_chevron)).dx,
          2,
        );
        // The height is a minimum: it grows at large text.
        expect(
          tester.getSize(button).height,
          cell.scale == 1 ? 40 : greaterThanOrEqualTo(40),
        );
        // A touched layout reaches a 44 px target; the drawn link stays 40.
        if (cell.width < 1024) {
          expect(
            tester.getSize(find.byType(WebBackLink)).height,
            greaterThanOrEqualTo(44),
          );
        }
      },
    );

    testWidgets('hover washes the accent at 8 percent and nudges 2 px left',
        (tester) async {
      await pumpDs(
        tester,
        dsCells[4],
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: WebBackLink(label: 'Study', onPressed: () {}),
        ),
      );
      final before = tester.getTopLeft(find.byIcon(_chevron)).dx;
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Study')));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byIcon(_chevron)).dx, before - 2);
      final wash = find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is ShapeDecoration &&
            (w.decoration as ShapeDecoration).color ==
                PantasColors.light.accent.withValues(alpha: .08),
      );
      expect(wash, findsOneWidget);
      expect(
        ((tester.widget<DecoratedBox>(wash).decoration as ShapeDecoration).shape
                as RoundedRectangleBorder)
            .borderRadius,
        BorderRadius.circular(11),
      );
    });

    testWidgets('reduced motion keeps the chevron still', (tester) async {
      await pumpDs(
        tester,
        dsCells[4],
        MediaQuery(
          data: MediaQueryData.fromView(tester.view)
              .copyWith(disableAnimations: true),
          child: Padding(
            padding: const EdgeInsets.only(left: 40),
            child: WebBackLink(label: 'Study', onPressed: () {}),
          ),
        ),
      );
      final before = tester.getTopLeft(find.byIcon(_chevron)).dx;
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Study')));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byIcon(_chevron)).dx, before);
    });

    testWidgets('keyboard focus draws a ring of radius-back, 2 px outside',
        (tester) async {
      resetWebKeyboardFocus();
      await pumpDs(
        tester,
        dsCells[4],
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: WebBackLink(label: 'Study', onPressed: () {}),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final ring = find.byKey(const ValueKey('back-link-ring'));
      expect(ring, findsOneWidget);
      expect(
        tester.getRect(ring),
        tester.getRect(find.byType(TextButton)).inflate(4),
      );
      final shape =
          (tester.widget<DecoratedBox>(ring).decoration as ShapeDecoration)
              .shape as RoundedRectangleBorder;
      expect(shape.side.width, 2);
      expect(shape.side.color, PantasColors.light.accent);
      expect(shape.borderRadius, BorderRadius.circular(11 + 4));
    });

    testWidgets('a link with no nudge rings itself with the shared ring',
        (tester) async {
      resetWebKeyboardFocus();
      await pumpDs(
        tester,
        dsCells[4],
        WebBackLink(label: 'Study', nudge: false, onPressed: () {}),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('focus-ring')), findsOneWidget);
    });
  });

  group('KeyHint', () {
    dsMatrix(
      'standalone, on a primary button and in a disabled button',
      (context) => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WebKeyHint('Ctrl K'),
          WebKeyHint('Enter', onButton: true),
          WebKeyHint('Enter', onButton: true, enabled: false),
        ],
      ),
      check: (tester, cell) async {
        final c = _colors(cell);
        final chips = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(WebKeyHint),
                matching: find.byType(Container),
              ),
            )
            .toList();
        TextStyle style(int i) => tester
            .widget<Text>(
              find.descendant(
                of: find.byType(WebKeyHint).at(i),
                matching: find.byType(Text),
              ),
            )
            .style!;
        // Standalone: 11/600 text-secondary, 1 px divider-strong ring.
        expect(style(0).fontSize, 11);
        expect(style(0).fontWeight, FontWeight.w600);
        expect(style(0).color, c.textSecondary);
        final standalone = chips[0].decoration! as BoxDecoration;
        expect(standalone.color, isNull);
        expect(standalone.border!.top.color, c.dividerStrong);
        expect(standalone.border!.top.width, 1);
        expect(standalone.borderRadius, BorderRadius.circular(5));
        expect(
          chips[0].padding,
          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        );
        // On a primary button: 12/600 on-accent on kbd-on-fill, no ring.
        expect(style(1).fontSize, 12);
        expect(style(1).color, c.onAccent);
        final filled = chips[1].decoration! as BoxDecoration;
        expect(filled.color, c.kbdOnFill);
        expect(filled.border, isNull);
        expect(filled.borderRadius, BorderRadius.circular(5));
        expect(
          chips[1].padding,
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        );
        // In a disabled button: transparent, the ring, text-disabled.
        expect(style(2).color, c.textDisabled);
        final off = chips[2].decoration! as BoxDecoration;
        expect(off.color, isNull);
        expect(off.border!.top.color, c.dividerStrong);
      },
    );

    testWidgets('it is not a control and takes no focus', (tester) async {
      await pumpDs(tester, dsCells[4], const WebKeyHint('Esc'));
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(ExcludeSemantics), findsWidgets);
    });

    testWidgets('it stays hidden until a hardware key is pressed',
        (tester) async {
      await pumpDs(
        tester,
        dsCells[4],
        const WebKeyboardHints(
          finePointer: false,
          child: Column(
            children: [WebKeyHint('Esc'), Text('after')],
          ),
        ),
      );
      expect(find.text('Esc'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();
      expect(find.text('Esc'), findsOneWidget);
    });
  });

  group('Spinner', () {
    testWidgets('the page spinner is 20 px and the inline one is 18 px',
        (tester) async {
      await pumpDs(
        tester,
        dsCells[4],
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PantasSpinner(),
            SizedBox(width: 8),
            PantasSpinner.inline(color: Color(0xFFFFFFFF)),
          ],
        ),
      );
      expect(
        tester.getSize(find.byType(PantasSpinner).first),
        const Size(20, 20),
      );
      expect(
        tester.getSize(find.byType(PantasSpinner).last),
        const Size(18, 18),
      );
    });
  });

  group('TextAction', () {
    dsMatrix(
      'is a tertiary accent button, 42 px, a rounded rectangle',
      (context) => WebTextAction(label: 'Edit', onPressed: () {}),
      check: (tester, cell) async {
        final c = _colors(cell);
        final button = find.byType(TextButton);
        expect(_fg(tester, button), c.accent);
        expect(_fg(tester, button, {WidgetState.hovered}), c.accentHover);
        final style = tester.widget<TextButton>(button).style!;
        expect(style.backgroundColor!.resolve({}), Colors.transparent);
        expect(
          (style.shape!.resolve({})! as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(12),
        );
        expect(
          tester.getSize(button).height,
          cell.scale == 1 ? 42 : greaterThanOrEqualTo(42),
        );
      },
    );
  });
}
