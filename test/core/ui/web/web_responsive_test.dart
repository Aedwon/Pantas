import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_keyboard_hints.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';

void main() {
  test('named web tiers follow the D136 boundaries and leave native alone', () {
    for (final entry in <double, WebLayoutTier>{
      599: WebLayoutTier.phone,
      600: WebLayoutTier.tabletPortrait,
      1023: WebLayoutTier.tabletPortrait,
      1024: WebLayoutTier.compact,
      1279: WebLayoutTier.compact,
      1280: WebLayoutTier.compact,
      1439: WebLayoutTier.compact,
      1440: WebLayoutTier.wide,
    }.entries) {
      expect(webLayoutTier(width: entry.key, web: true), entry.value);
      expect(webLayoutTier(width: entry.key, web: false), WebLayoutTier.phone);
    }
  });
  for (final width in [599.0, 600.0, 1023.0]) {
    testWidgets('narrow route column at $width', (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const contentKey = ValueKey('phone-content');
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WebRouteShell(
              path: '/home',
              child: Scaffold(key: contentKey, body: Text('Phone content')),
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.byKey(contentKey)).width,
        width < 640 ? width : 640,
      );
      expect(tester.getCenter(find.byKey(contentKey)).dx, width / 2);
      expect(tester.takeException(), isNull);
    });
  }
  for (final path in ['/guardian', '/guardian/waiting', '/guardian/contact']) {
    testWidgets('$path has no tab navigation on a tablet', (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1100, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            home: WebRouteShell(
              path: path,
              child: const Scaffold(body: Text('Guardian')),
            ),
          ),
        ),
      );
      expect(find.byType(AppNavBar), findsNothing);
      expect(find.text('Guardian'), findsOneWidget);
    });
  }
  testWidgets('touch keeps copy instructions and removes button hint spacing',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: WebKeyboardHints(
          finePointer: false,
          child: Scaffold(
            body: Column(
              children: [
                const WebKeyHint('Click to copy', keyboard: false),
                WebButton(label: 'Next', keyHint: 'Enter', onPressed: () {}),
                WebButton(label: 'Next', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Click to copy'), findsOneWidget);
    expect(find.text('Enter'), findsNothing);
    final buttons = find.byType(TextButton);
    expect(tester.getSize(buttons.at(0)), tester.getSize(buttons.at(1)));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.pump();
    expect(find.text('Click to copy'), findsOneWidget);
    expect(find.text('Enter'), findsOneWidget);
    expect(
      tester.getSize(buttons.at(0)).width,
      greaterThan(tester.getSize(buttons.at(1)).width),
    );
  });
  for (final fine in [false, true]) {
    testWidgets('hint visibility with fine pointer $fine and hardware key',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: WebKeyboardHints(
            finePointer: fine,
            child: const Scaffold(body: WebKeyHint('Esc')),
          ),
        ),
      );
      expect(find.text('Esc'), fine ? findsOneWidget : findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();
      expect(find.text('Esc'), findsOneWidget);
    });
  }
  testWidgets('a hardware key reveals every hint across child replacement',
      (tester) async {
    late StateSetter update;
    var nextPage = false;
    var shortcutCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: WebKeyboardHints(
          finePointer: false,
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.keyA): () =>
                      shortcutCalls++,
                },
                child: Focus(
                  autofocus: true,
                  child: Scaffold(
                    body: Column(
                      children: [
                        WebKeyHint(nextPage ? 'Enter' : 'Esc'),
                        const WebKeyHint('F'),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Esc'), findsNothing);
    expect(find.text('F'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.pump();
    expect(shortcutCalls, 1);
    expect(find.text('Esc'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
    update(() => nextPage = true);
    await tester.pump();
    expect(find.text('Enter'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
  });
}
