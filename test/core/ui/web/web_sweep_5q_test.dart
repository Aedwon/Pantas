import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/settings/presentation/widgets/web_pro_hero.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

/// Fifth sweep of the web pages: hover, ring, chevron, Tab order, perks.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  setUp(() {
    debugWebPlatformOverride = true;
    resetWebKeyboardFocus();
  });
  tearDown(() => debugWebPlatformOverride = null);

  void size(WidgetTester tester, double width, [double height = 900]) {
    tester.view
      ..physicalSize = Size(width, height)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    bool dark = true,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(body: Center(child: child)),
        ),
      );

  Future<void> hover(WidgetTester tester, Finder finder) async {
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: const Offset(5, 5));
    await tester.pump();
    await mouse.moveTo(tester.getCenter(finder));
    await tester.pumpAndSettle();
  }

  group('5Q-6, 5Q-8: a text link answers the pointer in dark too', () {
    testWidgets('the dark link lightens on hover', (tester) async {
      size(tester, 1440);
      await mount(
        tester,
        WebTextLink(label: 'View full plan', onPressed: () {}, arrow: false),
      );
      Color color() => tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('View full plan'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style
          .color!;
      final before = color();
      await hover(tester, find.text('View full plan'));
      expect(color(), isNot(before));
      expect(color(), const WebTokens(Brightness.dark).tintText);
    });
  });

  testWidgets('5Q-7: a dark primary button is darker on hover', (tester) async {
    size(tester, 1440);
    await mount(tester, WebButton(label: 'Continue Lesson', onPressed: () {}));
    Color? fill() => tester
        .widget<Material>(
          find
              .descendant(
                of: find.byType(WebButton),
                matching: find.byType(Material),
              )
              .first,
        )
        .color;
    final before = fill();
    await hover(tester, find.text('Continue Lesson'));
    expect(fill(), isNot(before));
    expect(
      const WebTokens(Brightness.dark).accentHover,
      isNot(const WebTokens(Brightness.dark).colors.accentFill),
    );
  });

  testWidgets(
      '5Q-9: an unselected segment is tinted on hover, the selected '
      'one is not', (tester) async {
    size(tester, 1440);
    await mount(
      tester,
      SizedBox(
        width: 380,
        child: WebSegmentedControl(
          labels: const ['Subjects', 'Topics', 'Lessons'],
          selected: 0,
          onChanged: (_) {},
        ),
      ),
    );
    Color? overlay(String label) {
      final button = tester.widget<TextButton>(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(TextButton),
        ),
      );
      return button.style!.overlayColor!.resolve({WidgetState.hovered});
    }

    expect(overlay('Topics'), isNot(Colors.transparent));
    expect(overlay('Subjects'), Colors.transparent);
    await hover(tester, find.text('Topics'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('5Q-3: the Settings chevron is readable in dark', (tester) async {
    size(tester, 1440);
    await mount(
      tester,
      SizedBox(
        width: 700,
        child: ScopePicker(
          settingsRows: true,
          selectedIds: const {'l1'},
          subjects: const [
            ScopeSubject(
              title: 'Math',
              topics: [
                ScopeTopic(
                  id: 't',
                  title: 'Topic',
                  lessons: [ScopeLesson(id: 'l1', title: 'Lesson')],
                ),
              ],
            ),
          ],
          onChanged: (_) {},
        ),
      ),
    );
    final icon = tester.widget<Icon>(
      find.descendant(
        of: find.byKey(const ValueKey('scope-caret-base-t')),
        matching: find.byType(Icon),
      ),
    );
    const tokens = WebTokens(Brightness.dark);
    expect(icon.color, tokens.colors.tertiaryLabel);
    // Against the card, at least the 3:1 a control icon needs.
    final bg = tokens.colors.surface;
    double lum(Color c) => c.computeLuminance();
    final ratio = (lum(icon.color!) + .05) / (lum(bg) + .05);
    expect(ratio, greaterThan(3));
  });

  group('5Q-11: the back link ring is whole', () {
    testWidgets('keyboard focus draws a closed ring in the overlay',
        (tester) async {
      size(tester, 1440);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildDarkTheme(web: true),
          home: Scaffold(
            body: ClipRect(
              child: Padding(
                padding: const EdgeInsets.only(left: 100, top: 50),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: WebBackLink(label: 'Home', onPressed: () {}),
                ),
              ),
            ),
          ),
        ),
      );
      // Back link A (Nov 7): the ring is the ghost buttons' rounded
      // rectangle, no longer a pill.
      final stadium = find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is ShapeDecoration &&
            (w.decoration as ShapeDecoration).shape is RoundedRectangleBorder &&
            ((w.decoration as ShapeDecoration).shape as RoundedRectangleBorder)
                    .side
                    .width ==
                2,
      );
      expect(stadium, findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(stadium, findsOneWidget);
      // The ring covers the whole link, 14 px left of where the page clips.
      final link = tester.getRect(find.byType(TextButton));
      final ring = tester.getRect(stadium);
      expect(ring, link);
      expect(ring.left, lessThan(100));
      // A click takes it away.
      await tester.tapAt(const Offset(700, 400));
      await tester.pumpAndSettle();
      expect(stadium, findsNothing);
    });
  });

  group('5Q-12: Tab starts in the sidebar', () {
    testWidgets('the first Tab from the page goes to Search, then Home',
        (tester) async {
      size(tester, 1440);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildDarkTheme(web: true),
          home: WebShellFrame(
            web: true,
            activeIndex: 0,
            person: 'Aerol',
            exam: 'CSE Pro',
            plan: 'Pro',
            onNavigate: (_) {},
            onSearch: () {},
            child: Focus(
              autofocus: true,
              skipTraversal: true,
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Top control'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Other control'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      String? focused() {
        final primary = FocusManager.instance.primaryFocus;
        final element = primary?.context;
        if (element == null) return null;
        String? text;
        void visit(Element e) {
          if (text != null) return;
          final w = e.widget;
          if (w is Text && w.data != null) {
            text = w.data;
            return;
          }
          e.visitChildren(visit);
        }

        (element as Element).visitChildren(visit);
        return text;
      }

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focused(), 'Search lessons');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focused(), 'Home');
    });
  });

  group('6T-11: a card is the same size in dark and light', () {
    Future<Size> cardSize(
      WidgetTester tester,
      Widget card, {
      required bool dark,
    }) async {
      await mount(
        tester,
        SizedBox(width: 400, child: card),
        dark: dark,
      );
      await tester.pumpAndSettle();
      return tester.getSize(find.byKey(const ValueKey('sized-card')));
    }

    testWidgets('WebCard', (tester) async {
      size(tester, 1440);
      const card = WebCard(
        key: ValueKey('sized-card'),
        padding: EdgeInsets.all(20),
        child: SizedBox(height: 50, width: double.infinity),
      );
      final dark = await cardSize(tester, card, dark: true);
      final light = await cardSize(tester, card, dark: false);
      expect(dark, light);
      // The edge is still drawn in dark, over the card.
      await cardSize(tester, card, dark: true);
      final box = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const ValueKey('sized-card')),
          matching: find.byType(Container),
        ),
      );
      final edge = box.foregroundDecoration! as BoxDecoration;
      expect((edge.border! as Border).top.color, const Color(0xFF2C2C2C));
    });
  });

  group('5Q-15: the Pro perks do not wrap while the heading has room', () {
    for (final width in [700.0, 620.0]) {
      testWidgets('perks stay on one line at a card width of $width',
          (tester) async {
        size(tester, 1440);
        await mount(
          tester,
          SizedBox(
            width: width,
            child: const WebProHero(
              heading: "You're on Pro.",
              detail: "Thanks for backing Pantas. Here's everything that's "
                  'yours.',
            ),
          ),
        );
        for (final perk in [
          'Notes on why your answer was wrong',
          "Progress that's always backed up",
        ]) {
          final box = tester.getSize(find.text(perk));
          final text = tester.widget<Text>(find.text(perk));
          expect(
            box.height,
            lessThan((text.style?.fontSize ?? 16) * 1.3 * 1.5),
            reason: perk,
          );
        }
      });
    }
  });
}
