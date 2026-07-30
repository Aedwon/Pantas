import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/wrapped/data/user_metrics_artifact_repository.dart';
import 'package:pantas/features/wrapped/domain/wrapped_payload.dart';
import 'package:pantas/features/wrapped/presentation/wrapped_reveal_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('loads local artifact with privacy toggles default off',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await UserMetricsArtifactRepository(db).upsert(
      UserMetricsArtifactEntry(
        userId: 'user_1',
        examId: 'exam_cse',
        artifactId: 'artifact_1',
        payload: const WrappedPayload(
          title: 'Mock 3 - Personal Best',
          slides: [WrappedSlide(title: 'Score', body: 'You beat your best.')],
          archetypeId: 'game_day_player',
          shareId: 'share_1',
        ),
        firedAt: DateTime(2026, 6, 10),
      ),
    );

    await tester.pumpAppWithProviders(
      const WrappedRevealPage(artifactId: 'artifact_1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Mock 3 - Personal Best'), findsOneWidget);
    expect(find.text('You beat your best.'), findsOneWidget);
    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches.map((switch_) => switch_.value), everyElement(isFalse));
    expect(find.text('Share PNG'), findsOneWidget);
  });

  testWidgets('shows unavailable state when cache row is missing',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await tester.pumpAppWithProviders(
      const WrappedRevealPage(artifactId: 'missing'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        "Your Wrapped needs a connection. It'll be here when you're back.",
      ),
      findsOneWidget,
    );
  });
}
