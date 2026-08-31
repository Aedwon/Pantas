import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/error_banner.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/question_card.dart';
import 'package:pantas/core/ui/components/quiz_progress_bar.dart';
import 'package:pantas/features/assessment/application/assessment_result_providers.dart';
import 'package:pantas/features/assessment/domain/models/assessment_session.dart';
import 'package:pantas/features/assessment/domain/use_cases/complete_assessment.dart';
import 'package:pantas/features/assessment/domain/use_cases/start_assessment.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

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
  int _currentIndex = 0;
  String? _errorMessage;
  bool _completing = false;

  // When completing fails, keep the session alive so the user can retry without
  // re-answering.
  AssessmentSession? _pendingCompleteSession;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _session = null;
      _errorMessage = null;
      _pendingCompleteSession = null;
    });
    try {
      final alreadyCompleted = await ref.read(
        assessmentCompletedProvider(widget.examId).future,
      );
      if (!mounted) return;
      if (alreadyCompleted) {
        context.pushReplacement('/assessment/${widget.examId}/results');
        return;
      }
      final scopedTopics = await ref.read(
        scopedTopicsProvider(widget.examId).future,
      );
      final session = await ref
          .read(_startAssessmentProvider)
          .call(widget.examId, topics: scopedTopics);
      if (!mounted) return;
      setState(() => _session = session);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _complete(AssessmentSession session) async {
    setState(() => _completing = true);
    try {
      await ref
          .read(_completeAssessmentProvider)
          .call(session: session, now: DateTime.now());
      if (!mounted) return;
      // The Home tab reads both of these from inside the bottom-nav shell, so
      // they were already cached as "no assessment" before this run started.
      // Neither is autoDispose and the shell never unmounts, so without an
      // explicit invalidation the results page renders the stale null as
      // "No assessment found." and Home keeps offering to start the
      // assessment the user just finished.
      ref
        ..invalidate(assessmentResultProvider(widget.examId))
        ..invalidate(assessmentCompletedProvider(widget.examId))
        ..invalidate(countForExamProvider(widget.examId))
        ..invalidate(sessionPanelProvider(widget.examId))
        ..invalidate(todayInputsProvider(widget.examId));
      context.pushReplacement('/assessment/${widget.examId}/results');
    } catch (e) {
      if (!mounted) return;
      // Keep session alive so user can retry without re-answering
      setState(() {
        _completing = false;
        _pendingCompleteSession = session;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _onAnswer(String chosenChoiceId) async {
    final session = _session;
    if (session == null || _completing) return;

    final aq = session.questions[_currentIndex];
    final updated = session.copyWithAnswer(
      questionId: aq.question.id,
      chosenChoiceId: chosenChoiceId,
    );

    if (_currentIndex < session.questions.length - 1) {
      setState(() {
        _session = updated;
        _currentIndex++;
      });
      return;
    }

    setState(() => _session = updated);
    await _complete(updated);
  }

  Future<bool> _confirmLeave() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave assessment?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;

    Widget body;
    if (_errorMessage != null) {
      body = ErrorBanner(
        variant: ErrorBannerVariant.error,
        message: _errorMessage!,
        actionLabel: 'Retry',
        // If we have a pending session (complete failed), retry complete.
        // Otherwise retry load.
        onAction: _pendingCompleteSession != null
            ? () => _complete(_pendingCompleteSession!)
            : _load,
      );
    } else if (session == null || _completing) {
      body = const FaintBars();
    } else {
      body = Column(
        children: [
          QuizProgressBar(
            current: _currentIndex + 1,
            total: session.questions.length,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: QuestionCard(
                question: session.questions[_currentIndex].question,
                onAnswer: _onAnswer,
              ),
            ),
          ),
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmLeave();
        if (leave && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Assessment')),
        body: Padding(padding: const EdgeInsets.all(16), child: body),
      ),
    );
  }
}
