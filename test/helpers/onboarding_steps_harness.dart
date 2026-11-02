import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_consent_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_exam_date_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_guardian_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_study_days_step.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_name_step.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_subjects_step.dart';

import '../features/guardian/fake_guardian_gateway.dart';
import 'in_memory_database.dart';

/// Every framed onboarding step, by name.
const framedOnboardingSteps = [
  'age',
  'guardian',
  'consent',
  'picker',
  'dateUnknown',
  'dateKnown',
  'studyDays',
  'name',
  'customName',
  'customSubjects',
];

/// The real catalog, with Civil Service Professional given a sitting so the
/// "known date" step can show it.
List<ExamCatalogEntry> onboardingTestCatalog() {
  final raw = jsonDecode(File('content/exams/catalog.json').readAsStringSync())
      as List<dynamic>;
  return [
    for (final item in raw.cast<Map<String, dynamic>>())
      ExamCatalogEntry(
        id: item['id'] as String,
        name: item['name'] as String,
        shortName: item['shortName'] as String,
        priceTier: item['priceTier'] as String,
        group: item['group'] as String,
        comingSoon: item['comingSoon'] as bool,
        hasContent: item['id'] == 'exam_cse_pro',
        publishedSittings: item['id'] == 'exam_cse_pro'
            ? [
                PublishedExamSitting(
                  firstDay: DateTime(2027, 3, 14),
                  lastDay: DateTime(2027, 3, 14),
                  sourceUrl: 'https://example.test',
                ),
              ]
            : const [],
      ),
  ];
}

Future<void> loadGeist() async {
  final fonts = FontLoader('Geist');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
  }
  await fonts.load();
}

class _Host extends StatefulWidget {
  const _Host({required this.step, required this.token});
  final Widget step;
  final Object token;
  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  final OnboardingFrameController _controller = OnboardingFrameController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OnboardingFrame(
        controller: _controller,
        enabled: true,
        resetToken: widget.token,
        child: widget.step,
      );
}

/// Pumps one framed onboarding step inside the real onboarding frame.
/// [wide] is wide web at 1440 by 900, otherwise a phone at 390 by 844.
Future<void> pumpFramedStep(
  WidgetTester tester,
  String step, {
  required bool wide,
  bool dark = false,
  GlobalKey? boundary,
  void Function(String)? onPicked,
}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  debugWebPlatformOverride = wide ? true : null;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view.physicalSize =
      wide ? const Size(1440, 900) : const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final db = inMemoryDatabase();
  addTearDown(db.close);
  await AppPreferencesRepository(db).setSelectedExamId('exam_cse_pro');
  final catalog = onboardingTestCatalog();
  final widget = switch (step) {
    'age' => OnboardingAgeGateStep(
        currentYear: 2026,
        onAgeGatePassed: () {},
        onGuardianNeeded: () {},
        onBack: () {},
      ),
    'guardian' => OnboardingGuardianStep(onSent: () {}, onBack: () {}),
    'consent' => OnboardingConsentStep(onCompleted: () {}, onBack: () {}),
    'picker' => ExamPickerScreen(
        mode: ExamPickerMode.onboarding,
        cseOnly: true,
        onPicked: (id) => onPicked?.call(id),
        onBack: () {},
        onCustom: () {},
      ),
    'dateUnknown' => OnboardingExamDateStep(
        now: DateTime(2026, 10, 3),
        onCompleted: () {},
        onBack: () {},
      ),
    'dateKnown' => OnboardingExamDateStep(
        now: DateTime(2026, 10, 3),
        onCompleted: () {},
        onBack: () {},
      ),
    'studyDays' => OnboardingStudyDaysStep(
        now: DateTime(2026, 10, 3),
        onCompleted: () {},
        onBack: () {},
      ),
    'name' => OnboardingNameStep(onCompleted: () {}, onBack: () {}),
    'customName' => CustomTrackNameStep(
        onContinue: (_) {},
        onBack: () {},
      ),
    'customSubjects' => CustomTrackSubjectsStep(
        name: 'My exam',
        onCreated: (_) {},
        onCompleted: () {},
        onBack: () {},
      ),
    _ => throw ArgumentError(step),
  };
  // The date step shows the catalog's sitting only for an exam that has one.
  if (step == 'dateUnknown') {
    await AppPreferencesRepository(db).setSelectedExamId('exam_upcat');
  }
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        guardianGatewayProvider.overrideWithValue(FakeGuardianGateway()),
        examPickerCatalogProvider.overrideWith((ref) => Stream.value(catalog)),
        corpusSubjectsWithTopicsProvider.overrideWith(
          (ref) async => <String, Set<TopicId>>{
            'Mathematics': {'math'},
            'English': {'english'},
            'Science': {'science'},
            'Filipino': {'filipino'},
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark ? buildDarkTheme(web: wide) : buildLightTheme(web: wide),
        home: MediaQuery(
          data: MediaQueryData(
            size: tester.view.physicalSize,
            disableAnimations: true,
          ),
          child: RepaintBoundary(
            key: boundary,
            child: Scaffold(body: _Host(step: widget, token: step)),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}
