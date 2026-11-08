// Design system 4.0, Mock exam family: every mock screen at 390, 1100 and
// 1440 wide, light and dark, at text scale 1.0 and 2.0, with no layout
// overflow. Then the D170 phone layout: the same controls, with the same
// effects, as the wide layout.
import 'dart:convert';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_timer.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_page.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_preparation_page.dart';

import '../../../helpers/ds_matrix.dart';
import 'web_mock_layout_test.dart' as layout show blueprint, result;

/// The mock widths: a phone, the compact range and the full width.
final _cells = <DsCell>[
  for (final width in [390.0, 1100.0, 1440.0])
    for (final dark in [false, true])
      for (final scale in [1.0, 2.0]) DsCell(width, scale, dark: dark),
];

class _ContentRepo extends Mock implements ContentRepository {}

class _AttemptRepo extends Mock implements MockAttemptRepo {}

class _FlagsRepo extends Mock implements QuestionFlagsRepository {}

class _PrefsRepo extends Mock implements AppPreferencesRepository {}

const _passage = Passage(
  id: 'p',
  topicId: 't',
  title: 'A reading passage',
  body: 'The office reviews each request before it sends a reply.\n\n'
      'Every reply names the person who checked it.',
  language: 'en',
  wordCount: 20,
);

HydratedMockQuestion _hydrated({bool withPassage = false}) =>
    HydratedMockQuestion(
      const Question(
        id: 'q1',
        version: 1,
        examIds: [],
        topicId: 't',
        language: 'en',
        stem: 'Which statement follows from the information given?',
        explanation: 'Explanation.',
        choices: [
          Choice(
            id: 'a',
            label: 'A',
            text: 'The first answer.',
            isCorrect: true,
          ),
          Choice(
            id: 'b',
            label: 'B',
            text: 'The second answer.',
            isCorrect: false,
          ),
          Choice(
            id: 'c',
            label: 'C',
            text: 'The third answer.',
            isCorrect: false,
          ),
          Choice(
            id: 'd',
            label: 'D',
            text: 'The fourth answer.',
            isCorrect: false,
          ),
        ],
      ),
      withPassage ? _passage : null,
    );

/// Pumps [child] at [cell] with the web platform from 1024 and no scroll
/// wrapper, then lets the frame settle.
Future<void> _pump(
  WidgetTester tester,
  DsCell cell,
  Widget child, {
  List<Override> overrides = const [],
}) async {
  tester.view
    ..physicalSize = Size(cell.width, 900)
    ..devicePixelRatio = 1;
  addTearDown(() {
    tester.view.reset();
    debugWebPlatformOverride = null;
  });
  final web = cell.width >= 1024;
  debugWebPlatformOverride = web;
  final theme =
      cell.dark ? buildDarkTheme(web: web) : buildLightTheme(web: web);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: theme,
        builder: (context, home) => MediaQuery(
          data: MediaQueryData(
            size: Size(cell.width, 900),
            textScaler: TextScaler.linear(cell.scale),
            disableAnimations: true,
          ),
          child: home ?? const SizedBox(),
        ),
        home: child,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
}

void _matrix(
  String name,
  Widget Function(DsCell cell) build, {
  List<Override> Function(DsCell cell)? overrides,
  Future<void> Function(WidgetTester tester, DsCell cell)? check,
}) {
  for (final cell in _cells) {
    testWidgets('$name ($cell)', (tester) async {
      await tester.runAsync(loadDsFonts);
      await _pump(
        tester,
        cell,
        build(cell),
        overrides: overrides?.call(cell) ?? const [],
      );
      expect(tester.takeException(), isNull);
      if (check != null) await check(tester, cell);
    });
  }
}

MockSessionInProgress _state({
  int index = 4,
  Set<String> flags = const {},
  Map<String, MockAnswer> answers = const {},
  bool strict = false,
}) =>
    MockSessionInProgress(
      attemptId: 'a',
      durationSeconds: 5400,
      questionIds: [for (var i = 1; i <= 40; i++) 'q$i'],
      currentIndex: index,
      elapsedSeconds: 0,
      answers: answers,
      flags: flags,
      strictMode: strict,
    );

Widget _session({
  Duration remaining = const Duration(minutes: 29),
  bool oneBlock = false,
  bool strict = false,
  bool last = false,
  List<String>? log,
}) =>
    MockSessionPage(
      state: _state(
        index: last ? 39 : 4,
        strict: strict,
        flags: const {'q5'},
        answers: {'q1': const MockAnswer(selectedIndex: 1, atSec: 5)},
      ),
      remainingInPart: remaining,
      partLength: const Duration(minutes: 90),
      partPosition: last ? 40 : 5,
      partTotal: 40,
      partName: 'Numerical Ability',
      oneBlock: oneBlock,
      canGoPrevious: true,
      canGoNext: !last,
      onPrevious: () => log?.add('previous'),
      onNext: () => log?.add('next'),
      onAnswer: (i) => log?.add('answer-$i'),
      onToggleFlag: () => log?.add('flag'),
      onPause: () => log?.add('pause'),
      onSubmitExam: () => log?.add('submit'),
      onEndPartEarly: () => log?.add('end-part'),
      upcomingParts: oneBlock
          ? const []
          : const [
              MockUpcomingPart(number: 2, name: 'Science', count: 30),
            ],
    );

void main() {
  _matrix(
    'session screen',
    (cell) => _session(),
    overrides: (cell) => [
      hydratedMockQuestionProvider.overrideWith((ref, id) => _hydrated()),
    ],
  );
  _matrix(
    'session screen with a passage, last five minutes',
    (cell) => _session(remaining: const Duration(minutes: 4, seconds: 20)),
    overrides: (cell) => [
      hydratedMockQuestionProvider
          .overrideWith((ref, id) => _hydrated(withPassage: true)),
    ],
  );
  _matrix(
    'session screen, one block, strict',
    (cell) => _session(oneBlock: true, strict: true, last: true),
    overrides: (cell) => [
      hydratedMockQuestionProvider.overrideWith((ref, id) => _hydrated()),
    ],
  );
  _matrix(
    'setup screen',
    (cell) => MockSetupPage(
      parsedBlueprint: layout.blueprint,
      onStart: (_) {},
    ),
  );
  _matrix(
    'start preparation screen',
    (cell) => MockStartPreparationPage(
      parsedBlueprint: layout.blueprint,
      sample: const MockSample(
        expectedQuestionCount: 10,
        sections: [
          SampledMockSection(
            sectionId: 's',
            name: 'General Information',
            questionIds: ['q1', 'q2'],
          ),
        ],
      ),
      onStart: () {},
    ),
  );
  _matrix(
    'custom setup screen',
    (cell) => CustomMockSetupPage(
      data: const CustomMockSetupData(
        examId: 'exam_custom_1',
        subjects: [
          Subject(
            id: 'math',
            examId: 'exam_custom_1',
            name: 'Mathematics',
            ordering: 0,
          ),
          Subject(
            id: 'sci',
            examId: 'exam_custom_1',
            name: 'Science',
            ordering: 1,
          ),
        ],
        topicsBySubject: {},
        availableQuestions: 240,
      ),
      onSave: (CustomBlueprint blueprint) async {},
    ),
  );
  _matrix(
    'paused screen',
    (cell) => PausePage(
      partNames: const [
        'Language Proficiency',
        'Reading Comprehension',
        'Mathematics',
      ],
      currentPartIndex: 2,
      remaining: const Duration(minutes: 21, seconds: 47),
      partLength: const Duration(minutes: 75),
      answeredCount: 144,
      onResume: () {},
      onDiscard: () {},
    ),
  );
  _matrix(
    'between parts screen',
    (cell) => PartTransitionPage(
      partNames: const ['Language Proficiency', 'Mathematics', 'Science'],
      nextPartIndex: 1,
      endedEarly: false,
      answeredQuestions: [for (var i = 0; i < 40; i++) i != 7],
      onStartNext: () {},
    ),
  );
  _matrix(
    'results screen',
    (cell) => MockResultsPage(
      results: layout.result,
      examId: 'exam_upcat',
      proIsActive: false,
      reviewUntil: DateTime(2026, 10, 17),
      blueprintName: 'UPCAT simulation',
      dateFormatted: 'Saturday, Oct 3',
      disableAnimations: true,
      onReviewTap: () {},
      onDone: () {},
      onSeePro: () {},
    ),
  );

  group('review screen', () {
    late _ContentRepo content;
    late _AttemptRepo attempts;
    late _FlagsRepo flags;
    late _PrefsRepo prefs;
    final ids = List.generate(12, (i) => 'q_${i + 1}');

    setUp(() {
      content = _ContentRepo();
      attempts = _AttemptRepo();
      flags = _FlagsRepo();
      prefs = _PrefsRepo();
      final attempt = MockAttempt(
        id: 'attempt_1',
        userId: 'user_1',
        examId: 'cse_prof',
        blueprintId: 'bp_1',
        blueprintName: 'UPCAT Full',
        durationMinutes: 180,
        status: MockAttemptStatus.completed,
        strictMode: false,
        sampledQuestionsJson: jsonEncode([
          {'sectionId': 'sec_1', 'name': 'Section 1', 'questionIds': ids},
        ]),
        elapsedSeconds: 3600,
        accumulatedPausedSeconds: 0,
        pausedAtLastFlush: false,
        answersJson: '{"q_1":{"selectedIndex":1,"atSec":10}}',
        flagsJson: '["q_2"]',
        currentIndex: 0,
        startedAt: DateTime.utc(2026, 8),
        lastFlushedAt: DateTime.utc(2026, 8),
        updatedAt: DateTime.utc(2026, 8),
        scoreRaw: 1,
        scoreTotal: 12,
        submittedAt: DateTime.utc(2026, 8),
      );
      when(() => attempts.findById('attempt_1'))
          .thenAnswer((_) async => attempt);
      when(() => content.questionsByIds(any())).thenAnswer((call) async {
        final wanted =
            (call.positionalArguments.first as Iterable<String>).toSet();
        return {
          for (final id in ids)
            if (wanted.contains(id))
              id: Question(
                id: id,
                version: 1,
                examIds: const ['cse_prof'],
                topicId: 't_1',
                language: 'en',
                stem: 'Stem for $id',
                choices: const [
                  Choice(
                    id: 'c_a',
                    label: 'A',
                    text: 'Opt A',
                    isCorrect: false,
                  ),
                  Choice(id: 'c_b', label: 'B', text: 'Opt B', isCorrect: true),
                ],
                explanation: 'Explanation $id',
              ),
        };
      });
      when(() => content.topicById(any())).thenAnswer(
        (_) async => const Topic(
          id: 't_1',
          subjectId: 's_1',
          name: 'Mathematics',
          ordering: 1,
        ),
      );
      when(() => content.subjectById(any())).thenAnswer(
        (_) async => const Subject(
          id: 's_1',
          examId: 'cse_prof',
          name: 'Mathematics',
          ordering: 1,
        ),
      );
      when(() => flags.flaggedIds()).thenAnswer((_) async => <String>{});
      when(() => flags.isFlagged(any())).thenAnswer((_) async => false);
      when(() => prefs.deviceValue(any())).thenAnswer((_) async => null);
      when(() => prefs.setDeviceValue(any(), any())).thenAnswer((_) async {});
    });

    for (final cell in _cells) {
      testWidgets('review list ($cell)', (tester) async {
        await tester.runAsync(loadDsFonts);
        await _pump(
          tester,
          cell,
          const MockReviewPage(attemptId: 'attempt_1', proIsActive: false),
          overrides: [
            mockAttemptRepoProvider.overrideWithValue(attempts),
            contentRepositoryProvider.overrideWithValue(content),
            questionFlagsRepositoryProvider.overrideWithValue(flags),
            appPreferencesRepositoryProvider.overrideWithValue(prefs),
          ],
        );
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      });
    }
  });

  // D170: below 1024 the mock is built from the quiz's phone parts. Every
  // control exists at both widths and has the same effect.
  group('phone layout (D170) matches the wide layout', () {
    for (final width in [390.0, 1440.0]) {
      final cell = DsCell(width, 1, dark: false);
      final phone = width < 1024;

      Future<List<String>> open(
        WidgetTester tester, {
        bool oneBlock = false,
        bool last = false,
      }) async {
        await tester.runAsync(loadDsFonts);
        final log = <String>[];
        await _pump(
          tester,
          cell,
          _session(oneBlock: oneBlock, last: last, log: log),
          overrides: [
            hydratedMockQuestionProvider.overrideWith((ref, id) => _hydrated()),
          ],
        );
        return log;
      }

      testWidgets('answer, flag and navigate act the same at $width',
          (tester) async {
        final log = await open(tester);
        await tester.tap(find.text('The second answer.'));
        await tester.pump();
        await tester.tap(
          find.byKey(ValueKey(phone ? 'mock-flag' : 'web-mock-flag')),
        );
        await tester.pump();
        await tester.tap(find.byTooltip('Previous question'));
        await tester.pump();
        await tester.tap(find.byTooltip('Next question'));
        await tester.pump();
        expect(log, ['answer-1', 'flag', 'previous', 'next']);
      });

      testWidgets('the flag shows its state in its name at $width',
          (tester) async {
        final semantics = tester.ensureSemantics();
        await open(tester);
        final flag =
            find.byKey(ValueKey(phone ? 'mock-flag' : 'web-mock-flag'));
        expect(flag, findsOneWidget);
        expect(
          find.descendant(of: flag, matching: find.text('Flagged')),
          findsOneWidget,
        );
        expect(
          tester
              .getSemantics(flag)
              .getSemanticsData()
              .flagsCollection
              .isToggled,
          Tristate.isTrue,
        );
        semantics.dispose();
      });

      testWidgets('pause asks first, then acts the same at $width',
          (tester) async {
        final log = await open(tester);
        await tester.tap(
          find.byKey(const ValueKey('mock-pause')).evaluate().isEmpty
              ? find.text('Pause')
              : find.byKey(const ValueKey('mock-pause')),
        );
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text("Real exams don't pause."), findsOneWidget);
        await tester.tap(find.text('Pause').last);
        await tester.pump(const Duration(milliseconds: 600));
        expect(log, ['pause']);
      });

      testWidgets('submit asks first, then acts the same at $width',
          (tester) async {
        final log = await open(tester, oneBlock: true, last: true);
        await tester.tap(find.byTooltip('Submit the exam'));
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('Submit the exam?'), findsOneWidget);
        await tester.tap(find.text('Submit').last);
        await tester.pump(const Duration(milliseconds: 600));
        expect(log, ['submit']);
      });

      testWidgets('the timer shows the same time and a name at $width',
          (tester) async {
        final semantics = tester.ensureSemantics();
        await open(tester);
        expect(find.byType(PantasTimer), findsOneWidget);
        expect(find.text('29:00'), findsOneWidget);
        // 29 minutes left of a 90 minute part.
        expect(
          tester.widget<PantasTimer>(find.byType(PantasTimer)).fractionLeft,
          closeTo(29 / 90, 1e-9),
        );
        expect(
          find.bySemanticsLabel('Time left'),
          findsOneWidget,
          reason: 'the clock keeps its name, and it is not a live region',
        );
        semantics.dispose();
      });

      testWidgets('under five minutes the clock takes the warning at $width',
          (tester) async {
        await tester.runAsync(loadDsFonts);
        await _pump(
          tester,
          cell,
          _session(remaining: const Duration(minutes: 4, seconds: 30)),
          overrides: [
            hydratedMockQuestionProvider.overrideWith((ref, id) => _hydrated()),
          ],
        );
        expect(find.text('5 min left'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('a long passage never scrolls the Flag off the phone screen',
        (tester) async {
      await tester.runAsync(loadDsFonts);
      final log = <String>[];
      final longPassage = HydratedMockQuestion(
        _hydrated().question,
        Passage(
          id: 'p',
          topicId: 't',
          title: 'A long passage',
          body: List.filled(
            60,
            'The office reviews each request before it sends a reply.',
          ).join('\n\n'),
          language: 'en',
          wordCount: 600,
        ),
      );
      await _pump(
        tester,
        const DsCell(390, 1, dark: false),
        _session(log: log),
        overrides: [
          hydratedMockQuestionProvider.overrideWith((ref, id) => longPassage),
        ],
      );
      final list = find.byType(ListView);
      tester
          .state<ScrollableState>(
            find.descendant(of: list, matching: find.byType(Scrollable)).first,
          )
          .position
          .jumpTo(1000000000);
      await tester.pump();
      final flag = find.byKey(const ValueKey('mock-flag'));
      final box = tester.getRect(flag);
      expect(box.top, greaterThanOrEqualTo(0));
      expect(box.bottom, lessThanOrEqualTo(900));
      await tester.tap(flag);
      await tester.pump();
      expect(log, ['flag']);
    });

    testWidgets(
        'the five-minute warning is announced once, by the proctor '
        'call', (tester) async {
      await tester.runAsync(loadDsFonts);
      final spoken = <String>[];
      tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility,
        (message) async {
          final map = message as Map<Object?, Object?>;
          if (map['type'] == 'announce') {
            spoken.add(
              (map['data']! as Map<Object?, Object?>)['message']! as String,
            );
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility,
          null,
        ),
      );
      final semantics = tester.ensureSemantics();
      final overrides = [
        hydratedMockQuestionProvider.overrideWith((ref, id) => _hydrated()),
      ];
      const cell = DsCell(390, 1, dark: false);
      await _pump(
        tester,
        cell,
        _session(remaining: const Duration(minutes: 5, seconds: 1)),
        overrides: overrides,
      );
      await _pump(
        tester,
        cell,
        _session(remaining: const Duration(minutes: 4, seconds: 59)),
        overrides: overrides,
      );
      await tester.pump();
      expect(find.text('5 min left'), findsOneWidget);
      expect(
        find.bySemanticsLabel('5 minutes left in this subject.'),
        findsOneWidget,
      );
      expect(spoken, isNot(contains('Five minutes left.')));
      semantics.dispose();
    });

    testWidgets('the phone header is 44 high at default text', (tester) async {
      await tester.runAsync(loadDsFonts);
      await _pump(
        tester,
        const DsCell(390, 1, dark: false),
        _session(),
        overrides: [
          hydratedMockQuestionProvider.overrideWith((ref, id) => _hydrated()),
        ],
      );
      final header = tester.getSize(find.byKey(const ValueKey('mock-header')));
      expect(header.height, greaterThanOrEqualTo(44));
      expect(header.height, lessThan(64));
    });
  });
}
