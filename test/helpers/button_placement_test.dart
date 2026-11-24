import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
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
    expect(widePlacementProblems(tester), [contains('spans its box')]);
  });
}
