import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/application/beta_pro_provider.dart';
import 'package:pantas/features/settings/presentation/widgets/beta_pro_row.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final width in [390.0, 800.0, 1100.0, 1440.0]) {
      testWidgets('beta row states at $width in $brightness', (tester) async {
        debugWebPlatformOverride = true;
        addTearDown(() => debugWebPlatformOverride = null);
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final updates = StreamController<BetaProState?>();
        addTearDown(updates.close);
        final pending = Completer<void>();
        var calls = 0;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              betaProProvider.overrideWith((ref) => updates.stream),
              setBetaProProvider.overrideWithValue(({required enabled}) {
                expect(enabled, isTrue);
                calls++;
                return pending.future;
              }),
            ],
            child: MaterialApp(
              theme: brightness == Brightness.dark
                  ? buildDarkTheme(web: true)
                  : buildLightTheme(web: true),
              home: const Scaffold(
                body: Column(children: [BetaProRow(), BetaProNote()]),
              ),
            ),
          ),
        );
        expect(find.text('Beta: Pro Features'), findsNothing);
        updates
            .add(BetaProState(until: DateTime(2026, 11, 16), enabled: false));
        await tester.pump();
        expect(find.text('Beta: Pro Features'), findsOneWidget);
        await tester.tap(find.byType(PantasSwitch));
        await tester.pump();
        expect(find.text('Turning On…'), findsOneWidget);
        await tester.tap(find.byType(PantasSwitch), warnIfMissed: false);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(calls, 1);
        updates.add(BetaProState(until: DateTime(2026, 11, 16), enabled: true));
        pending.complete();
        await tester.pumpAndSettle();
        expect(find.text('Turning On…'), findsNothing);
        expect(
          find.text('Pro features are on for the beta, until Nov 16.'),
          findsOneWidget,
        );
        updates.add(null);
        await tester.pumpAndSettle();
        expect(find.text('Beta: Pro Features'), findsNothing);
        expect(
          find.text('Pro features are on for the beta, until Nov 16.'),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
