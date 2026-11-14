import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// Share of differing pixels above which a golden fails (lead ruling: 0.1%).
const double goldenTolerance = 0.001;

/// The tag every golden test carries. `dart_test.yaml` skips it by default.
const String goldenTag = 'golden';

/// Loads the fonts the app ships, under the family names the theme asks for.
/// Without them the test font is a box face and a golden proves nothing.
Future<void> loadGoldenFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(rootBundle.load(file));
    }
    await loader.load();
  }

  await load('Geist', [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
      'assets/fonts/Geist-$w.ttf',
  ]);
  await load('Source Serif 4', ['assets/fonts/SourceSerif4-Variable.ttf']);
  await load('Phosphor', ['assets/fonts/phosphor/Phosphor.ttf']);
  await load('PhosphorFill', ['assets/fonts/phosphor/Phosphor-Fill.ttf']);
  await load('PhosphorBold', ['assets/fonts/phosphor/Phosphor-Bold.ttf']);
}

/// Passes up to [goldenTolerance] of differing pixels, so a one-pixel
/// anti-aliasing difference between machines does not fail a sheet.
class TolerantGoldenComparator extends LocalFileComparator {
  TolerantGoldenComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= goldenTolerance) return true;
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}

/// How a state is reached. Rest is untouched; the others are driven live.
enum GoldenAction {
  rest,

  /// A mouse pointer moves onto the cell.
  hover,

  /// A pointer is pressed on the cell and held.
  pressed,

  /// The keyboard moves focus onto the cell (Tab), so the focus ring shows.
  focus,

  /// A pointer taps the cell, for a control that opens something (a select's
  /// list).
  tap,
}

/// One cell of a sheet: a labeled state of the component.
class GoldenState {
  const GoldenState(
    this.label,
    this.build, {
    this.action = GoldenAction.rest,
    this.width,
    this.web,
    this.at = Alignment.center,
    this.window,
    this.target,
    this.tabs = 1,
  });

  final String label;
  final WidgetBuilder build;
  final GoldenAction action;

  /// The widest the cell's content may be. Defaults to the sheet's cell width.
  final double? width;

  /// Draws this cell with the web (desktop) layout or the phone layout,
  /// whatever the rest of the sheet does. Null follows the sheet.
  final bool? web;

  /// Where in the cell the pointer lands for hover and pressed. The center by
  /// default; a part of a composite (a bar's counter) names its own spot.
  final Alignment at;

  /// Draws the cell as a whole window of this size, and captures the window.
  /// For a component that lives in the root overlay (a popover, a sheet, a
  /// drawer), which a plain cell would not capture. The builder fills the
  /// window.
  final Size? window;

  /// Finds the part of the cell the pointer lands on, when [at] cannot name it
  /// (a link that is narrower than its cell). Wins over [at].
  final Finder Function()? target;

  /// How many times Tab is pressed for a focus cell.
  final int tabs;
}

/// Rest, hover, pressed and focus cells of one control, plus a disabled cell
/// when [disabled] is given. The labels read "[prefix] rest" and so on.
List<GoldenState> interactionStates(
  String prefix,
  WidgetBuilder build, {
  WidgetBuilder? disabled,
  double? width,
  bool? web,
  Alignment at = Alignment.center,
  Finder Function()? target,
}) =>
    [
      GoldenState('$prefix rest', build, width: width, web: web),
      GoldenState(
        '$prefix hover',
        build,
        action: GoldenAction.hover,
        width: width,
        web: web,
        at: at,
        target: target,
      ),
      GoldenState(
        '$prefix pressed',
        build,
        action: GoldenAction.pressed,
        width: width,
        web: web,
        at: at,
        target: target,
      ),
      GoldenState(
        '$prefix focus',
        build,
        action: GoldenAction.focus,
        width: width,
        web: web,
      ),
      if (disabled != null)
        GoldenState('$prefix disabled', disabled, width: width, web: web),
    ];

/// A theme the sheet renders in.
enum _Mode { light, dark }

const _cellPad = 12.0;
const _gap = 10.0;
const _panelPad = 16.0;

/// Registers one golden test: a sheet of [states] in light and dark side by
/// side, compared with `test/goldens/files/<name>.png`.
///
/// Each cell is pumped alone, so hover, pressed and focus each get a live
/// widget and the one pointer or focus the test owns. The cell is captured to
/// an image and the images are composed into the sheet.
void goldenSheet(
  String name,
  List<GoldenState> states, {
  double cellWidth = 220,
  bool web = false,
  int columns = 3,
  Duration settle = const Duration(milliseconds: 600),
}) {
  testWidgets(
    '$name sheet',
    (tester) async {
      await loadGoldenFonts();
      goldenFileComparator = TolerantGoldenComparator(
        Uri.parse('${(goldenFileComparator as LocalFileComparator).basedir}x'),
      );
      tester.view
        ..physicalSize = const Size(6000, 6000)
        ..devicePixelRatio = 1;
      debugWebPlatformOverride = web;
      // flutter_test turns box shadows off, which draws every drop shadow as
      // a hard gray edge. The app has soft shadows, so the sheet shows them.
      debugDisableShadows = false;
      try {
        addTearDown(() {
          tester.view.reset();
          debugWebPlatformOverride = null;
        });

        final images = <_Mode, List<ui.Image>>{_Mode.light: [], _Mode.dark: []};
        for (final mode in _Mode.values) {
          for (final state in states) {
            images[mode]!.add(
              await _capture(
                tester,
                mode,
                state,
                cellWidth,
                state.web ?? web,
                settle,
              ),
            );
          }
        }
        addTearDown(() {
          for (final list in images.values) {
            for (final image in list) {
              image.dispose();
            }
          }
        });

        tester.view.physicalSize = const Size(6000, 6000);
        final sheetKey = GlobalKey();
        await tester.pumpWidget(
          _themed(
            _Mode.light,
            web,
            Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: sheetKey,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final mode in _Mode.values)
                      _Panel(
                        mode: mode,
                        web: web,
                        columns: columns,
                        title: '$name ${mode.name}',
                        labels: [for (final s in states) s.label],
                        images: images[mode]!,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(sheetKey),
          matchesGoldenFile('../files/$name.png'),
        );
      } finally {
        // The binding checks this flag before tear-downs run.
        debugDisableShadows = true;
      }
    },
    tags: goldenTag,
  );
}

Widget _themed(_Mode mode, bool web, Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: mode == _Mode.dark
          ? buildDarkTheme(web: web)
          : buildLightTheme(web: web),
      home: Material(
        color: Colors.transparent,
        child: Directionality(textDirection: TextDirection.ltr, child: child),
      ),
    );

Future<ui.Image> _capture(
  WidgetTester tester,
  _Mode mode,
  GoldenState state,
  double cellWidth,
  bool web,
  Duration settle,
) async {
  debugWebPlatformOverride = web;
  final boundaryKey = GlobalKey();
  final contentKey = GlobalKey();
  final window = state.window;
  tester.view.physicalSize = window ?? const Size(6000, 6000);
  await tester.pumpWidget(
    window != null
        ? RepaintBoundary(
            key: boundaryKey,
            child: _themed(
              mode,
              web,
              Builder(
                builder: (context) => ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SizedBox(
                    key: contentKey,
                    width: window.width,
                    height: window.height,
                    child: Builder(builder: state.build),
                  ),
                ),
              ),
            ),
          )
        : _themed(
            mode,
            web,
            Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: boundaryKey,
                child: Builder(
                  builder: (context) => ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(_cellPad),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: state.width ?? cellWidth,
                        ),
                        // Unbounded height, as in a card or a page column, so
                        // a component that fills its height does not fill the
                        // view.
                        child: UnconstrainedBox(
                          key: contentKey,
                          alignment: Alignment.topLeft,
                          constrainedAxis: Axis.horizontal,
                          child: Builder(builder: state.build),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
  );
  await tester.pump(const Duration(milliseconds: 100));
  final contentBox = tester.getRect(find.byKey(contentKey));
  final center = state.target != null
      ? tester.getCenter(state.target!())
      : state.at.withinRect(contentBox);
  TestGesture? gesture;
  switch (state.action) {
    case GoldenAction.rest:
      break;
    case GoldenAction.hover:
      gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(1, 1));
      await gesture.moveTo(center);
    case GoldenAction.pressed:
      gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: center);
      await gesture.down(center);
    case GoldenAction.tap:
      await tester.tapAt(center);
    case GoldenAction.focus:
      for (var i = 0; i < state.tabs; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      }
  }
  // Long enough for every press, hover and focus motion to finish, and a
  // fixed number of frames, so an endless spinner cannot stall the sheet.
  for (var t = Duration.zero;
      t < settle;
      t += const Duration(milliseconds: 100)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(tester.takeException(), isNull, reason: state.label);
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(boundaryKey),
  );
  final image = (await tester.runAsync(boundary.toImage))!;
  if (gesture != null) {
    if (state.action == GoldenAction.pressed) await gesture.up();
    await gesture.removePointer();
  }
  return image;
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.mode,
    required this.web,
    required this.columns,
    required this.title,
    required this.labels,
    required this.images,
  });

  final _Mode mode;
  final bool web;
  final int columns;
  final String title;
  final List<String> labels;
  final List<ui.Image> images;

  @override
  Widget build(BuildContext context) {
    final theme = mode == _Mode.dark
        ? buildDarkTheme(web: web)
        : buildLightTheme(web: web);
    final ink = theme.colorScheme.onSurface;
    final caption = TextStyle(
      fontFamily: 'Geist',
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: ink.withValues(alpha: 0.6),
    );
    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(_panelPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title.toUpperCase(), style: caption),
            const SizedBox(height: _gap),
            for (var i = 0; i < images.length; i += columns)
              Padding(
                padding: const EdgeInsets.only(bottom: _gap),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var j = i; j < i + columns && j < images.length; j++)
                      Padding(
                        padding: const EdgeInsets.only(right: _gap),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(labels[j].toUpperCase(), style: caption),
                            const SizedBox(height: 4),
                            RawImage(
                              image: images[j],
                              width: images[j].width.toDouble(),
                              height: images[j].height.toDouble(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
