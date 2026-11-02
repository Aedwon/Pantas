import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_layout_theme.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_page.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';
import 'package:pantas/l10n/app_localizations.dart';

import 'api.dart';
import 'databases.dart';
import 'fixed_quiz_controller.dart';
import 'mock_topics.dart';

/// What to show in the center pane.
class ScreenSpec {
  const ScreenSpec({
    required this.kind,
    required this.itemId,
    required this.examId,
    required this.wide,
    required this.dark,
    this.state = 'question',
    this.choice,
    this.generation = 0,
  });

  final String kind;
  final String itemId;
  final String examId;

  /// `question`, `correct` or `wrong` for questions; `start` or `exam` for
  /// mock exams.
  final String state;

  /// For a wrong answer: the letter of the choice picked.
  final String? choice;
  final bool wide;
  final bool dark;
  final int generation;

  ({double width, double height}) get size =>
      wide ? (width: 1280, height: 800) : (width: 390, height: 844);

  /// A fresh screen for any change here, so no state carries between items.
  String get key =>
      '$kind|$itemId|$examId|$state|$choice|$wide|$dark|$generation';
}

/// Mounts one real screen the way the app mounts it, with test seams only:
/// the databases, an anonymous auth state and the quiz controller.
class ScreenHost extends StatefulWidget {
  const ScreenHost({
    required this.databases,
    required this.api,
    required this.spec,
    super.key,
  });

  final ReviewDatabases databases;
  final ContentPassApi api;
  final ScreenSpec spec;

  @override
  State<ScreenHost> createState() => _ScreenHostState();
}

class _ScreenHostState extends State<ScreenHost> {
  late final AppDatabase _app = widget.databases.newAppDatabase();
  late final Future<List<Override>> _overrides = _prepare();

  Future<List<Override>> _prepare() async {
    final spec = widget.spec;
    final db = widget.databases;
    await AppPreferencesRepository(_app).setSelectedExamId(spec.examId);
    final overrides = <Override>[
      contentDatabaseProvider.overrideWithValue(db.content),
      appDatabaseProvider.overrideWithValue(_app),
      authStateProvider.overrideWith(
        (ref) => Stream.value(const AuthState.anonymous(uid: 'content-pass')),
      ),
    ];
    if (spec.kind == 'question') {
      overrides.add(fixedQuizControllerOverride(await _running(db, spec)));
    }
    return overrides;
  }

  @override
  void dispose() {
    _app.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.spec.size;
    return FutureBuilder<List<Override>>(
      future: _overrides,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _Failure(snapshot.error!);
        }
        final overrides = snapshot.data;
        if (overrides == null) return const SizedBox.shrink();
        return SizedBox(
          width: size.width,
          height: size.height,
          child: ProviderScope(
            overrides: overrides,
            child: _ReviewApp(spec: widget.spec, api: widget.api),
          ),
        );
      },
    );
  }
}

class _ReviewApp extends StatefulWidget {
  const _ReviewApp({required this.spec, required this.api});

  final ScreenSpec spec;
  final ContentPassApi api;

  @override
  State<_ReviewApp> createState() => _ReviewAppState();
}

class _ReviewAppState extends State<_ReviewApp> {
  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    // The nested router must not change the address of the reviewer page.
    routerNeglect: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => _screen(widget.spec, widget.api),
      ),
      // Anything the screen navigates to lands on an empty page.
      GoRoute(
        path: '/:rest(.*)',
        builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
      ),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.spec.size;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: appLightTheme(),
      darkTheme: appDarkTheme(),
      themeMode: widget.spec.dark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
      builder: (context, child) => MediaQuery(
        // The nested app is laid out at the requested size, not the window's.
        data: MediaQuery.of(context).copyWith(
          size: Size(size.width, size.height),
          padding: EdgeInsets.zero,
          viewPadding: EdgeInsets.zero,
          viewInsets: EdgeInsets.zero,
        ),
        child: WebLayoutTheme(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

Widget _screen(ScreenSpec spec, ContentPassApi api) => switch (spec.kind) {
      'lesson' => LessonPage(lessonId: spec.itemId),
      'question' => QuizPage(
          examId: spec.examId,
          mode: QuizPageMode.today,
          // Shows the Pro wrong-choice note without a store entitlement.
          proIsActive: true,
        ),
      'mock' when spec.state == 'exam' => _MockExam(spec: spec),
      'mock' => _MockStart(spec: spec),
      'figure' => _FigureScreen(spec: spec, api: api),
      _ => Scaffold(body: Center(child: Text('Unknown kind ${spec.kind}'))),
    };

/// One real illustration in the app's own image block, at the reader's width.
class _FigureScreen extends StatelessWidget {
  const _FigureScreen({required this.spec, required this.api});

  final ScreenSpec spec;
  final ContentPassApi api;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FutureBuilder<Map<String, Object?>>(
        future: api.figure(spec.itemId),
        builder: (context, snapshot) {
          final block = snapshot.data;
          if (snapshot.hasError) return Text('${snapshot.error}');
          if (block == null) return const SizedBox.shrink();
          final wide = context.wideWeb;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? (spec.size.width - 672) / 2 : 24,
              vertical: 32,
            ),
            child: ContentRenderer(
              blocks: [
                {'_type': 'image', ...block},
              ],
              readerFigures: true,
            ),
          );
        },
      ),
    );
  }
}

/// The mock setup screen for the exam's real blueprint.
///
/// The count of questions the app would find is left out: the blueprint's
/// topics decide it, and a missing topic is reported by the Exam state.
class _MockStart extends ConsumerWidget {
  const _MockStart({required this.spec});

  final ScreenSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parsed = ref.watch(mockSetupParsedBlueprintProvider(spec.examId));
    if (parsed.hasError) return _Failure(parsed.error!);
    final blueprint = parsed.valueOrNull;
    if (blueprint == null) {
      return parsed.isLoading
          ? const SizedBox.shrink()
          : const _Failure('The app has no blueprint for this exam.');
    }
    return MockSetupPage(parsedBlueprint: blueprint, onStart: (_) {});
  }
}

/// The paper the server route would serve: each blueprint section's questions
/// in file order, tagged for the exam, up to the section's count.
final _examPaperProvider = FutureProvider.family<
    ({List<String> ids, Map<String, String> sectionOf}),
    String>((ref, examId) async {
  final blueprint =
      await ref.watch(mockSetupParsedBlueprintProvider(examId).future);
  if (blueprint == null) {
    throw StateError('The app has no blueprint for this exam.');
  }
  final content = ref.watch(contentRepositoryProvider);
  final ids = <String>[];
  final sectionOf = <String, String>{};
  for (final section in blueprint.sections) {
    final taken = <String>[];
    for (final topic in section.topicIds) {
      final questions = await content.questionsByTopic(
        seedTopicId(topic),
        examId: examId,
      );
      taken.addAll(questions.map((q) => q.id));
    }
    for (final id in taken.take(section.questionCount)) {
      ids.add(id);
      sectionOf[id] = section.name;
    }
  }
  if (ids.isEmpty) {
    throw StateError('No questions in the seed match the blueprint topics.');
  }
  return (ids: ids, sectionOf: sectionOf);
});

/// The mock exam screen, built as the server route builds it, on the first
/// question, with the blueprint's own time for the clock.
class _MockExam extends ConsumerWidget {
  const _MockExam({required this.spec});

  final ScreenSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parsed = ref.watch(mockSetupParsedBlueprintProvider(spec.examId));
    final paper = ref.watch(_examPaperProvider(spec.examId));
    final error = parsed.error ?? paper.error;
    if (error != null) return _Failure(error);
    final blueprint = parsed.valueOrNull;
    final data = paper.valueOrNull;
    if (blueprint == null || data == null) return const SizedBox.shrink();
    final limit = Duration(minutes: blueprint.blueprint.durationMinutes);
    final state = MockSessionInProgress(
      attemptId: 'content-pass',
      durationSeconds: limit.inSeconds,
      questionIds: data.ids,
      currentIndex: 0,
      elapsedSeconds: 0,
      answers: const {},
      flags: const {},
      strictMode: false,
    );
    return MockSessionPage(
      state: state,
      examTitle: switch (spec.examId) {
        'exam_cse_pro' => 'CSE Professional simulation',
        'exam_cse_sub' => 'CSE Subprofessional simulation',
        _ => 'Mock exam',
      },
      remainingInPart: limit,
      partLength: limit,
      partPosition: 1,
      partTotal: data.ids.length,
      canGoPrevious: false,
      canGoNext: data.ids.length > 1,
      onPrevious: () {},
      onNext: () {},
      onGoTo: (_) {},
      onAnswer: (_) {},
      onToggleFlag: () {},
      onPause: () {},
      oneBlock: true,
      questionSubjects: data.sectionOf,
      onSubmitExam: () {},
    );
  }
}

/// Builds the running quiz for a question screen.
///
/// The session holds the requested question first and a second real question
/// after it, so the reveal shows Next as it does in the middle of a quiz.
Future<QuizRunning> _running(ReviewDatabases db, ScreenSpec spec) async {
  final content = ContentRepository(db.content);
  final question = await content.questionById(spec.itemId);
  if (question == null) throw StateError('No question ${spec.itemId}');
  final other = (await content.questionsByTopic(question.topicId))
      .where((q) => q.id != question.id)
      .firstOrNull;
  final outcome = switch (spec.state) {
    'correct' => _outcome(question, question.correctChoice.id),
    'wrong' => _outcome(question, wrongChoice(question, spec.choice).id),
    _ => null,
  };
  final now = DateTime.now();
  final session = QuizSession(
    sessionId: 'content-pass',
    examId: spec.examId,
    questions: [question, if (other != null) other],
    currentIndex: 0,
    outcomes: [if (outcome != null) outcome],
    startedAt: now,
  );
  return QuizRunning(session: session, persisted: true, questionShownAt: now);
}

/// The wrong choice with [label], or the first wrong choice.
Choice wrongChoice(Question question, String? label) {
  final wrong = question.choices.where((c) => !c.isCorrect).toList();
  return wrong.firstWhere((c) => c.label == label, orElse: () => wrong.first);
}

AnswerOutcome _outcome(Question question, String chosen) => AnswerOutcome(
      questionId: question.id,
      questionVersion: question.version,
      chosenChoiceId: chosen,
      correctChoiceId: question.correctChoice.id,
      responseMs: 4000,
    );

/// A screen the real code could not draw, with the plain reason.
class _Failure extends StatelessWidget {
  const _Failure(this.error);

  final Object error;

  @override
  Widget build(BuildContext context) {
    final err = error;
    final reason = err is StateError ? err.message : '$err';
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Can't show this here",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(reason, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
