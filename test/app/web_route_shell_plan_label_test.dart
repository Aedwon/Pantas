import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

void main() {
  Future<void> pumpShell(
    WidgetTester tester,
    Future<bool> Function() pro,
  ) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proForActiveExamProvider.overrideWith((ref) => pro()),
          activeExamShortNameProvider.overrideWithValue('PUP CET'),
        ],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: const WebRouteShell(path: '/study', child: SizedBox()),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a plan still loading is not shown as Free', (tester) async {
    await pumpShell(tester, () => Completer<bool>().future);

    expect(find.textContaining('Free'), findsNothing);
    expect(find.text('PUP CET'), findsWidgets);
  });

  testWidgets('a resolved plan is shown', (tester) async {
    await pumpShell(tester, () async => true);
    await tester.pump();

    expect(find.text('PUP CET · Pro'), findsOneWidget);
  });
}
