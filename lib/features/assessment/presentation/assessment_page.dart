import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/remote/content_limit.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/metrics/overall_accuracy.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/new_design/passage_card.dart'
    as passage_ui;
import 'package:pantas/core/ui/components/new_design/question_card.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/report_form.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/assessment/application/assessment_leave_guard.dart';
import 'package:pantas/features/assessment/application/assessment_result_providers.dart';
import 'package:pantas/features/assessment/domain/models/assessment_session.dart';
import 'package:pantas/features/assessment/domain/use_cases/complete_assessment.dart';
import 'package:pantas/features/assessment/domain/use_cases/start_assessment.dart';
import 'package:pantas/features/assessment/presentation/assessment_results_page.dart';
import 'package:pantas/features/assessment/presentation/web_assessment_layout.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';

final _startAssessmentProvider = Provider<StartAssessment>(
  (ref) => StartAssessment(
    AssessmentQuestionSelector(
      ref.watch(contentRepositoryProvider),
      ref.watch(reviewStateRepositoryProvider),
    ),
  ),
);

/// AS_Question draws "SUBJECT · TOPIC". The card upper-cases it.
final _questionHeaderProvider = FutureProvider.autoDispose
    .family<String, (String, String)>((ref, key) async {
  final (examId, topicId) = key;
  final content = ref.watch(contentRepositoryProvider);
  final topic = await content.topicById(topicId);
  if (topic == null) return '';
  final subject = await content.subjectById(topic.subjectId);
  final name = examSubjectName(examId, topic.name, subject?.name);
  return name == null ? topic.name : '$name · ${topic.name}';
});

final _completeAssessmentProvider = Provider<CompleteAssessment>(
  (ref) => CompleteAssessment(
    assessmentRepo: AssessmentRepository(ref.watch(appDatabaseProvider)),
    reviewRepo: ref.watch(reviewStateRepositoryProvider),
    scheduler: const FsrsScheduler(),
    contentRepo: ref.watch(contentRepositoryProvider),
    attemptsRepo: ref.watch(attemptsRepositoryProvider),
  ),
);

final _assessmentExamNameProvider =
    FutureProvider.autoDispose.family<String, ExamId>((ref, id) async {
  final exams = await ref.watch(contentRepositoryProvider).listExams();
  return exams.where((exam) => exam.id == id).firstOrNull?.shortName ??
      'Assessment';
});

class AssessmentPage extends ConsumerStatefulWidget {
  const AssessmentPage({required this.examId, super.key});
  final ExamId examId;
  @override
  ConsumerState<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends ConsumerState<AssessmentPage> {
  AssessmentSession? _session;
  int _index = 0;
  String? _picked;
  bool _failed = false;
  bool _unavailable = false;
  bool _completing = false;
  // Set when saving takes long enough that Next should say so.
  bool _savingSlow = false;
  Timer? _slowTimer;
  bool _advancing = false;
  bool _leaveOpen = false;
  // Set just before this page itself navigates away (leave confirmed, results,
  // already done), so the route's `onExit` lets that through without asking.
  bool _exiting = false;
  AssessmentLeaveGuard? _guard;
  int _generation = 0;
  Future<bool> Function()? _owner;
  final _questionClock = Stopwatch();
  final Set<String> _reported = {};
  @override
  void initState() {
    super.initState();
    final guard = ref.read(assessmentLeaveGuardProvider)..running = _allowLeave;
    _guard = guard;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  /// Browser Back reaches the route's `onExit` instead of this page's pop
  /// handling. It shows the same dialog as the X and keeps the answers. Leaving
  /// the page itself is always allowed, and so is leaving before any question
  /// is on screen.
  Future<bool> _allowLeave() async {
    if (!mounted || _exiting || _session == null) return true;
    // Saving the answers: the X is off now, and so is Back.
    if (_completing) return false;
    unawaited(_leave());
    return false;
  }

  @override
  void dispose() {
    _guard?.detach(_allowLeave);
    _generation++;
    _slowTimer?.cancel();
    _questionClock.stop();
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    final db = ref.read(appDatabaseProvider);
    final telemetry = ref.read(telemetryProvider);
    final prefs = ref.read(appPreferencesRepositoryProvider);
    setState(() {
      _session = null;
      _failed = false;
      _unavailable = false;
    });
    try {
      await ref.read(authStateProvider.future);
      if (!mounted || generation != _generation) return;
      final preparer = ref.read(todayQuizPreparerProvider);
      final lifetime = preparer.accountLifetimeToken;
      bool current() =>
          mounted &&
          generation == _generation &&
          identical(db, ref.read(appDatabaseProvider)) &&
          identical(preparer, ref.read(todayQuizPreparerProvider)) &&
          lifetime == preparer.accountLifetimeToken;
      final contexts = SyncActiveContextStore(db);
      final snapshot = await contexts.readSnapshot();
      final selected = await prefs.selectedExamId();
      _owner = () async {
        if (!current()) return false;
        final next = await contexts.readSnapshot();
        final exam = await prefs.selectedExamId();
        return current() && next?.token == snapshot?.token && exam == selected;
      };
      if (!await _owner!()) throw StateError('Assessment ownership changed');
      final completed =
          await ref.read(assessmentCompletedProvider(widget.examId).future);
      if (!await _owner!()) throw StateError('Assessment ownership changed');
      if (completed && mounted) {
        _exiting = true;
        context.go('/home');
        return;
      }
      final topics = await ref.read(scopedTopicsProvider(widget.examId).future);
      final session = await ref
          .read(_startAssessmentProvider)
          .call(widget.examId, topics: topics);
      if (!await _owner!()) throw StateError('Assessment ownership changed');
      setState(() {
        _session = session;
        _index = 0;
        _picked = null;
      });
      _questionClock
        ..reset()
        ..start();
    } catch (error, stack) {
      // An exam with no questions is a state, not a fault.
      if (error is! NoAssessmentQuestionsError) {
        unawaited(telemetry.recordError(error, stack));
      }
      if (mounted && generation == _generation) {
        setState(() {
          _unavailable = error is NoAssessmentQuestionsError;
          _failed = !_unavailable;
        });
      }
    }
  }

  Future<bool> _checkOwner() async {
    final valid = await _owner!();
    if (!valid && mounted) {
      setState(() {
        _session = null;
        _picked = null;
        _failed = true;
      });
    }
    return valid;
  }

  Future<void> _next() async {
    // Capture what this tap answers before awaiting, and ignore a second tap
    // while the owner check is pending, so no answer is recorded twice and no
    // question is skipped.
    final session = _session;
    final picked = _picked;
    final index = _index;
    if (session == null || picked == null || _completing || _advancing) return;
    _advancing = true;
    try {
      if (!await _checkOwner()) return;
      if (!mounted || !identical(session, _session)) return;
      final updated = session.copyWithAnswer(
        questionId: session.questions[index].question.id,
        chosenChoiceId: picked,
        elapsedMs: _questionClock.elapsedMilliseconds,
      );
      _questionClock
        ..reset()
        ..start();
      if (index + 1 < session.questions.length) {
        setState(() {
          _session = updated;
          _index = index + 1;
          _picked = null;
        });
        // The ring on the answer just given must not carry to the same
        // place on the next question (the quiz does the same).
        releaseChoiceFocus(this);
        return;
      }
      setState(() => _session = updated);
      await _complete();
    } finally {
      _advancing = false;
    }
  }

  Future<void> _complete() async {
    if (_completing || _session == null) return;
    final telemetry = ref.read(telemetryProvider);
    _questionClock.stop();
    setState(() {
      _completing = true;
      _failed = false;
    });
    // The question stays on screen while the answers are saved. Next shows
    // that it is working only if saving takes noticeably long.
    _slowTimer?.cancel();
    _slowTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted && _completing) setState(() => _savingSlow = true);
    });
    var done = false;
    try {
      if (!await _checkOwner()) return;
      final publish =
          await ref.read(studySettingsCaptureProvider)(examId: widget.examId);
      await publish.apply(
        () => ref
            .read(_completeAssessmentProvider)
            .call(session: _session!, now: DateTime.now(), canPersist: _owner),
      );
      if (!await _checkOwner()) return;
      ref
        ..invalidate(assessmentResultProvider(widget.examId))
        ..invalidate(assessmentCompletedProvider(widget.examId))
        ..invalidate(countForExamProvider(widget.examId))
        ..invalidate(roadmapTodayProvider(widget.examId));
      ref.read(todayQuizPreparerProvider).invalidateAll();
      ref.read(quizSessionPanelRevisionProvider.notifier).publishCompletion();
      // Have the results ready before leaving, so they open in one step.
      await holdAssessmentResults(ref, widget.examId);
      if (mounted) {
        // Stay in the saving state: this page is replaced, not shown again.
        done = true;
        _exiting = true;
        context.pushReplacement('/assessment/${widget.examId}/results');
      }
    } on AssessmentAlreadyCompleted {
      if (await _checkOwner() && mounted) {
        _exiting = true;
        context.go('/home');
      }
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _failed = true);
    } finally {
      _slowTimer?.cancel();
      if (mounted && !done) {
        setState(() {
          _completing = false;
          _savingSlow = false;
        });
      }
    }
  }

  Future<void> _leave() async {
    if (_leaveOpen || _completing) return;
    _leaveOpen = true;
    final leave = await showPantasDialog<bool>(
      context: context,
      // An alertdialog does not close on a scrim click.
      barrierDismissible: false,
      builder: (context) => WebAssessmentLeaveDialog(
        onKeepGoing: () => Navigator.of(context).pop(false),
        onLeave: () => Navigator.of(context).pop(true),
      ),
    );
    _leaveOpen = false;
    if ((leave ?? false) && mounted) {
      _generation++;
      _exiting = true;
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    firstScreenReady(
      context,
      ref,
      ready: _unavailable || _failed || session != null,
    );
    final question = session?.questions[_index].question;
    final header = question == null
        ? null
        : ref
            .watch(_questionHeaderProvider((widget.examId, question.topicId)))
            .valueOrNull;
    final passageState = question?.passageId == null
        ? null
        : ref.watch(passageByIdProvider(question!.passageId!));
    final passage = passageState?.valueOrNull;
    final limitReached = ref.watch(contentLimitReachedProvider);
    Widget body;
    if (limitReached && (_unavailable || _failed) && session == null) {
      // The server refused for the daily limit, so the exam is not empty.
      body = const StateView(message: contentLimitMessage);
    } else if (_unavailable) {
      body = StateView(
        message: "Assessment isn't ready yet",
        detail: "We're still adding questions for this exam. "
            'You can use the rest of Pantas for now.',
        actionLabel: 'Back to Quiz',
        onRetry: () => context.go('/quiz'),
      );
    } else if (_failed) {
      body = errorFor('assessment', session == null ? _load : _complete);
    } else if (session == null) {
      body = const SkeletonQuestionPage();
    } else if (passageState != null && !passageState.hasValue) {
      body = passageState.hasError
          ? errorFor(
              'passage',
              () => ref.invalidate(passageByIdProvider(question!.passageId!)),
            )
          : const SkeletonQuestionPage();
    } else {
      body = SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s16,
          PantasSpace.s20,
          PantasSpace.s16,
          PantasLayout.reserveBarPhone,
        ),
        child: Column(
          children: [
            QuestionCard(
              subject: header ?? '',
              stem: question!.stem,
              figure: question.figureSpecJson == null
                  ? null
                  : QuestionFigure(specJson: question.figureSpecJson),
              passage: passage == null
                  ? null
                  : passage_ui.PassageCard(
                      title: passage.title,
                      text: passage.body,
                    ),
              choices: [
                for (final choice in question.choices)
                  ChoiceRow(
                    letter: choice.label,
                    text: choice.text,
                    state: _picked == choice.id
                        ? ChoiceRowState.picked
                        : ChoiceRowState.plain,
                    onTap: () => setState(() => _picked = choice.id),
                  ),
              ],
            ),
          ],
        ),
      );
    }
    if (context.wideWeb) {
      return PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _leave();
        },
        child: Scaffold(
          backgroundColor: context.webTokens.colors.background,
          body: SafeArea(
            child: session != null &&
                    !_failed &&
                    !_unavailable &&
                    (passageState == null || passageState.hasValue)
                ? WebAssessmentLayout(
                    question: question!,
                    subject: header ?? '',
                    examName: ref
                            .watch(_assessmentExamNameProvider(widget.examId))
                            .valueOrNull ??
                        'Assessment',
                    index: _index,
                    total: session.questions.length,
                    chosenId: _picked,
                    passage: passage,
                    saving: _savingSlow,
                    onPick: (id) => setState(() => _picked = id),
                    onNext: _next,
                    onLeave: _leave,
                    report: WebTopBarButton(
                      tooltip: 'Report',
                      icon: IconTheme(
                        data: IconThemeData(
                          color: _reported.contains(question.id)
                              ? context.webTokens.colors.accent
                              : context.webTokens.colors.textSecondary,
                          size: PantasSpace.s20,
                        ),
                        child: PantasIcons.report,
                      ),
                      onPressed: () async {
                        final sent = await openQuestionReport(
                          context,
                          question.id,
                          queue: ReportQueue(ref.read(appDatabaseProvider)),
                        );
                        if ((sent ?? false) && mounted) {
                          setState(() => _reported.add(question.id));
                        }
                      },
                    ),
                  )
                : Column(
                    children: [
                      WebTopBar(
                        leading: PantasIconButton(
                          tooltip: 'Leave assessment',
                          onPressed: _completing ? null : _leave,
                          glyph: PantasIcons.close,
                        ),
                      ),
                      Expanded(child: body),
                    ],
                  ),
          ),
        ),
      );
    }
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // AS_Question: the board's top row starts 6 px down.
                  SizedBox(
                    height: PantasSize.btnLg,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        PantasSpace.s8,
                        PantasSpace.s6,
                        PantasSpace.s8,
                        PantasSpace.s0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PantasIconButton(
                            tooltip: 'Leave assessment',
                            onPressed: _completing ? null : _leave,
                            glyph: PantasIcons.close,
                          ),
                          if (question != null)
                            PantasIconButton(
                              tooltip: 'Report',
                              accent: _reported.contains(question.id),
                              onPressed: _completing
                                  ? null
                                  : () async {
                                      final sent = await openQuestionReport(
                                        context,
                                        question.id,
                                        queue: ReportQueue(
                                          ref.read(
                                            appDatabaseProvider,
                                          ),
                                        ),
                                      );
                                      if ((sent ?? false) && mounted) {
                                        setState(
                                          () => _reported.add(question.id),
                                        );
                                      }
                                    },
                              icon: PantasIcons.report,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: body),
                ],
              ),
              if (session != null && !_failed)
                Positioned(
                  left: PantasLayout.gutterPhone,
                  right: PantasLayout.gutterPhone,
                  bottom: PantasLayout.barBottomPhone,
                  child: FloatingBar.content(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PantasSpace.s14,
                          ),
                          child: Text(
                            '${_index + 1} of ${session.questions.length}',
                            style: context.type.subheadStrong,
                          ),
                        ),
                        const Spacer(),
                        PantasButton(
                          label: _index + 1 == session.questions.length
                              ? 'Finish'
                              : 'Next',
                          height: PantasSize.btn,
                          radius: PantasRadius.full,
                          fullWidth: false,
                          horizontalPadding: PantasSpace.s20,
                          busy: _savingSlow,
                          onPressed: _picked == null ? null : _next,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
