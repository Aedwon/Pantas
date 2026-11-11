import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_page.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

// ignore_for_file: cascade_invocations

/// Item 3 (Nov 3): "My exam isn't listed" ended on /onboarding showing three
/// gray bars forever. This drives the whole custom path through the real app,
/// router and in-memory repositories. The exam list was read before the track
/// existed and never re-read, so the router decided no exam was chosen and
/// kept the student on the finishing screen.
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

  for (final web in [false, true]) {
    testWidgets(
      'custom exam reaches /home with no bars left (web: $web)',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              contentDatabaseProvider.overrideWithValue(contentDb),
              onboardingWebProvider.overrideWithValue(web),
              examPickerCatalogProvider
                  .overrideWith((ref) => Stream.value(const [])),
              entitlementProvider.overrideWith(
                (_) => Stream.value(const Entitlement.free()),
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
        String location() =>
            router.routerDelegate.currentConfiguration.uri.toString();

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
        expect(find.text('When is your exam?'), findsOneWidget);
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
        expect(find.byType(LoadingShapes), findsNothing);
        expect(location(), '/home');
        expect(
          await AppPreferencesRepository(db).hasCompletedOnboarding(),
          isTrue,
        );
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        });
      },
    );
  }
}
