import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/first_run/application/first_run_data.dart';
import 'package:pantas/features/first_run/presentation/first_run_page.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/pump_app.dart';

Map<String, Object?> _text(String text, {String style = 'normal'}) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'_type': 'span', 'text': text, 'marks': <String>[]},
      ],
    };

Question _q(
  String id,
  String stem,
  List<(String, bool)> choices,
  String explanation,
) =>
    Question(
      id: id,
      version: 1,
      examIds: const ['exam_upcat'],
      topicId: 't1',
      language: 'en',
      stem: stem,
      explanation: explanation,
      choices: [
        for (var i = 0; i < choices.length; i++)
          Choice(
            id: '$id-c$i',
            label: 'ABCD'[i],
            text: choices[i].$1,
            isCorrect: choices[i].$2,
          ),
      ],
    );

/// The run's content as fixtures: Q1 and Q3 right answer is the second
/// choice, Q2's right answer is the first.
final FirstRunData fixtureData = FirstRunData(
  lesson: Lesson(
    id: 'l1',
    topicId: 't1',
    title: 'Fractions, Decimals, and Percentages',
    summary: '',
    estimatedMinutes: 10,
    bodyJson: [
      _text('Core Concept', style: 'h2'),
      _text('Fractions, decimals, and percentages are three ways.'),
      _text('Examples', style: 'h2'),
      _text('#1: Basic Conversion', style: 'h3'),
      _text('Express 0.125 as a fraction.'),
      _text('Solution:'),
      _text('Divide by 125.'),
      _text('#2: Second example', style: 'h3'),
      _text('Never shown.'),
    ],
  ),
  subjectName: 'Mathematics',
  topicName: 'Arithmetic & Number Sense',
  questions: [
    _q('q1', 'What is 3/8 expressed as a percentage?',
        [('3.75%', false), ('37.5%', true), ('375%', false)], 'Divide 3 by 8.'),
    _q('q2', 'A wholesaler gives a 15% discount. What fraction is paid?',
        [('17/20', true), ('3/20', false), ('3/2', false)], 'Pay 85%.'),
    _q('q3', 'Express 0.25 as a fraction.',
        [('1/5', false), ('1/4', true), ('2/5', false)], 'Quarter.'),
  ],
);

class FirstRunRig {
  FirstRunRig(this.db, this.router);

  final AppDatabase db;
  final GoRouter router;

  String get location => router.routerDelegate.currentConfiguration.uri.path;

  /// The stored run, or null when none is open.
  Future<String?> stored(WidgetTester tester) =>
      tester.runAsync<String?>(() async {
        final row = await (db.select(db.devicePrefs)
              ..where((p) => p.key.equals('first_run_open_v1')))
            .getSingleOrNull();
        final value = row?.value;
        return value == null || value.isEmpty ? null : value;
      });
}

/// Pumps the run at [width] with the run already open (unless [open] is
/// false). [extra] overrides providers, for example a failing data load.
Future<FirstRunRig> pumpFirstRun(
  WidgetTester tester, {
  double width = 390,
  bool open = true,
  String? progressJson,
  List<Override> extra = const [],
  bool disableAnimations = true,
}) async {
  tester.view
    ..physicalSize = Size(width, width >= 1024 ? 900 : 844)
    ..devicePixelRatio = 1;
  debugWebPlatformOverride = width >= 1024;
  addTearDown(() {
    tester.view.reset();
    debugWebPlatformOverride = null;
  });
  final db = inMemoryDatabase();
  addTearDown(db.close);
  if (open) {
    await tester.runAsync(
      () => db.into(db.devicePrefs).insert(
            DevicePrefsCompanion.insert(
              key: 'first_run_open_v1',
              value: progressJson ??
                  '{"uid":"u1","examId":"exam_upcat","step":"intro",'
                      '"picks":{},"checked":[]}',
            ),
          ),
    );
  }
  final router = GoRouter(
    initialLocation: '/try',
    routes: [
      GoRoute(
        path: '/try',
        builder: (context, state) => const FirstRunPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const Text('HOME')),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
        authStateProvider.overrideWith(
          (ref) => Stream.value(
            const AuthState.signedIn(
              user: AuthUser(uid: 'u1', email: '', displayName: ''),
            ),
          ),
        ),
        activeExamFocusProvider.overrideWith(
          (ref) async => ActiveExamFocus.selected(buildExam(id: 'exam_upcat')),
        ),
        firstRunDataProvider.overrideWith((ref, examId) async => fixtureData),
        firstRunReadDwellProvider.overrideWithValue(
          const Duration(milliseconds: 50),
        ),
        ...extra,
      ],
      child: MediaQuery(
        data: MediaQueryData(
          size: Size(width, width >= 1024 ? 900 : 844),
          disableAnimations: disableAnimations,
        ),
        child: MaterialApp.router(
          theme: buildLightTheme(web: width >= 1024),
          routerConfig: router,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return FirstRunRig(db, router);
}
