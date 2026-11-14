import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';

import '../helpers/in_memory_database.dart';

class _Sink implements Telemetry {
  final screens = <String>[];

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    if (event == TelemetryEvent.screenViewed) {
      screens.add(properties!['screen']! as String);
    }
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}

void main() {
  testWidgets('the app router logs each screen change through telemetry',
      (tester) async {
    final db = inMemoryDatabase();
    final contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'cse',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    final preferences = AppPreferencesRepository(db);
    await preferences.setPassedAgeGate(value: true);
    await preferences.setSelectedExamId('cse');
    final sink = _Sink();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        entitlementProvider
            .overrideWith((_) => Stream.value(const Entitlement.free())),
        telemetryProvider.overrideWithValue(sink),
      ],
    );
    final router = container.read(routerProvider);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child:
            MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    router.go('/plan');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    router.go('/plan');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(sink.screens, contains('plan'));
    expect(sink.screens.where((s) => s == 'plan'), hasLength(1));
    expect(sink.screens, isNot(contains('startup')));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    container.dispose();
    // Closing the database lets drift's stream cleanup finish in real time.
    // That cleanup then schedules a zero-length timer on the test clock, so
    // pump after it, or the bundled CI run reports the timer as pending.
    await tester.runAsync(db.close);
    await tester.pump(const Duration(seconds: 1));
  });
}
