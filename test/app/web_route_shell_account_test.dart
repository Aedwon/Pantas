import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/core/ui/motion/selection_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

class _Sink implements Telemetry {
  final events = <TelemetryEvent>[];
  final properties = <Map<String, Object>?>[];

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    events.add(event);
    this.properties.add(properties);
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}

void main() {
  testWidgets(
      'the sidebar name row opens Settings, Account, keeps Settings '
      'highlighted and logs the Settings tab', (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.reset);
    final sink = _Sink();
    final router = GoRouter(
      initialLocation: '/study',
      routes: [
        for (final path in ['/study', '/settings/account'])
          GoRoute(
            path: path,
            builder: (context, state) => WebRouteShell(
              path: path,
              child: Text('page $path'),
            ),
          ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          telemetryProvider.overrideWithValue(sink),
          proForActiveExamProvider.overrideWith((ref) async => true),
          activeExamShortNameProvider.overrideWithValue('PUP CET'),
          userSettingsProvider.overrideWith(
            (ref) async => const UserSettings(
              name: 'Ana',
              dailyReminderTime: null,
              studyDays: StudyDays.all,
              examDate: null,
              strictMockMode: false,
              helpImproveApp: false,
              carryOverProgress: true,
              sessionOrdering: SessionOrdering.interleavedTail,
              retainTableOrder: true,
              updatedAt: null,
            ),
          ),
        ],
        child: MaterialApp.router(
          theme: buildLightTheme(web: true),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pro account'), findsOneWidget);
    expect(find.text('PUP CET'), findsNothing);

    await tester.tap(find.text('Ana'));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/settings/account',
    );
    expect(sink.events, [TelemetryEvent.tabOpened]);
    expect(sink.properties, [
      {'tab': 'settings'},
    ]);
    final marker = tester.widget<SlidingMarker>(
      find.byKey(const ValueKey('sidebar-marker')),
    );
    expect(marker.index, 3, reason: 'Settings stays highlighted');
  });
}
