import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/install/install_platform.dart';
import 'package:pantas/core/ui/components/install_card.dart';
import 'package:pantas/core/ui/components/install_sheet.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

Widget _host({
  required Widget child,
  Brightness brightness = Brightness.light,
  double width = 390,
}) =>
    MaterialApp(
      theme: brightness == Brightness.dark
          ? buildDarkTheme(web: true)
          : buildLightTheme(web: true),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: width, child: child),
        ),
      ),
    );

void main() {
  for (final brightness in Brightness.values) {
    final theme = brightness.name;

    testWidgets('phone card, native install, $theme', (tester) async {
      var installs = 0;
      var notNows = 0;
      await tester.pumpWidget(
        _host(
          brightness: brightness,
          child: InstallCard(
            path: InstallPath.native,
            onPrimary: () => installs++,
            onNotNow: () => notNows++,
          ),
        ),
      );
      expect(find.text('Keep Pantas on your Home Screen'), findsOneWidget);
      expect(
        find.text(
          'Pantas opens faster and keeps working without internet. '
          'Your progress stays the same.',
        ),
        findsOneWidget,
      );
      expect(find.text('Install Pantas'), findsOneWidget);
      expect(find.text('Show Me How'), findsNothing);
      // Phone order: the primary button comes first in reading order. The
      // test font is wide, so the two may land on separate lines.
      final primary = tester.getTopLeft(find.text('Install Pantas'));
      final secondary = tester.getTopLeft(find.text('Not Now'));
      expect(
        primary.dy < secondary.dy ||
            (primary.dy == secondary.dy && primary.dx < secondary.dx),
        isTrue,
      );
      await tester.tap(find.text('Install Pantas'));
      await tester.tap(find.text('Not Now'));
      expect([installs, notNows], [1, 1]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('wide card, native install, $theme', (tester) async {
      await tester.pumpWidget(
        _host(
          brightness: brightness,
          width: 1080,
          child: InstallCard(
            path: InstallPath.native,
            onPrimary: () {},
            onNotNow: () {},
          ),
        ),
      );
      expect(find.text('Keep Pantas one click away'), findsOneWidget);
      expect(
        find.text(
          'Install it and Pantas opens in its own window, like any app. '
          'Your progress stays the same.',
        ),
        findsOneWidget,
      );
      // Wide order: Not Now, then the primary button.
      expect(
        tester.getTopLeft(find.text('Not Now')).dx,
        lessThan(tester.getTopLeft(find.text('Install Pantas')).dx),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('iPhone card says Show Me How, $theme', (tester) async {
      await tester.pumpWidget(
        _host(
          brightness: brightness,
          child: InstallCard(
            path: InstallPath.iosInstructions,
            onPrimary: () {},
            onNotNow: () {},
          ),
        ),
      );
      expect(find.text('Show Me How'), findsOneWidget);
      expect(find.text('Install Pantas'), findsNothing);
      expect(find.text('Keep Pantas on your Home Screen'), findsOneWidget);
    });

    testWidgets('the iPhone sheet shows three steps, $theme', (tester) async {
      await tester.pumpWidget(
        _host(
          brightness: brightness,
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => showInstallSheet(context),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Add Pantas to your Home Screen'), findsOneWidget);
      expect(
        find.text('Then it opens like any app. Your progress stays the same.'),
        findsOneWidget,
      );
      for (final copy in [
        'Tap Share',
        'It is in the Safari toolbar at the bottom.',
        'Tap Add to Home Screen',
        'Scroll down in the list to find it.',
        'Tap Add',
        'Pantas appears on your Home Screen.',
      ]) {
        expect(find.text(copy), findsOneWidget);
      }
      expect(find.byKey(const ValueKey('install-share-ring')), findsOneWidget);
      expect(find.text('Got It'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Got It'));
      await tester.pumpAndSettle();
      expect(find.text('Add Pantas to your Home Screen'), findsNothing);
    });
  }

  testWidgets('an iPad-wide iOS card keeps the Home Screen wording',
      (tester) async {
    await tester.pumpWidget(
      _host(
        width: 1080,
        child: InstallCard(
          path: InstallPath.iosInstructions,
          onPrimary: () {},
          onNotNow: () {},
        ),
      ),
    );
    expect(find.text('Keep Pantas on your Home Screen'), findsOneWidget);
    expect(find.text('Show Me How'), findsOneWidget);
  });

  testWidgets('the card needs an install path', (tester) async {
    expect(
      () => InstallCard(
        path: InstallPath.none,
        onPrimary: () {},
        onNotNow: () {},
      ),
      throwsAssertionError,
    );
  });
}
