import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/web_page_transitions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

const _arriving = Key('arriving');

Finder get _solidBackground => find.ancestor(
      of: find.byKey(_arriving),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox &&
            widget.color == buildDarkTheme(web: true).scaffoldBackgroundColor,
      ),
    );

Future<void> _pushPage(WidgetTester tester, {required double width}) async {
  debugWebPlatformOverride = true;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildDarkTheme(web: true),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const SizedBox.expand(key: _arriving),
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('a wide page arrives on a solid background', (tester) async {
    await _pushPage(tester, width: 1440);
    expect(_solidBackground, findsOneWidget);
  });

  testWidgets('a phone page is left as it was', (tester) async {
    await _pushPage(tester, width: 390);
    expect(_solidBackground, findsNothing);
  });

  test('every desktop browser and iOS slide, and Android keeps its own', () {
    final builders = webPageTransitionsTheme.builders;
    PageTransitionsBuilder inner(TargetPlatform platform) =>
        (builders[platform]! as SolidWidePageTransitionsBuilder).delegate;
    for (final platform in [
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.iOS,
    ]) {
      expect(inner(platform), isA<CupertinoPageTransitionsBuilder>());
      expect(
        builders[platform]!.transitionDuration,
        const Duration(milliseconds: 500),
      );
    }
    expect(
      inner(TargetPlatform.android),
      isA<PredictiveBackPageTransitionsBuilder>(),
    );
  });

  test('a native build keeps Flutter default transitions', () {
    expect(
      buildDarkTheme(web: false).pageTransitionsTheme,
      isNot(same(webPageTransitionsTheme)),
    );
  });
}
