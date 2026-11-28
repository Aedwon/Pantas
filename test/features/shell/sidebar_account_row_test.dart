import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../../goldens/golden_harness.dart';

/// The account row at the foot of the wide sidebar (board "Sidebar Account
/// Card", variant B): one button that opens Settings, Account.
const _row = ValueKey('sidebar-account');

Future<void> _pump(
  WidgetTester tester, {
  String plan = 'Free',
  String person = 'Aedwon',
  VoidCallback? onAccount,
  bool dark = false,
  double width = 244,
}) async {
  resetWebKeyboardFocus();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1440, 900);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            height: 700,
            child: WebSidebar(
              activeIndex: 0,
              person: person,
              plan: plan,
              onAccount: onAccount ?? () {},
              onNavigate: (_) {},
              onSearch: () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

PantasColors _colors(WidgetTester tester) =>
    Theme.of(tester.element(find.byKey(_row))).extension<PantasColors>()!;

/// The fill the button paints: the Material under the row.
Color? _fill(WidgetTester tester) => tester
    .widget<Material>(
      find
          .descendant(of: find.byKey(_row), matching: find.byType(Material))
          .first,
    )
    .color;

List<BoxShadow>? _shadow(WidgetTester tester) =>
    (tester.widget<DecoratedBox>(find.byKey(_row)).decoration as BoxDecoration)
        .boxShadow;

Future<TestGesture> _hover(WidgetTester tester) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(find.text('Aedwon')));
  await tester.pumpAndSettle();
  return mouse;
}

/// Tab until the row holds focus, as a keyboard user reaches it.
Future<void> _tabToRow(WidgetTester tester) async {
  final focus = Focus.of(tester.element(find.text('Aedwon')));
  for (var i = 0; i < 12 && !focus.hasPrimaryFocus; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
  }
  expect(focus.hasPrimaryFocus, isTrue, reason: 'Tab reaches the row');
  await tester.pumpAndSettle();
}

void main() {
  group('button', () {
    for (final plan in ['Free', 'Pro']) {
      testWidgets('$plan: one button labeled with name and plan',
          (tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, plan: plan);
        final finder = find.bySemanticsLabel('Account, Aedwon, $plan account');
        expect(finder, findsOneWidget);
        expect(tester.getSemantics(finder).flagsCollection.isButton, isTrue);
        handle.dispose();
      });
    }

    testWidgets('click, Enter and Space each open Account once',
        (tester) async {
      var opened = 0;
      await _pump(tester, onAccount: () => opened++);
      await tester.tap(find.text('Aedwon'));
      await tester.pump();
      expect(opened, 1);

      await _tabToRow(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(opened, 2);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(opened, 3);
    });

    testWidgets('the pointer is a hand over the row', (tester) async {
      await _pump(tester);
      final regions = find.descendant(
        of: find.byKey(_row),
        matching: find.byType(MouseRegion),
      );
      expect(
        tester
            .widgetList<MouseRegion>(regions)
            .any((r) => r.cursor == SystemMouseCursors.click),
        isTrue,
      );
    });
  });

  group('plan line and card', () {
    testWidgets('Free: "Free account", no card, no shadow', (tester) async {
      await _pump(tester);
      final c = _colors(tester);
      expect(find.text('Free account'), findsOneWidget);
      expect(_shadow(tester), anyOf(isNull, isEmpty));
      // Plain on the sidebar: the fill is clear.
      expect(_fill(tester)?.a ?? 0, 0);
      expect(_fill(tester), isNot(c.surfaceCard));
    });

    for (final dark in [false, true]) {
      testWidgets(
          'Pro (${dark ? 'dark' : 'light'}): "Pro account" on '
          'surfaceCard with the selected item shadow', (tester) async {
        await _pump(tester, plan: 'Pro', dark: dark);
        expect(find.text('Pro account'), findsOneWidget);
        expect(_fill(tester), _colors(tester).surfaceCard);
        expect(
          _shadow(tester),
          (dark ? PantasShadow.dark : PantasShadow.light).navActive,
        );
      });
    }

    testWidgets('unknown plan: name only, no card, still a button',
        (tester) async {
      var opened = 0;
      final handle = tester.ensureSemantics();
      await _pump(tester, plan: '', onAccount: () => opened++);
      expect(find.text('Aedwon'), findsOneWidget);
      expect(find.textContaining('account'), findsNothing);
      expect(find.textContaining('Free'), findsNothing);
      expect(find.textContaining('Pro'), findsNothing);
      expect(_shadow(tester), anyOf(isNull, isEmpty));
      expect(_fill(tester)?.a ?? 0, 0);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Account, Aedwon'))
            .flagsCollection
            .isButton,
        isTrue,
      );
      await tester.tap(find.text('Aedwon'));
      expect(opened, 1);
      handle.dispose();
    });

    testWidgets('the exam is not in the row', (tester) async {
      await _pump(tester, plan: 'Pro');
      expect(find.textContaining('CSE'), findsNothing);
      expect(find.textContaining('PUP'), findsNothing);
      expect(find.textContaining(', Pro'), findsNothing);
      expect(find.textContaining('·'), findsNothing);
    });
  });

  group('hover', () {
    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      testWidgets('Pro ($mode): the card turns to surfaceHover',
          (tester) async {
        await _pump(tester, plan: 'Pro', dark: dark);
        await _hover(tester);
        expect(_fill(tester), _colors(tester).surfaceHover);
      });

      testWidgets('Free ($mode): textPrimary at the hover opacity',
          (tester) async {
        await _pump(tester, dark: dark);
        await _hover(tester);
        expect(
          _fill(tester),
          _colors(tester).textPrimary.withValues(alpha: PantasOpacity.hover),
        );
      });

      testWidgets('Free ($mode): the fill starts from clear text color',
          (tester) async {
        await _pump(tester, dark: dark);
        final rest = _fill(tester)!;
        final text = _colors(tester).textPrimary;
        // Same hue as the hover fill, zero alpha: no gray flash on the fade.
        expect(rest.a, 0);
        expect(rest.r, text.r);
        expect(rest.g, text.g);
        expect(rest.b, text.b);
        expect(rest, isNot(Colors.transparent));
      });
    }
  });

  group('focus', () {
    for (final plan in ['Free', 'Pro']) {
      testWidgets('$plan: keyboard focus shows the standard ring',
          (tester) async {
        await _pump(tester, plan: plan);
        final ring = find.descendant(
          of: find.ancestor(
            of: find.byKey(_row),
            matching: find.byType(OffsetFocusRing),
          ),
          matching: find.byKey(const ValueKey('focus-ring')),
        );
        expect(ring, findsNothing);
        await _tabToRow(tester);
        expect(ring, findsOneWidget);
      });
    }
  });

  group('narrow sidebar (220)', () {
    testWidgets('a long name ends in dots and the plan line stays whole',
        (tester) async {
      // The test font is far wider than Geist; measure with the real one.
      await loadGoldenFonts();
      await _pump(
        tester,
        plan: 'Pro',
        person: 'Maria Cristina Santos de la Fuente y Alvarez',
        width: 220,
      );
      expect(tester.takeException(), isNull);
      final name = tester.renderObject<RenderParagraph>(
        find.textContaining('Maria Cristina'),
      );
      expect(name.didExceedMaxLines, isTrue);
      final line = tester.renderObject<RenderParagraph>(
        find.text('Pro account'),
      );
      expect(line.didExceedMaxLines, isFalse);
      final painter = TextPainter(
        text: line.text,
        textDirection: TextDirection.ltr,
      )..layout();
      expect(line.size.width, greaterThanOrEqualTo(painter.width));
      painter.dispose();
    });
  });
}
