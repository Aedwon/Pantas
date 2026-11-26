// The walk-through lesson in the reader (E-196): the four sample lessons and a
// worst-case lesson, drawn full length the way the reader draws a lesson body,
// at 390 and 1440, light and dark.
//
// One image per lesson, width and theme. It holds two copies of the lesson
// side by side: as loaded (left) and with every Quick Check, Try, Why? and
// Next step revealed (right). The worst-case lesson also has the tap-back
// landed on the pair inside hidden steps (the tint at full, held at its start)
// and the Reduce Motion outline, at 390.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/lesson_markdown.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/reader_full_width.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

import '../../helpers/walkthrough_fixtures.dart';
import 'screen_harness.dart';

/// The tall surface the lesson is laid out on. The captured image is only as
/// tall as the lesson, so one image shows it whole.
const double _surfaceHeight = 40000;

/// The reader's side padding on a phone (`_Reader` in the lesson page).
const double _phonePadding = 24;

/// The wide reader's side room around its column (`WebReaderMetrics`).
const double _wideRoom = 56;

/// The gap between the two copies of the lesson in an image.
const double _gutter = 24;

/// The lesson Markdown of the worst-case fixture, as blocks.
List<Map<String, Object?>> _worstCase() {
  final source = File('test/goldens/screens/fixtures/walkthrough_worst_case.md')
      .readAsStringSync();
  final frontmatter = RegExp(r'^---\n(.*?)\n---\n', dotAll: true);
  final match = frontmatter.firstMatch(source);
  return lessonBlocksFromMarkdown(
    match == null ? source : source.substring(match.end),
  );
}

List<Map<String, Object?>> _sample(String name) =>
    lessonBlocksFromMarkdown(walkthroughFixture(name));

/// One copy of the lesson, in the reader's column and padding.
Widget _panel(
  Key key,
  List<Map<String, Object?>> blocks,
  double width,
) {
  final wide = width >= 1024;
  final column = wide ? readerStandardWidth : width - 2 * _phonePadding;
  final side = wide ? _wideRoom : _phonePadding;
  return Builder(
    builder: (context) => ColoredBox(
      key: key,
      color: context.colors.background,
      child: Padding(
        padding: EdgeInsets.fromLTRB(side, 24, side, 56),
        child: SizedBox(
          width: column,
          child: ContentRenderer(blocks: blocks, readerFigures: true),
        ),
      ),
    ),
  );
}

/// Lays [panels] side by side on a tall surface and returns the finder of the
/// image to capture, which is as tall as the tallest panel.
Future<Finder> _pump(
  WidgetTester tester,
  double width,
  List<Widget> panels, {
  required bool dark,
  required bool still,
}) async {
  final web = width >= 1024;
  // The window is as wide as the copies side by side, so every control can be
  // tapped; the layout still reads the reader's own width.
  final panelWidth = web ? readerStandardWidth + 2 * _wideRoom : width;
  final total = panels.length * panelWidth + (panels.length - 1) * _gutter;
  final size = Size(total, _surfaceHeight);
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  debugWebPlatformOverride = web;
  final sheet = GlobalKey();
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark ? buildDarkTheme(web: web) : buildLightTheme(web: web),
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, _surfaceHeight),
            disableAnimations: still,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              // Never scrolls: the surface is taller than the lesson. It only
              // gives the lesson a height of its own and a Scrollable.
              physics: const NeverScrollableScrollPhysics(),
              child: RepaintBoundary(
                key: sheet,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (i, panel) in panels.indexed) ...[
                      if (i > 0) const SizedBox(width: _gutter),
                      panel,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await settleFrames(tester, 2);
  afterCapture(() async {
    await tester.pumpWidget(const SizedBox());
  });
  return find.byKey(sheet);
}

/// Taps every control that reveals something, inside [within], until none is
/// left: Show answer, Why?, Show all steps.
Future<void> _openAll(WidgetTester tester, Finder within) async {
  Finder inside(String key) =>
      find.descendant(of: within, matching: find.byKey(ValueKey(key)));
  // A bounded loop: a control that does not go after a tap fails the test
  // instead of looping.
  for (final key in [
    'walk-show-all-steps',
    'walk-next-step',
    'walk-answer-button',
  ]) {
    for (var i = 0; inside(key).evaluate().isNotEmpty; i++) {
      expect(i, lessThan(20), reason: '$key stays after a tap');
      await tester.tap(inside(key).first);
      await settleFrames(tester, 2);
    }
  }
  final whys = inside('walk-why-button').evaluate().length;
  for (var i = 0; i < whys; i++) {
    await tester.tap(inside('walk-why-button').at(i));
    await settleFrames(tester, 2);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final lessons = <String, List<Map<String, Object?>> Function()>{
    'discounted_prices': () => _sample('discounted-prices'),
    'subjects_and_verbs': () => _sample('finding-subjects-and-matching-verbs'),
    'signed_integers': () => _sample('signed-integer-operations'),
    'negative_numbers': () => _sample('substituting-negative-numbers'),
    'worst_case': _worstCase,
  };

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    // As loaded, and with everything revealed, side by side.
    for (final MapEntry(key: name, value: load) in lessons.entries) {
      goldenScreen('walkthrough_${name}_$mode', (tester, width) async {
        final blocks = load();
        const rest = ValueKey('walk-golden-rest');
        const open = ValueKey('walk-golden-open');
        final target = await _pump(
          tester,
          width,
          [_panel(rest, blocks, width), _panel(open, blocks, width)],
          dark: dark,
          still: true,
        );
        await _openAll(tester, find.byKey(open));
        await settleFrames(tester, 2);
        expect(tester.takeException(), isNull);
        return target;
      });
    }

    // The tap-back lands on the pair inside hidden steps: the tint at full
    // (the board's PT_CL_Target frame), held at its start.
    goldenScreen(
      'walkthrough_worst_case_tapback_$mode',
      (tester, width) async {
        final target = await _pump(
          tester,
          width,
          [_panel(const ValueKey('walk-golden-tap'), _worstCase(), width)],
          dark: dark,
          still: false,
        );
        await tester.tap(find.byKey(const ValueKey('walk-checklist-row-2')));
        // The steps open (240 ms), then the tint starts and holds 300 ms.
        await tester.pump(const Duration(milliseconds: 260));
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 16));
        expect(
          find.byKey(const ValueKey('walk-tint-minus-before-negative')),
          findsOneWidget,
        );
        return target;
      },
      widths: const [390],
    );

    // With Reduce Motion the target gets a static outline instead.
    goldenScreen(
      'walkthrough_worst_case_outline_$mode',
      (tester, width) async {
        final target = await _pump(
          tester,
          width,
          [_panel(const ValueKey('walk-golden-out'), _worstCase(), width)],
          dark: dark,
          still: true,
        );
        await tester.tap(find.byKey(const ValueKey('walk-checklist-row-2')));
        await settleFrames(tester, 2);
        expect(
          find.byKey(const ValueKey('walk-outline-minus-before-negative')),
          findsOneWidget,
        );
        return target;
      },
      widths: const [390],
    );
  }
}
