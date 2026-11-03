import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../../core/ui/motion/preview_curves.dart';

final _theme = buildLightTheme();
final _webTheme = buildLightTheme(web: true);

/// Item 17, demos 1 and 3: the tab bar pill and the sidebar marker glide, and
/// the icon color fades. Checked against the approved preview's own numbers.

Widget _bar(int index, {bool reduced = false}) => MaterialApp(
      theme: _theme,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(
          bottomNavigationBar: AppNavBar(currentIndex: index, onTap: (_) {}),
        ),
      ),
    );

Widget _side(int index, {bool reduced = false}) => MaterialApp(
      theme: _webTheme,
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(1440, 900),
          disableAnimations: reduced,
        ),
        child: Scaffold(
          body: Row(
            children: [
              WebSidebar(
                activeIndex: index,
                person: 'Aedwon',
                exam: 'CSE',
                plan: 'Free',
                onNavigate: (_) {},
                onSearch: () {},
              ),
            ],
          ),
        ),
      ),
    );

/// Flutter's cubic and the preview's solver differ by about a thousandth.
Matcher _closeTo(Color? want) => _CloseColor(want!);

class _CloseColor extends Matcher {
  const _CloseColor(this.want);
  final Color want;
  @override
  Description describe(Description description) =>
      description.add('within .01 of $want');
  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is Color &&
      (item.r - want.r).abs() < .01 &&
      (item.g - want.g).abs() < .01 &&
      (item.b - want.b).abs() < .01;
}

Rect _pill(WidgetTester tester) => tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('nav-pill')),
        matching: find.byType(DecoratedBox),
      ),
    );

Color? _icon(WidgetTester tester, IconData glyph) =>
    tester.widget<Icon>(find.byIcon(glyph)).color;

Rect _marker(WidgetTester tester) => tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('sidebar-marker')),
        matching: find.byType(DecoratedBox),
      ),
    );

void main() {
  const light = PantasColors.light;

  group('phone tab bar (demo 1)', () {
    testWidgets('the pill glides 240 ms on the shared ease', (tester) async {
      await tester.pumpWidget(_bar(0));
      final from = _pill(tester);
      await tester.pumpWidget(_bar(2));
      await tester.pump(); // the animation clock starts on this frame
      final tabs = tester.getRect(find.byType(AppNavBar));
      expect(from.left, closeTo(tabs.left + 6, .5));

      final startLeft = from.left;
      // Where the pill ends is where the third tab sits.
      await tester.pump(const Duration(milliseconds: 240));
      final to = _pill(tester);
      expect(to.left, greaterThan(startLeft + 100));

      // Replay, sampling frames.
      await tester.pumpWidget(_bar(0));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_bar(2));
      await tester.pump();
      var elapsed = 0;
      for (final ms in [60, 60, 60, 60]) {
        await tester.pump(Duration(milliseconds: ms));
        elapsed += ms;
        final want =
            previewLerp(from.left, to.left, previewShared(elapsed / 240));
        expect(_pill(tester).left, closeTo(want, 1.5), reason: '$elapsed ms');
        expect(_pill(tester).top, from.top, reason: 'it only moves sideways');
        expect(_pill(tester).height, from.height);
      }
    });

    testWidgets('the icon and label colors fade 160 ms on the ease',
        (tester) async {
      await tester.pumpWidget(_bar(0));
      expect(_icon(tester, PantasIcons.quizTab), light.secondaryLabel);
      await tester.pumpWidget(_bar(2));
      await tester.pump();
      var elapsed = 0;
      for (final ms in [40, 40, 40, 40]) {
        await tester.pump(Duration(milliseconds: ms));
        elapsed += ms;
        final p = previewEase(elapsed / 160);
        expect(
          _icon(tester, PantasIcons.quizTab),
          _closeTo(Color.lerp(light.secondaryLabel, light.accent, p)),
          reason: 'icon in at $elapsed ms',
        );
        expect(
          _icon(tester, PantasIcons.homeTab),
          _closeTo(Color.lerp(light.accent, light.secondaryLabel, p)),
          reason: 'icon out at $elapsed ms',
        );
        expect(
          tester.widget<Text>(find.text('Quiz')).style!.color,
          _icon(tester, PantasIcons.quizTab),
        );
      }
    });

    testWidgets('the label never changes weight, so the text cannot jump',
        (tester) async {
      await tester.pumpWidget(_bar(0));
      await tester.pumpWidget(_bar(2));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 60));
        for (final label in ['Home', 'Study', 'Quiz', 'Settings']) {
          expect(
            tester.widget<Text>(find.text(label)).style!.fontWeight,
            FontWeight.w600,
          );
        }
      }
    });

    testWidgets('reduced motion shows the final state in one frame',
        (tester) async {
      await tester.pumpWidget(_bar(0, reduced: true));
      final from = _pill(tester);
      await tester.pumpWidget(_bar(2, reduced: true));
      await tester.pump();
      expect(_pill(tester).left, greaterThan(from.left + 100));
      expect(_icon(tester, PantasIcons.quizTab), light.accent);
      expect(_icon(tester, PantasIcons.homeTab), light.secondaryLabel);
    });

    testWidgets('the motion ends: no endless ticker', (tester) async {
      await tester.pumpWidget(_bar(0));
      await tester.pumpWidget(_bar(3));
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('a rebuild with the same tab does not restart the glide',
        (tester) async {
      await tester.pumpWidget(_bar(1));
      await tester.pumpWidget(_bar(1));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('wide sidebar (demo 3)', () {
    testWidgets('the marker glides 240 ms on the shared ease', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1440, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_side(0));
      final from = _marker(tester);
      await tester.pumpWidget(_side(3));
      await tester.pump();
      // Four rows, 40 px tall, 4 px apart: row 3 starts 132 px below row 0.
      var elapsed = 0;
      for (final ms in [60, 60, 60, 60]) {
        await tester.pump(Duration(milliseconds: ms));
        elapsed += ms;
        final want = from.top + 132 * previewShared(elapsed / 240);
        expect(_marker(tester).top, closeTo(want, 1), reason: '$elapsed ms');
        expect(_marker(tester).left, from.left, reason: 'only moves down');
        expect(_marker(tester).height, 40);
      }
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('the icon color fades 160 ms on the ease', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1440, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_side(0));
      final off = _icon(tester, PantasIcons.quizTab)!;
      final on = _icon(tester, PantasIcons.homeTab)!;
      await tester.pumpWidget(_side(2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final p = previewEase(80 / 160);
      expect(
        _icon(tester, PantasIcons.quizTab),
        _closeTo(Color.lerp(off, on, p)),
      );
      expect(
        _icon(tester, PantasIcons.homeTab),
        _closeTo(Color.lerp(on, off, p)),
      );
    });

    testWidgets('reduced motion shows the final state in one frame',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1440, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_side(0, reduced: true));
      final from = _marker(tester);
      final off = _icon(tester, PantasIcons.quizTab)!;
      await tester.pumpWidget(_side(2, reduced: true));
      await tester.pump();
      expect(_marker(tester).top, closeTo(from.top + 88, .5));
      expect(_icon(tester, PantasIcons.quizTab), isNot(off));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('a page outside the four tabs draws no marker', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1440, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_side(-1));
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('sidebar-marker')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('sidebar-marker')),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
      );
    });
  });
}
