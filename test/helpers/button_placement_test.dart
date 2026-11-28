import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

import 'button_placement.dart';

/// The wide placement check itself: it passes the shared dialog and a ghost
/// row, and names each way a pair can break the rule.
void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: Center(child: SizedBox(width: 600, child: child)),
        ),
      ),
    );
    await tester.pump();
  }

  Widget card(Widget actions) => DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [const Text('Paused quiz'), actions],
          ),
        ),
      );

  WebButton discard() => WebButton(
        label: 'Discard',
        variant: WebButtonVariant.tertiary,
        onPressed: () {},
      );
  WebButton resume() => WebButton(label: 'Resume', onPressed: () {});

  testWidgets('a right-aligned pair, secondary then main, passes',
      (tester) async {
    await pump(
      tester,
      card(
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [discard(), const SizedBox(width: 8), resume()],
        ),
      ),
    );
    expect(widePlacementProblems(tester), isEmpty);
  });

  testWidgets('the shared wide dialog passes', (tester) async {
    await pump(
      tester,
      CenteredDialog(
        title: 'Sign out?',
        message: 'Your progress is saved.',
        primaryLabel: 'Sign Out',
        secondaryLabel: 'Cancel',
        onConfirm: () {},
        onCancel: () {},
      ),
    );
    expect(widePlacementProblems(tester), isEmpty);
  });

  testWidgets('a ghost row with no main button may sit at the left',
      (tester) async {
    await pump(
      tester,
      card(
        Row(
          children: [
            WebButton(
              label: 'Sign Out',
              variant: WebButtonVariant.tertiary,
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            WebButton(
              label: 'Delete Account',
              variant: WebButtonVariant.tertiary,
              redText: true,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    expect(widePlacementProblems(tester), isEmpty);
  });

  testWidgets('main first is named', (tester) async {
    await pump(
      tester,
      card(
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [resume(), const SizedBox(width: 8), discard()],
        ),
      ),
    );
    expect(
      widePlacementProblems(tester),
      [contains('the main button "Resume" is not last')],
    );
  });

  testWidgets('a pair at the left of its card is named', (tester) async {
    await pump(
      tester,
      card(Row(children: [discard(), const SizedBox(width: 8), resume()])),
    );
    expect(
      widePlacementProblems(tester),
      [contains('belongs at the right end')],
    );
  });

  testWidgets('a wrong gap is named', (tester) async {
    await pump(
      tester,
      card(
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [discard(), const SizedBox(width: 12), resume()],
        ),
      ),
    );
    expect(widePlacementProblems(tester), [contains('12.0 px between')]);
  });

  testWidgets('equal halves are named', (tester) async {
    await pump(
      tester,
      card(ButtonPair(gap: 8, primary: resume(), secondary: discard())),
    );
    expect(
      widePlacementProblems(tester),
      [contains('"Discard" is stretched'), contains('"Resume" is stretched')],
    );
  });

  testWidgets('a lone button spanning its card is named', (tester) async {
    await pump(
      tester,
      card(WebButton(label: 'Resume', expand: true, onPressed: () {})),
    );
    expect(widePlacementProblems(tester), [contains('is full width')]);
  });

  testWidgets('a full-width button in a column with no painted box is named',
      (tester) async {
    // The mock setup column and the practice picker panel, before E-162.
    await pump(
      tester,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Strict mode'),
          WebButton(label: 'Start', expand: true, onPressed: () {}),
        ],
      ),
    );
    expect(
      widePlacementProblems(tester),
      [contains('"Start" is full width (600 px')],
    );
  });

  testWidgets('a button stretched to a fixed box is named', (tester) async {
    // Get Started in its 260 px box and Done in its 192 px box, before E-162.
    await pump(
      tester,
      Center(
        child: SizedBox(
          width: 260,
          child:
              WebButton(label: 'Get Started', expand: true, onPressed: () {}),
        ),
      ),
    );
    expect(
      widePlacementProblems(tester),
      [contains('"Get Started" is full width (260 px')],
    );
  });

  testWidgets('the board A drawer Start is kept full width', (tester) async {
    await pump(
      tester,
      card(
        WebButton(
          key: const ValueKey('drawer-foot-start'),
          label: 'Start',
          expand: true,
          onPressed: () {},
        ),
      ),
    );
    expect(widePlacementProblems(tester), isEmpty);
  });

  // Added Nov 25 (E-170): the wide "Use Google Instead" hover box hugged its
  // content because the raw TextButton had zero padding.
  Widget hoverText(double padding) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {},
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: padding),
              ),
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.hovered)
                    ? const Color(0xFFDDEEFF)
                    : Colors.transparent,
              ),
            ),
            child: const Text('Use Google Instead'),
          ),
        ],
      );

  testWidgets('a hover-painting text button with no inside padding is named',
      (tester) async {
    await pump(tester, hoverText(0));
    expect(
      widePlacementProblems(tester),
      [contains('"Use Google Instead" paints a hover box')],
    );
  });

  testWidgets('a hover-painting text button with 14 px inside passes',
      (tester) async {
    await pump(tester, hoverText(14));
    expect(widePlacementProblems(tester), isEmpty);
  });

  // Added Nov 25 (E-175): buttons stacked one above the other share width
  // and height.
  testWidgets('a stacked pair of different size is named', (tester) async {
    await pump(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WebButton(label: 'Continue', onPressed: () {}),
          const SizedBox(height: 8),
          WebButton(
            label: 'Use Google Instead',
            kind: PantasButtonKind.tertiary,
            size: PantasButtonSize.sm,
            onPressed: () {},
          ),
        ],
      ),
    );
    expect(
      widePlacementProblems(tester),
      [contains('"Continue"'), contains('"Use Google Instead"')],
    );
  });

  testWidgets('a stacked pair of one width and height passes', (tester) async {
    await pump(
      tester,
      SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WebButton(label: 'Continue', expand: true, onPressed: () {}),
            const SizedBox(height: 8),
            WebButton(
              label: 'Use Google Instead',
              expand: true,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    final problems = widePlacementProblems(tester);
    expect(problems.where((p) => p.contains('stacked above')), isEmpty);
  });
}
