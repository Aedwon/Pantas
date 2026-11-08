import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/score_breakdown_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// Fifth sweep: the pieces the quiz and the assessment now share.
void main() {
  tearDown(() => debugWebPlatformOverride = null);

  void wide(WidgetTester tester) {
    debugWebPlatformOverride = true;
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    bool dark = false,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(body: child),
        ),
      );

  group('5R-1: WebCenteredTopBar', () {
    for (final trailing in [true, false]) {
      testWidgets('centers the title on the page, trailing=$trailing',
          (tester) async {
        wide(tester);
        await mount(
          tester,
          Column(
            children: [
              WebCenteredTopBar(
                leading: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(Icons.close), WebKeyHint('Esc')],
                ),
                title: 'Assessment · CSE Pro',
                trailing: trailing
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Saved on this device.'),
                          Icon(Icons.flag),
                        ],
                      )
                    : null,
              ),
            ],
          ),
        );
        final title = tester.getRect(find.text('Assessment · CSE Pro'));
        expect(title.center.dx, closeTo(720, .5));
      });
    }

    testWidgets('top bar buttons sit 44 px wide at the bar edges',
        (tester) async {
      wide(tester);
      await mount(
        tester,
        Column(
          children: [
            WebCenteredTopBar(
              leading: WebTopBarButton(
                tooltip: 'Leave',
                icon: const Icon(Icons.close),
                onPressed: () {},
              ),
              title: 'Title',
              trailing: WebTopBarButton(
                tooltip: 'Report',
                icon: const Icon(Icons.flag),
                onPressed: () {},
              ),
            ),
          ],
        ),
      );
      expect(tester.getCenter(find.byTooltip('Leave')).dx, 42);
      expect(tester.getCenter(find.byTooltip('Report')).dx, 1440 - 42);
    });
  });

  group('5R-4: releaseChoiceFocus', () {
    testWidgets('lets go of a focused choice and keeps another control',
        (tester) async {
      wide(tester);
      late State owner;
      final other = FocusNode();
      addTearDown(other.dispose);
      await mount(
        tester,
        _Owner(
          onState: (s) => owner = s,
          child: Column(
            children: [
              WebAnswerOption(
                letter: 'A',
                onPressed: () {},
                child: const Text('Choice A'),
              ),
              TextButton(
                focusNode: other,
                onPressed: () {},
                child: const Text('Report'),
              ),
            ],
          ),
        ),
      );
      bool onChoice() =>
          FocusManager.instance.primaryFocus?.context
              ?.findAncestorWidgetOfExactType<WebAnswerOption>() !=
          null;
      Focus.of(tester.element(find.text('Choice A'))).requestFocus();
      await tester.pump();
      expect(onChoice(), isTrue);
      releaseChoiceFocus(owner);
      await tester.pump();
      await tester.pump();
      expect(onChoice(), isFalse);

      other.requestFocus();
      await tester.pump();
      releaseChoiceFocus(owner);
      await tester.pump();
      await tester.pump();
      expect(FocusManager.instance.primaryFocus, other);
    });
  });

  group('5R-5: a floating WebCard', () {
    for (final dark in [false, true]) {
      testWidgets('has an edge and a shadow in both themes, dark=$dark',
          (tester) async {
        wide(tester);
        await mount(
          tester,
          const Center(
            child: WebCard(floating: true, child: Text('Questions')),
          ),
          dark: dark,
        );
        final box = tester
            .widget<Container>(
              find.descendant(
                of: find.byType(WebCard),
                matching: find.byType(Container),
              ),
            )
            .decoration! as BoxDecoration;
        expect(box.border, isNotNull);
        expect(box.boxShadow, isNotEmpty);
      });
    }

    testWidgets(
        'in light its edge is the system edge-bar (D-system card--floating)',
        (tester) async {
      wide(tester);
      await mount(
        tester,
        const Center(
          child: WebCard(floating: true, child: Text('Questions')),
        ),
      );
      final box = tester
          .widget<Container>(
            find.descendant(
              of: find.byType(WebCard),
              matching: find.byType(Container),
            ),
          )
          .decoration! as BoxDecoration;
      final edge = (box.border! as Border).top.color;
      // The system's floating card takes `edge-bar` (6 percent black in
      // light) and the `elev-bar` shadow, which carries the card on white.
      expect(edge, PantasColors.light.edgeBar);
      expect(box.boxShadow, isNotEmpty);
    });

    testWidgets('a plain card in light has neither', (tester) async {
      wide(tester);
      await mount(
        tester,
        const Center(child: WebCard(child: Text('Plain'))),
      );
      final box = tester
          .widget<Container>(
            find.descendant(
              of: find.byType(WebCard),
              matching: find.byType(Container),
            ),
          )
          .decoration! as BoxDecoration;
      expect(box.border, isNull);
      expect(box.boxShadow, isNull);
    });
  });

  group('5R-6: WebBackLink', () {
    testWidgets('leaves room after the label for the focus ring',
        (tester) async {
      wide(tester);
      await mount(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: WebBackLink(label: 'Session', onPressed: () {}),
        ),
      );
      final label = tester.getRect(find.text('Session'));
      final button = tester.getRect(find.byType(TextButton));
      expect(button.right - label.right, webBackLinkPadRight);
    });
  });

  group('5R-2: ScoreBreakdownRow', () {
    testWidgets('a long subject name wraps on a phone instead of truncating',
        (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const name = 'Language Proficiency (English & Filipino)';
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: ScoreBreakdownRow(
                name: name,
                correct: 12,
                total: 20,
                divider: false,
              ),
            ),
          ),
        ),
      );
      final text = tester.widget<Text>(find.text(name));
      expect(text.overflow, isNot(TextOverflow.ellipsis));
      expect(text.maxLines, isNull);
      final paragraph = tester.renderObject<RenderParagraph>(find.text(name));
      expect(paragraph.didExceedMaxLines, isFalse);
      // Two lines: taller than one line of the same text.
      expect(tester.getSize(find.text(name)).height, greaterThan(30));
      // The count and the percent still fit beside it.
      expect(find.text('12 / 20'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('a short name stays on one line', (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: const Scaffold(
            body: ScoreBreakdownRow(
              name: 'Algebra',
              correct: 3,
              total: 4,
              divider: false,
            ),
          ),
        ),
      );
      expect(tester.getSize(find.text('Algebra')).height, lessThan(30));
    });
  });
}

class _Owner extends StatefulWidget {
  const _Owner({required this.onState, required this.child});
  final ValueChanged<State> onState;
  final Widget child;
  @override
  State<_Owner> createState() => _OwnerState();
}

class _OwnerState extends State<_Owner> {
  @override
  void initState() {
    super.initState();
    widget.onState(this);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
