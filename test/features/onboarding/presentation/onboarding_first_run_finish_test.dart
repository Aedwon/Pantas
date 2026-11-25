import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/first_run/application/first_run_providers.dart';
import 'package:pantas/features/first_run/domain/first_run_progress.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_page.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

// ignore_for_file: cascade_invocations

/// Setup's last step goes to `/try` when the run is offered and to `/home`
/// when it is not (no fixed lesson, or the assessment is already done). The
/// opener is faked on both sides. The router also sends an open run from
/// Home to `/try`, so the test records every stop and checks the last.
void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await DriftSettingsRepository(db).recordPolicyAcceptance();
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await seedContentExam(
      contentDb,
      examId: 'exam_cse_pro',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'exam_cse_pro',
      name: 'Mathematics',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Algebra',
    );
    // Only a topic that holds a question is offered.
    await seedContentQuestion(
      contentDb,
      questionId: 'q1',
      topicId: 't1',
      examId: 'exam_cse_pro',
    );
  });

  tearDown(() => db.close());

  for (final offered in [true, false]) {
    testWidgets(
      'finishing setup goes to ${offered ? '/try' : '/home'} when the run is '
      '${offered ? '' : 'not '}offered',
      (tester) async {
        var opened = false;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              contentDatabaseProvider.overrideWithValue(contentDb),
              onboardingWebProvider.overrideWithValue(false),
              examPickerCatalogProvider
                  .overrideWith((ref) => Stream.value(const [])),
              entitlementProvider.overrideWith(
                (_) => Stream.value(const Entitlement.free()),
              ),
              firstRunOpenerProvider.overrideWith(
                (ref) => () async {
                  opened = offered;
                  ref.invalidate(firstRunPendingProvider);
                  return offered;
                },
              ),
              firstRunPendingProvider.overrideWith(
                (ref) async => opened
                    ? const FirstRunProgress(uid: 'u1', examId: 'exam_cse_pro')
                    : null,
              ),
            ],
            child: const App(flavor: Flavor.dev),
          ),
        );
        await tester.pumpAndSettle();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(App)),
        );
        final router = container.read(routerProvider);
        final seen = <String>[];
        void record() =>
            seen.add(router.routerDelegate.currentConfiguration.uri.path);
        router.routerDelegate.addListener(record);

        await tester.tap(find.text("My exam isn't listed"));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'My Exam');
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mathematics'));
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text("I don't know"));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Every Day'));
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Aedwon');
        await tester.pump();
        await tester.tap(find.text('Done'));
        for (var i = 0; i < 40; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        router.routerDelegate.removeListener(record);
        // The router passes through /home once setup counts as complete,
        // before the page's own step: the last stop is what the learner sees.
        if (offered) {
          expect(seen.last, '/try');
        } else {
          expect(seen.last, '/home');
          expect(seen, isNot(contains('/try')));
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}
