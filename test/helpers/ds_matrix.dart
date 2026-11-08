import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// One cell of the design system check matrix: a width, a theme and a text
/// scale (plan: 390 and 1440 wide, light and dark, text scale 1.0 and 2.0).
class DsCell {
  const DsCell(this.width, this.scale, {required this.dark});
  final double width;
  final bool dark;
  final double scale;
  @override
  String toString() => '${width.toInt()} ${dark ? 'dark' : 'light'} x$scale';
}

const dsCells = <DsCell>[
  DsCell(390, 1, dark: false),
  DsCell(390, 1, dark: true),
  DsCell(390, 2, dark: false),
  DsCell(390, 2, dark: true),
  DsCell(1440, 1, dark: false),
  DsCell(1440, 1, dark: true),
  DsCell(1440, 2, dark: false),
  DsCell(1440, 2, dark: true),
];

/// Pumps [child] inside the real Pantas theme at [cell] and returns once it
/// has settled. The wide cells run as the web build, the narrow ones as the
/// phone build.
Future<void> pumpDs(
  WidgetTester tester,
  DsCell cell,
  Widget child, {
  bool scroll = true,
}) async {
  tester.view
    ..physicalSize = Size(cell.width, 900)
    ..devicePixelRatio = 1;
  addTearDown(() {
    tester.view.reset();
    debugWebPlatformOverride = null;
  });
  debugWebPlatformOverride = cell.width >= 1024;
  final theme = cell.dark
      ? buildDarkTheme(web: cell.width >= 1024)
      : buildLightTheme(web: cell.width >= 1024);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: Size(cell.width, 900),
        textScaler: TextScaler.linear(cell.scale),
      ),
      child: MaterialApp(
        theme: theme,
        home: Scaffold(
          body: scroll
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Align(alignment: Alignment.topLeft, child: child),
                )
              : child,
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
}

/// Runs the check for every cell of [dsCells] under [description]. A layout
/// overflow raised while pumping fails the test.
void dsMatrix(
  String description,
  Widget Function(BuildContext context) build, {
  Future<void> Function(WidgetTester tester, DsCell cell)? check,
  bool scroll = true,
}) {
  for (final cell in dsCells) {
    testWidgets('$description ($cell)', (tester) async {
      await pumpDs(
        tester,
        cell,
        Builder(builder: build),
        scroll: scroll,
      );
      expect(tester.takeException(), isNull);
      if (check != null) await check(tester, cell);
    });
  }
}
