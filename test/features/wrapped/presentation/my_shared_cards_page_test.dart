import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/wrapped/application/wrapped_providers.dart';
import 'package:pantas/features/wrapped/data/user_metrics_artifact_repository.dart';
import 'package:pantas/features/wrapped/domain/wrapped_payload.dart';
import 'package:pantas/features/wrapped/presentation/my_shared_cards_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';
import '../fake_wrapped_share_host.dart';

/// Pumps with the ink splash disabled so the tap test does not depend on the
/// `ink_sparkle` shader asset (absent in some headless test bundles).
Future<void> _pumpNoSplash(
  WidgetTester tester,
  Widget child, {
  required List<Override> overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: buildLightTheme().copyWith(
          splashFactory: NoSplash.splashFactory,
        ),
        home: child,
      ),
    ),
  );
  await tester.pump();
}

Future<void> _seedShared(AppDatabase db) async {
  final repo = UserMetricsArtifactRepository(db);
  await repo.upsert(
    UserMetricsArtifactEntry(
      userId: 'user_1',
      examId: 'exam_cse',
      artifactId: 'streak_milestone',
      payload: const WrappedPayload(
        title: 'Day 7 Streak',
        slides: [WrappedSlide(title: 'Streak', body: '7 days')],
        archetypeId: 'steady_builder',
        shareId: 'placeholder',
      ),
      firedAt: DateTime.utc(2026, 6, 10),
    ),
  );
  await repo.markShared(
    userId: 'user_1',
    examId: 'exam_cse',
    artifactId: 'streak_milestone',
    sharedAt: DateTime.utc(2026, 6, 11),
    sharePlatform: 'local_png',
    shareId: 'hostedshareid0000000000000000abcd',
  );
}

void main() {
  testWidgets('lists hosted cards and revokes via the host', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _seedShared(db);
    final host = FakeWrappedShareHost();

    await _pumpNoSplash(
      tester,
      const MySharedCardsPage(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        wrappedShareHostProvider.overrideWithValue(host),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Day 7 Streak'), findsOneWidget);
    expect(
      find.text('pantas.app/wrapped/hostedshareid0000000000000000abcd'),
      findsOneWidget,
    );

    await tester.tap(find.text('Revoke'));
    await tester.pumpAndSettle();

    expect(host.revoked, contains('hostedshareid0000000000000000abcd'));
    expect(find.text('Day 7 Streak'), findsNothing);
  });

  testWidgets('shows empty state when nothing is shared', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await tester.pumpAppWithProviders(
      const MySharedCardsPage(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('No shared cards yet'), findsOneWidget);
  });

  testWidgets('Revoke is a named 48dp action', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _seedShared(db);

    await tester.pumpAppWithProviders(
      const MySharedCardsPage(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    final revoke = find.bySemanticsLabel('Revoke');
    expect(revoke, findsOneWidget);
    expect(tester.getSize(revoke).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(revoke).width, greaterThanOrEqualTo(48));
    expect(
      tester.getSemantics(revoke).getSemanticsData().hasAction(
            SemanticsAction.tap,
          ),
      isTrue,
    );
  });
}
