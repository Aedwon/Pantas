import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/steps_screen.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_consent_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_exam_date_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_study_days_step.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_name_step.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_subjects_step.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

const cse = ExamCatalogEntry(
  id: 'exam_cse_pro',
  name: 'Civil Service Exam',
  shortName: 'CSE Professional',
  priceTier: 'Civil Service',
  group: 'Civil service',
  comingSoon: false,
  publishedSittings: [],
  hasContent: true,
);

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);
  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    required bool dark,
    Stream<List<ExamCatalogEntry>>? catalog,
    ExamDate? date,
  }) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const SizedBox.shrink());
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse_pro');
    if (date != null) {
      await DriftSettingsRepository(db)
          .updateExamDate(date, today: DateTime(2026, 10, 3));
    }
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => catalog ?? Stream.value([cse])),
          corpusSubjectsWithTopicsProvider.overrideWith(
            (ref) async => <String, Set<TopicId>>{
              'Mathematics': {'math'},
              'English': {'english'},
            },
          ),
        ],
        child: MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(body: screen),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  WebButton button(WidgetTester tester, String label) =>
      tester.widget<WebButton>(find.widgetWithText(WebButton, label));
  for (final dark in [false, true]) {
    testWidgets('terms requires acceptance $dark', (tester) async {
      var completed = 0;
      await pump(
        tester,
        OnboardingConsentStep(onCompleted: () => completed++),
        dark: dark,
      );
      expect(find.bySemanticsLabel('Setup steps'), findsOneWidget);
      expect(find.text('Terms and Privacy'), findsOneWidget);
      expect(button(tester, 'Continue').onPressed, isNull);
      final termsBox = find.byKey(
        const ValueKey(
          'I agree to the Terms of Service and Privacy Policy',
        ),
      );
      expect(tester.getSize(termsBox), const Size(24, 24));
      expect(find.byType(Divider), findsOneWidget);
      final box = tester.widget<TextButton>(termsBox);
      final shape = box.style!.shape!.resolve({})! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(7));
      await tester.tap(
        find.byKey(
          const ValueKey(
            'I agree to the Terms of Service and Privacy Policy',
          ),
        ),
      );
      await tester.pump();
      expect(button(tester, 'Continue').onPressed, isNotNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(completed, 1);
      expect(tester.takeException(), isNull);
    });
    testWidgets('name and custom name $dark', (tester) async {
      await pump(tester, OnboardingNameStep(onCompleted: () {}), dark: dark);
      expect(find.text('NAME'), findsOneWidget);
      expect(button(tester, 'Done').onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'Aedwon');
      await tester.pump();
      expect(button(tester, 'Done').onPressed, isNotNull);
      await pump(tester, const CustomTrackNameStep(), dark: dark);
      expect(find.text('EXAM NAME'), findsOneWidget);
      expect(find.text("Give it a name you'll recognize."), findsOneWidget);
      expect(button(tester, 'Continue').onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'Bar Exam');
      await tester.pump();
      expect(button(tester, 'Continue').onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });
    testWidgets('custom subject grid $dark', (tester) async {
      await pump(
        tester,
        const CustomTrackSubjectsStep(name: 'Bar Exam'),
        dark: dark,
      );
      expect(find.text('What does it cover?'), findsOneWidget);
      expect(button(tester, 'Continue').onPressed, isNull);
      final boxes = find.byType(CheckboxListTile);
      expect(boxes, findsNWidgets(2));
      expect(
        tester.getTopLeft(boxes.first).dy,
        tester.getTopLeft(boxes.last).dy,
      );
      await tester.tap(find.text('Mathematics'));
      await tester.pump();
      expect(button(tester, 'Continue').onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });
    testWidgets('picker selection stays CSE only $dark', (tester) async {
      var picked = 0;
      await pump(
        tester,
        ExamPickerScreen(
          mode: ExamPickerMode.onboarding,
          cseOnly: true,
          onPicked: (_) => picked++,
        ),
        dark: dark,
      );
      expect(find.text('CIVIL SERVICE'), findsOneWidget);
      expect(find.text('Search exams'), findsOneWidget);
      expect(button(tester, 'Continue').onPressed, isNull);
      await tester.tap(find.byKey(const ValueKey('exam-exam_cse_pro')));
      await tester.pump();
      expect(button(tester, 'Continue').onPressed, isNotNull);
      expect(
        find.text('CSE Professional · Civil Service Commission'),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked, 1);
      expect(tester.takeException(), isNull);
    });
    for (final state in ['loading', 'error', 'empty']) {
      testWidgets('picker $state $dark', (tester) async {
        final controller = StreamController<List<ExamCatalogEntry>>();
        addTearDown(controller.close);
        await pump(
          tester,
          ExamPickerScreen(mode: ExamPickerMode.onboarding, onPicked: (_) {}),
          dark: dark,
          catalog: controller.stream,
        );
        if (state == 'error') controller.addError(StateError('offline'));
        if (state == 'empty') controller.add([]);
        await tester.pump();
        await tester.pump();
        expect(find.text('Which exam are you taking?'), findsOneWidget);
        if (state == 'error') {
          expect(find.text('Could not load exams.'), findsOneWidget);
          expect(find.text('Retry'), findsOneWidget);
        }
        if (state == 'empty') {
          expect(find.text('Set Up My Own Exam'), findsOneWidget);
          expect(find.text('Continue'), findsNothing);
        }
        if (state != 'empty') {
          expect(button(tester, 'Continue').onPressed, isNull);
        }
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('known date can be confirmed or changed $dark', (tester) async {
      final entry = ExamCatalogEntry(
        id: cse.id,
        name: cse.name,
        shortName: cse.shortName,
        priceTier: cse.priceTier,
        group: cse.group,
        comingSoon: false,
        hasContent: true,
        publishedSittings: [
          PublishedExamSitting(
            firstDay: DateTime(2026, 11, 11),
            lastDay: DateTime(2026, 11, 11),
            sourceUrl: 'https://csc.gov.ph',
          ),
        ],
      );
      await pump(
        tester,
        OnboardingExamDateStep(
          now: DateTime(2026, 10, 3),
          onCompleted: () {},
        ),
        dark: dark,
        catalog: Stream.value([entry]),
      );
      expect(find.text('Wednesday, November 11, 2026'), findsOneWidget);
      expect(find.text('Is this your exam day?'), findsOneWidget);
      expect(button(tester, "That's Right").onPressed, isNotNull);
      await tester.tap(find.text('Different Date'));
      await tester.pump();
      expect(button(tester, 'Continue').onPressed, isNull);
      expect(
        find.text(
          'Pick a month first.\nThen add the day here if you know it.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('restored progress uses Enter $dark', (tester) async {
      var continued = 0;
      await pump(
        tester,
        StepsScreen(
          title: 'Restoring your progress',
          subtitle: 'Signed in as student@example.com',
          steps: const [
            WorkStep(label: 'Your answers', state: WorkStepState.done),
            WorkStep(
              label: 'Lessons, bookmarks and flags',
              state: WorkStepState.done,
            ),
            WorkStep(
              label: 'Your plan',
              state: WorkStepState.done,
              detail: 'Rebuilt from your progress',
            ),
          ],
          buttonLabel: 'Continue',
          onContinue: () => continued++,
        ),
        dark: dark,
      );
      expect(find.text('Enter'), findsOneWidget);
      expect(find.text('Everything is back.'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('Restoring your progress'),
          matching: find.byType(WebCard),
        ),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(continued, 1);
    });
    testWidgets('date pick month day year and today $dark', (tester) async {
      await pump(
        tester,
        OnboardingExamDateStep(
          now: DateTime(2026, 10, 3),
          onCompleted: () {},
        ),
        dark: dark,
      );
      expect(button(tester, 'Continue').onPressed, isNull);
      expect(
        find.text(
          'Pick a month first.\nThen add the day here if you know it.',
        ),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('calendar-status'))).height,
        48,
      );
      final emptyPanel = find.ancestor(
        of: find.text(
          'Pick a month first.\nThen add the day here if you know it.',
        ),
        matching: find.byType(WebCard),
      );
      expect(tester.getSize(emptyPanel).height, greaterThanOrEqualTo(360));
      await tester.tap(find.bySemanticsLabel('October 2026'));
      await tester.pump();
      expect(button(tester, 'Continue').onPressed, isNotNull);
      expect(
        find.text("No day yet? We'll plan from today and ask later."),
        findsOneWidget,
      );
      expect(find.text('Today'), findsOneWidget);
      await tester.tap(find.text('3'));
      await tester.pump();
      expect(find.text('Saturday, October 3'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('January 2027'));
      await tester.pump();
      expect(find.text('Saturday, October 3'), findsNothing);
      expect(find.text('January 2027'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    for (final state in ['none', 'selected', 'late', 'soon']) {
      testWidgets('study days $state $dark', (tester) async {
        await pump(
          tester,
          OnboardingStudyDaysStep(
            now: DateTime(2026, 10, 3),
            onCompleted: () {},
          ),
          dark: dark,
          date: state == 'late' || state == 'soon'
              ? ExamDate.onDay(DateTime(2026, 10, 5))
              : null,
        );
        expect(find.text('Which days will you study?'), findsOneWidget);
        expect(find.text('Mon'), findsOneWidget);
        final status = find.byKey(const ValueKey('study-days-status'));
        expect(tester.getSize(status).width, 640);
        expect(tester.getSize(status).height, 96);
        final continueY =
            tester.getTopLeft(find.widgetWithText(WebButton, 'Continue')).dy;
        expect(button(tester, 'Continue').onPressed, isNull);
        if (state == 'none') {
          expect(
            find.text('Pick at least one day to continue.'),
            findsOneWidget,
          );
        }
        if (state == 'selected' || state == 'soon') {
          await tester.tap(find.text('Every Day'));
          await tester.pump();
          expect(button(tester, 'Continue').onPressed, isNotNull);
          if (state == 'soon') {
            expect(
              find.text(
                "Your exam is in 2 days. We'll focus on what matters most.",
              ),
              findsOneWidget,
            );
          }
        }
        if (state == 'late') {
          await tester.tap(find.byKey(const ValueKey('study-day-1')));
          await tester.pump();
          expect(
            find.text('None of these fall before your exam'),
            findsOneWidget,
          );
          expect(button(tester, 'Continue').onPressed, isNull);
        }
        expect(tester.getSize(status).height, 96);
        expect(
          tester.getTopLeft(find.widgetWithText(WebButton, 'Continue')).dy,
          continueY,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
