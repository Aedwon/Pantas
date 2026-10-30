import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/core/platform/welcome/welcome_handover.dart';
import 'package:pantas/core/platform/welcome/welcome_handover_providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';

import '../helpers/in_memory_database.dart';

class _RecordingHandover implements WelcomeHandover {
  final List<bool> readyCalls = [];

  @override
  bool get shownThisVisit => true;

  @override
  void appReady({required bool holdForTap}) => readyCalls.add(holdForTap);
}

void main() {
  testWidgets('a learner who finished onboarding removes the HTML Welcome',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'cse',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    final preferences = AppPreferencesRepository(db);
    await preferences.setPassedAgeGate(value: true);
    await preferences.setSelectedExamId('cse');
    await preferences.setCompletedOnboarding(value: true);
    final handover = _RecordingHandover();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          welcomeHandoverProvider.overrideWithValue(handover),
        ],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();

    expect(handover.readyCalls, isNotEmpty);
    expect(handover.readyCalls, everyElement(isFalse));
  });

  testWidgets('a new learner keeps the HTML Welcome until the app says so',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final handover = _RecordingHandover();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          welcomeHandoverProvider.overrideWithValue(handover),
        ],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();

    // Onboarding reports ready with a hold, never a release.
    expect(handover.readyCalls, isNot(contains(false)));
  });
}
