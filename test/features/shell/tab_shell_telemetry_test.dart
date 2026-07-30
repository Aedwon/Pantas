import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('AppShell emits tabOpened when tab is tapped', (tester) async {
    final sink = RecordingTelemetrySink();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          telemetryProvider.overrideWithValue(sink),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const AppShell(
            navigationShell: FakeStatefulNavigationShell(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Study'));
    await tester.pump();

    expect(sink.loggedEvents, [TelemetryEvent.tabOpened]);
    expect(sink.loggedProperties, [
      {'tab': 'study'},
    ]);
  });
}

class FakeStatefulNavigationShell extends StatefulWidget
    implements StatefulNavigationShell {
  const FakeStatefulNavigationShell({super.key});

  @override
  int get currentIndex => 0;

  @override
  void goBranch(int index, {bool initialLocation = false}) {}

  @override
  State<FakeStatefulNavigationShell> createState() =>
      _FakeStatefulNavigationShellState();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStatefulNavigationShellState
    extends State<FakeStatefulNavigationShell> {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class RecordingTelemetrySink implements Telemetry {
  final loggedEvents = <TelemetryEvent>[];
  final loggedProperties = <Map<String, Object>?>[];

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    loggedEvents.add(event);
    loggedProperties.add(properties);
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}
