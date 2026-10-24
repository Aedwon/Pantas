import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
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
import 'package:pantas/core/ui/components/report_form.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/assessment/application/assessment_result_providers.dart';
import 'package:pantas/features/assessment/domain/models/assessment_session.dart';
import 'package:pantas/features/assessment/domain/use_cases/complete_assessment.dart';
import 'package:pantas/features/assessment/domain/use_cases/start_assessment.dart';
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

final _completeAssessmentProvider = Provider<CompleteAssessment>(
  (ref) => CompleteAssessment(
    assessmentRepo: AssessmentRepository(ref.watch(appDatabaseProvider)),
    reviewRepo: ref.watch(reviewStateRepositoryProvider),
    scheduler: const FsrsScheduler(),
    contentRepo: ref.watch(contentRepositoryProvider),
    attemptsRepo: ref.watch(attemptsRepositoryProvider),
  ),
);

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
  bool _advancing = false;
  bool _leaveOpen = false;
  int _generation = 0;
  Future<bool> Function()? _owner;
  final _questionClock = Stopwatch();
  final Set<String> _reported = {};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _generation++;
    _questionClock.stop();
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    final db = ref.read(appDatabaseProvider);
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
    } catch (error) {
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
    _questionClock.stop();
    setState(() {
      _completing = true;
      _failed = false;
    });
    try {
      if (!await _checkOwner()) return;
      await ref
          .read(_completeAssessmentProvider)
          .call(session: _session!, now: DateTime.now(), canPersist: _owner);
      if (!await _checkOwner()) return;
      ref
        ..invalidate(assessmentResultProvider(widget.examId))
        ..invalidate(assessmentCompletedProvider(widget.examId))
        ..invalidate(roadmapTodayProvider(widget.examId));
      ref.read(todayQuizPreparerProvider).invalidateAll();
      ref.read(quizSessionPanelRevisionProvider.notifier).publishCompletion();
      if (mounted) {
        context.pushReplacement('/assessment/${widget.examId}/results');
      }
    } on AssessmentAlreadyCompleted {
      if (await _checkOwner() && mounted) context.go('/home');
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  Future<void> _leave() async {
    if (_leaveOpen || _completing) return;
    _leaveOpen = true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => CenteredDialog(
        title: 'Leave the assessment?',
        message: "Your answers so far won't be kept. "
            'You can start again from Home.',
        primaryLabel: 'Leave',
        secondaryLabel: 'Keep Going',
        destructive: true,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    _leaveOpen = false;
    if ((leave ?? false) && mounted) {
      _generation++;
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final question = session?.questions[_index].question;
    final topic = question == null
        ? null
        : ref.watch(topicByIdProvider(question.topicId)).valueOrNull;
    final passageState = question?.passageId == null
        ? null
        : ref.watch(passageByIdProvider(question!.passageId!));
    final passage = passageState?.valueOrNull;
    Widget body;
    if (_unavailable) {
      body = StateView(
        message: "Assessment isn't ready yet",
        detail: "We're still adding questions for this exam. "
            'You can use the rest of Pantas for now.',
        actionLabel: 'Back to Quiz',
        onRetry: () => context.go('/quiz'),
      );
    } else if (_failed) {
      body = errorFor('assessment', session == null ? _load : _complete);
    } else if (session == null || _completing) {
      body = loadingFor(const AsyncLoading<void>());
    } else if (passageState != null && !passageState.hasValue) {
      body = passageState.hasError
          ? errorFor(
              'passage',
              () => ref.invalidate(passageByIdProvider(question!.passageId!)),
            )
          : loadingFor(passageState);
    } else {
      body = SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        child: Column(
          children: [
            QuestionCard(
              subject: topic?.name ?? '',
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
            const SizedBox(height: 20),
            Text(
              'Answers show at the end.',
              style: context.type.footnote
                  .copyWith(color: context.colors.secondaryLabel),
            ),
          ],
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
                  SizedBox(
                    height: 44,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            tooltip: 'Leave assessment',
                            onPressed: _completing ? null : _leave,
                            icon: Icon(
                              PantasIcons.close,
                              color: context.colors.tertiaryLabel,
                              size: 22,
                            ),
                          ),
                          if (question != null)
                            IconButton(
                              tooltip: 'Report',
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
                              icon: IconTheme(
                                data: IconThemeData(
                                  color: _reported.contains(question.id)
                                      ? context.colors.accent
                                      : context.colors.tertiaryLabel,
                                  size: 21,
                                ),
                                child: PantasIcons.report,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: body),
                ],
              ),
              if (session != null && !_failed && !_completing)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: FloatingBar.content(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            '${_index + 1} of ${session.questions.length}',
                            style: context.type.subheadStrong,
                          ),
                        ),
                        const Spacer(),
                        PantasButton(
                          label: 'Next',
                          height: 44,
                          radius: 99,
                          fontSize: 16,
                          fullWidth: false,
                          horizontalPadding: 20,
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
