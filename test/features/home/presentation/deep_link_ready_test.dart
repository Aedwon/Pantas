import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/plan_provider.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/presentation/plan_screen.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

void main() {
  for (final kind in ['week', 'locked', 'unknown']) {
    testWidgets('deep plan route waits for visible fallback or error: $kind',
        (tester) async {
      final pending = Completer<PlanView>();
      var signals = 0;
      final path =
          kind == 'week' ? '/plan/week/2026-10-25' : '/plan/day/2026-10-25';
      final router = GoRouter(
        initialLocation: path,
        routes: [
          GoRoute(
            path: path,
            builder: (_, __) => kind == 'week'
                ? const PlanWeekScreen(start: '2026-10-25')
                : const PlanDayScreen(date: '2026-10-25'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firstScreenSignalProvider
                .overrideWithValue(FirstScreenSignal(() => signals++)),
            currentStudyCoverageProvider.overrideWithValue(false),
            studyCoverageLoadingProvider.overrideWithValue(false),
            entitlementProvider
                .overrideWith((_) => Stream.value(const Entitlement.free())),
            planViewProvider(5).overrideWith((_) => pending.future),
            planDayViewProvider('2026-10-25').overrideWith(
              (_) async => PlanDayView(
                date: DateTime(2026, 10, 25),
                plan: null,
                remaining: null,
                lessons: const [],
                kind: kind,
              ),
            ),
          ],
          child: MaterialApp.router(
            theme: buildLightTheme(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (kind != 'unknown') {
        expect(signals, 0);
        pending.complete(
          const PlanView(done: 0, total: 0, nodes: [], history: []),
        );
        await tester.pumpAndSettle();
      }
      expect(signals, 1);
      expect(router.routeInformationProvider.value.uri.path, path);
      expect(tester.takeException(), isNull);
    });
  }
}
