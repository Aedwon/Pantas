import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/theme/app_text_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../golden_harness.dart';

/// The two widths every key screen is captured at: a phone and the wide web
/// layout.
const List<double> screenWidths = [390, 1440];

/// The fixed moment every screen shows: 2026-11-09 09:00 local. Screens that
/// take a clock get this one. Screens that read the real clock are fixed in
/// their own fixtures.
final DateTime screenNow = DateTime(2026, 11, 9, 9);

/// The height of the captured window at [width]: a phone screen or a laptop.
double screenHeight(double width) => width >= 1024 ? 900 : 844;

/// Pumps one screen at `width` and returns what to capture.
typedef ScreenPump = Future<Finder> Function(
  WidgetTester tester,
  double width,
);

/// Loads the math fonts the lesson renderer draws formulas with and the
/// Material icon font, so a formula or icon is not a box. The regular face
/// stands in for the bold and italic.
Future<void> _loadMathFonts() async {
  // The Material icons some controls still use draw as boxes without this.
  await (FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
      .load();
  const base = 'packages/flutter_math_fork/lib/katex_fonts/fonts';
  for (final (family, file) in [
    ('Main', 'Main-Regular'),
    ('Math', 'Math-Italic'),
    ('AMS', 'AMS-Regular'),
    ('Size1', 'Size1-Regular'),
    ('Size2', 'Size2-Regular'),
    ('Size3', 'Size3-Regular'),
    ('Size4', 'Size4-Regular'),
  ]) {
    final loader = FontLoader('packages/flutter_math_fork/KaTeX_$family')
      ..addFont(rootBundle.load('$base/KaTeX_$file.ttf'));
    await loader.load();
  }
}

final List<Future<void> Function()> _afterCapture = [];

/// Runs [done] inside the test once the image is compared, before the binding
/// checks for pending timers. Use it to take a page down and close stores.
void afterCapture(Future<void> Function() done) => _afterCapture.add(done);

/// Registers one golden test per width in [widths]. The image is saved as
/// `files/screens/<name>_<width>.png`.
///
/// Animations are off (the [MediaQuery] says so) and the pumps run a fixed
/// number of frames, so nothing waits on a clock or an endless animation.
void goldenScreen(
  String name,
  ScreenPump pump, {
  List<double> widths = screenWidths,
}) {
  for (final width in widths) {
    testWidgets(
      '$name at ${width.toInt()}',
      (tester) async {
        await loadGoldenFonts();
        await _loadMathFonts();
        driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
        goldenFileComparator = TolerantGoldenComparator(
          Uri.parse(
            '${(goldenFileComparator as LocalFileComparator).basedir}x',
          ),
        );
        // flutter_test turns box shadows off; the app has soft shadows. The
        // binding checks the flag before tear-downs run, so reset it here.
        debugDisableShadows = false;
        try {
          final target = await pump(tester, width);
          expect(tester.takeException(), isNull);
          await expectLater(
            target,
            matchesGoldenFile('../files/screens/${name}_${width.toInt()}.png'),
          );
        } finally {
          for (final done in _afterCapture.reversed) {
            await done();
          }
          _afterCapture.clear();
          debugDisableShadows = true;
          debugWebPlatformOverride = null;
        }
      },
      tags: goldenTag,
    );
  }
}

/// Pumps [child] full screen at [width] in the real theme, light, with
/// animations off, under a [ProviderScope] with [overrides].
///
/// [router] puts [child] on a one-route router, for screens that read
/// GoRouter. [appTextScale] adds the app-root text scale the reader uses.
Future<Finder> pumpScreen(
  WidgetTester tester,
  double width,
  Widget child, {
  List<Override> overrides = const [],
  bool dark = false,
  bool router = false,
  bool appTextScale = false,
  int frames = 6,
}) async {
  final web = width >= 1024;
  final size = Size(width, screenHeight(width));
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  debugWebPlatformOverride = web;
  final key = GlobalKey();
  final theme = dark ? buildDarkTheme(web: web) : buildLightTheme(web: web);
  Widget framed(Widget page) => MediaQuery(
        data: MediaQueryData(size: size, disableAnimations: true),
        child: RepaintBoundary(
          key: key,
          child: appTextScale ? AppTextScale(child: page) : page,
        ),
      );
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: overrides,
      child: router
          ? MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: theme,
              builder: (context, page) => framed(page ?? const SizedBox()),
              routerConfig: GoRouter(
                routes: [GoRoute(path: '/', builder: (_, __) => child)],
              ),
            )
          : MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme,
              home: framed(child),
            ),
    ),
  );
  await settleFrames(tester, frames);
  return find.byKey(key);
}

/// Pumps a fixed number of frames. A spinner or a timer that never ends
/// cannot stall the screen, and two runs show the same frame.
Future<void> settleFrames(WidgetTester tester, [int frames = 6]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

/// A page the matrix tests pump inside a [Scaffold] body.
Widget scaffolded(Widget child) => Scaffold(body: child);

/// The sidebar items, in order, for [inShell].
enum ShellTab { home, study, quiz, settings }

/// Puts [page] in the wide app frame with [tab] selected when [width] is the
/// wide layout, as the app shows it. At phone width the page is returned
/// bare. A wide page needs no extra Scaffold: the frame sits in one.
Widget inShell(Widget page, double width, ShellTab tab) => width >= 1024
    ? Scaffold(
        body: WebShellFrame(
          activeIndex: tab.index,
          person: 'Student',
          exam: 'CSE',
          plan: 'Free',
          web: true,
          onNavigate: (_) {},
          onSearch: () {},
          child: page,
        ),
      )
    : page;
