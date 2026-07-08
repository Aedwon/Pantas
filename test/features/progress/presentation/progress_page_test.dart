import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/features/metrics/providers/current_archetype_provider.dart';
import 'package:cse_cet_reviewer/features/metrics/providers/metrics_signal_providers.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/paywall_teaser_panel.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/progress_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _buildRouter({required bool proIsActive}) => GoRouter(
      initialLocation: '/progress',
      routes: [
        GoRoute(
          path: '/progress',
          builder: (_, __) => Scaffold(
            body: ProgressPage(proIsActive: proIsActive),
          ),
        ),
        GoRoute(
          path: '/paywall',
          builder: (_, __) => const Scaffold(body: Text('Paywall')),
        ),
      ],
    );

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'cse',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await AppPreferencesRepository(db).setSelectedExamId('cse');
  });

  tearDown(() => db.close());

  Future<void> pumpProgress(
    WidgetTester tester, {
    required bool proIsActive,
    List<Override> overrides = const [],
  }) async {
    await tester.pumpAppWithRouter(
      _buildRouter(proIsActive: proIsActive),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        currentArchetypeProvider.overrideWith((ref, request) async => null),
        metricsSignalProvider.overrideWith((ref, request) async => null),
        ...overrides,
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('free user sees teaser with unlock affordance', (tester) async {
    await pumpProgress(tester, proIsActive: false);

    expect(find.byType(PaywallTeaserPanel), findsNWidgets(3));
    expect(find.text('Unlock with Pro'), findsNWidgets(3));
    expect(find.text('Accuracy trend'), findsOneWidget);
    expect(find.text("Where you're slipping"), findsOneWidget);
    expect(find.text('Mock exams'), findsOneWidget);
    expect(find.text('Milestones'), findsOneWidget);

    await tester.tap(find.text('Unlock with Pro').first);
    await tester.pumpAndSettle();
    expect(find.text('Paywall'), findsOneWidget);
  });

  testWidgets('pro user sees coming-soon panel, no unlock text',
      (tester) async {
    await pumpProgress(tester, proIsActive: true);

    expect(find.byType(PaywallTeaserPanel), findsNothing);
    expect(find.text('Unlock with Pro'), findsNothing);
    expect(
      find.text('Charts land here in an upcoming update.'),
      findsNWidgets(3),
    );
  });

  testWidgets('archetype panel renders label when provider resolves',
      (tester) async {
    await pumpProgress(
      tester,
      proIsActive: false,
      overrides: [
        currentArchetypeProvider.overrideWith(
          (ref, request) async => const CurrentArchetype(
            id: 'steady_builder',
            label: 'Steady builder',
            matchScore: 0.9,
            synthesizedCopy: 'You study a little every day.',
          ),
        ),
      ],
    );

    expect(find.text('Your profile'), findsOneWidget);
    expect(find.text('Steady builder'), findsOneWidget);
    expect(find.text('You study a little every day.'), findsOneWidget);
  });

  testWidgets('null signals render no stats band', (tester) async {
    await pumpProgress(tester, proIsActive: false);

    expect(find.byType(StatsBand), findsNothing);
  });
}
