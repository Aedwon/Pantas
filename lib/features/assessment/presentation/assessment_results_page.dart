import 'dart:async';

import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/metrics/overall_accuracy.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_debrief_loading.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/assessment/application/assessment_result_providers.dart';
import 'package:pantas/features/assessment/domain/models/assessment_result.dart';
import 'package:pantas/features/assessment/domain/models/topic_mastery.dart';
import 'package:pantas/features/assessment/presentation/assessment_results_motion.dart';
import 'package:pantas/features/assessment/presentation/assessment_skeletons.dart';
import 'package:pantas/features/assessment/presentation/web_assessment_layout.dart';

/// Waits until the student lets go of Enter, for at most [limit].
///
/// Go to Today answers the first press of Enter and opens Home. A key held a
/// little longer keeps sending repeats, and the focused button on Home takes a
/// repeat as a press, which opened the first lesson. The page stays until the
/// key is up, so the press ends here.
@visibleForTesting
Future<void> waitForEnterRelease({
  Duration limit = const Duration(seconds: 2),
}) async {
  final keyboard = HardwareKeyboard.instance;
  if (!keyboard.isLogicalKeyPressed(LogicalKeyboardKey.enter)) return;
  final released = Completer<void>();
  bool handler(KeyEvent event) {
    if (event is KeyUpEvent &&
        event.logicalKey == LogicalKeyboardKey.enter &&
        !released.isCompleted) {
      released.complete();
    }
    return false;
  }

  keyboard.addHandler(handler);
  try {
    await released.future.timeout(limit);
  } on TimeoutException {
    // A key that never reports its release must not trap the student here.
  } finally {
    keyboard.removeHandler(handler);
  }
}

String _seenKey(AssessmentResult result) =>
    'assessment.results_seen.${result.examId}.'
    '${result.completedAt.toUtc().toIso8601String()}';

class _ResultData {
  const _ResultData(
    this.result,
    this.examName,
    this.subjects,
    this.elapsed, {
    required this.seen,
    this.topicSubjectNames = const {},
  });
  final AssessmentResult? result;
  final String examName;
  final List<({String name, int correct, int total})> subjects;
  final Duration? elapsed;
  final bool seen;
  final Map<String, String> topicSubjectNames;
}

final _resultDataProvider =
    FutureProvider.autoDispose.family<_ResultData, ExamId>((ref, id) async {
  final result = await ref.watch(assessmentResultProvider(id).future);
  if (result == null) return const _ResultData(null, '', [], null, seen: false);
  final content = ref.watch(contentRepositoryProvider);
  final subjects = <String, ({String name, int correct, int total})>{};
  final names = <String, String>{};
  for (final mastery in result.topicMasteries) {
    final subject = await content.subjectById(mastery.topic.subjectId);
    if (subject == null) continue;
    final name = examSubjectName(id, mastery.topic.name, subject.name);
    if (name == null) continue;
    final key = csePartForTopic(id, mastery.topic.name)?.key ?? subject.id;
    names[mastery.topic.id] = name;
    final previous = subjects[key];
    subjects[key] = (
      name: name,
      correct: (previous?.correct ?? 0) + mastery.correct,
      total: (previous?.total ?? 0) + mastery.total
    );
  }
  final rows = subjects.values.toList()
    ..sort(
      (a, b) => (a.total == 0 ? 0 : a.correct / a.total)
          .compareTo(b.total == 0 ? 0 : b.correct / b.total),
    );
  final exam =
      (await content.listExams()).where((exam) => exam.id == id).firstOrNull;
  final db = ref.watch(appDatabaseProvider);
  final attempts = await (db.select(db.attemptsLocal)
        ..where(
          (row) =>
              row.examId.equals(id) &
              row.origin.equals('assessment') &
              row.completedAt.equals(result.completedAt),
        ))
      .get();
  final attempt = attempts.firstOrNull;
  final elapsed = attempt == null ||
          attempt.completedAt == null ||
          !attempt.completedAt!.isAfter(attempt.startedAt)
      ? null
      : attempt.completedAt!.difference(attempt.startedAt);
  final seen = await ref
          .watch(appPreferencesRepositoryProvider)
          .deviceValue(_seenKey(result)) ==
      'true';
  return _ResultData(
    result,
    exam?.shortName ?? 'Assessment',
    rows,
    elapsed,
    seen: seen,
    topicSubjectNames: names,
  );
});

/// Loads what the results screen shows and keeps it until the caller leaves,
/// so the screen opens with its data in hand and never shows a skeleton first.
/// A failure is left for the results screen to report with its own retry.
Future<void> holdAssessmentResults(WidgetRef ref, ExamId examId) async {
  final provider = _resultDataProvider(examId);
  ref.listenManual(provider, (_, __) {});
  try {
    await ref.read(provider.future).timeout(const Duration(seconds: 3));
  } catch (_) {
    // The results screen shows its own loading or error state.
  }
}

/// The topic the plan card names as the weakest.
///
/// A topic holds only a few questions, so several often tie, most often at
/// zero. A tie goes to the topic in the weakest subject, the one the list
/// above ranks first, and then to authored order. Without that the card could
/// name a topic from the strongest subject, which reads as a wrong claim next
/// to the list.
@visibleForTesting
TopicMastery? weakestAssessedTopic(
  List<TopicMastery> topics, {
  required Map<String, String> subjectOf,
  required List<({String name, int correct, int total})> subjects,
}) {
  double subjectAccuracy(TopicMastery mastery) {
    for (final subject in subjects) {
      if (subject.name == subjectOf[mastery.topic.id]) {
        return subject.total == 0 ? 0 : subject.correct / subject.total;
      }
    }
    return 1;
  }

  TopicMastery? weakest;
  for (final candidate in topics) {
    if (weakest == null) {
      weakest = candidate;
      continue;
    }
    final byTopic = candidate.accuracy.compareTo(weakest.accuracy);
    final bySubject = subjectAccuracy(candidate).compareTo(
      subjectAccuracy(weakest),
    );
    final byOrder = candidate.topic.ordering.compareTo(weakest.topic.ordering);
    if (byTopic < 0 ||
        (byTopic == 0 && (bySubject < 0 || (bySubject == 0 && byOrder < 0)))) {
      weakest = candidate;
    }
  }
  return weakest;
}

class AssessmentResultsPage extends ConsumerWidget {
  const AssessmentResultsPage({required this.examId, super.key});
  final ExamId examId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_resultDataProvider(examId));
    firstScreenReady(context, ref, ready: !data.isLoading);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: data.when(
        loading: () => context.wideWeb
            ? const WebDebriefLoading()
            : const AssessmentResultsSkeleton(),
        error: (error, _) => errorFor(
          'assessment results',
          () => ref.invalidate(_resultDataProvider(examId)),
          error: error,
        ),
        data: (value) {
          if (value.seen) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go('/home');
            });
            return const SizedBox.shrink();
          }
          if (value.result == null) {
            return Center(
              child: StateView(
                message: 'No results yet.',
                actionLabel: 'Back to Home',
                onRetry: () => context.go('/home'),
              ),
            );
          }
          return _ResultsBody(
            data: value,
            onAcknowledge: () async {
              final telemetry = ref.read(telemetryProvider);
              try {
                await ref
                    .read(appPreferencesRepositoryProvider)
                    .setDeviceValue(_seenKey(value.result!), 'true');
                // The provider is released when this page leaves. Resetting it
                // here would swap the results for a skeleton on the way out.
                await waitForEnterRelease();
                if (context.mounted) context.go('/home');
              } catch (error, stack) {
                unawaited(telemetry.recordError(error, stack));
                // The body shows its own retry line.
                rethrow;
              }
            },
          );
        },
      ),
    );
  }
}

class _ResultsBody extends StatefulWidget {
  const _ResultsBody({required this.data, required this.onAcknowledge});
  final _ResultData data;
  final Future<void> Function() onAcknowledge;
  @override
  State<_ResultsBody> createState() => _ResultsBodyState();
}

class _ResultsBodyState extends State<_ResultsBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AssessmentResultsSequence.duration,
  );
  late final AssessmentResultsSequence _sequence = AssessmentResultsSequence(
    _controller,
    subjectCount: widget.data.subjects.length,
  );
  bool _saving = false;
  bool _failed = false;

  /// Holds the page's keyboard focus (Enter is Go to Today). See [_reclaim].
  final FocusNode _focus = FocusNode(debugLabel: 'assessment results');
  bool _reclaimQueued = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_focusChanged);
  }

  void _focusChanged() {
    // Settle after the frame, as focus is often mid-change when this is called.
    if (_reclaimQueued) return;
    _reclaimQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reclaimQueued = false;
      _reclaim();
    });
  }

  /// Takes focus back when a page underneath has taken it.
  ///
  /// The assessment opens above Home, which stays mounted. When the answers are
  /// saved Home rebuilds, and its Today panel (autofocus, with its own Enter
  /// shortcut) took the focus from this page. Enter on Go to Today then
  /// reached Home instead, and opened the first lesson (3L-7).
  void _reclaim() {
    if (!mounted || ModalRoute.of(context)?.isCurrent == false) return;
    if (_focus.context == null || !_focus.canRequestFocus) return;
    final primary = FocusManager.instance.primaryFocus;
    final inside = primary != null &&
        (primary == _focus ||
            primary.ancestors.contains(FocusScope.of(context)));
    if (!inside) _focus.requestFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The sequence plays once for this arrival. A rebuild or a resize keeps
    // the controller where it is, and reduced motion shows the final state.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_focusChanged);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _acknowledge() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await widget.onAcknowledge();
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.data.result!;
    // Only topics whose subject is shown count, so the ring agrees with rows.
    final shown = [
      for (final m in result.topicMasteries)
        if (widget.data.topicSubjectNames.containsKey(m.topic.id)) m,
    ];
    final total = shown.fold(0, (sum, m) => sum + m.total);
    final correct = shown.fold(0, (sum, m) => sum + m.correct);
    final weakest = weakestAssessedTopic(
      shown,
      subjectOf: widget.data.topicSubjectNames,
      subjects: widget.data.subjects,
    );
    final weakestSubject =
        widget.data.topicSubjectNames[weakest?.topic.id] ?? '';
    final c = context.colors;
    final elapsed = widget.data.elapsed;
    if (context.wideWeb) {
      return SafeArea(
        child: WebAssessmentResults(
          focusNode: _focus,
          examName: widget.data.examName,
          correct: correct,
          total: total,
          subjects: widget.data.subjects,
          elapsed: elapsed,
          weakestTopic: weakest?.topic.name,
          weakestSubject: weakestSubject,
          saving: _saving,
          failure: _failed ? saveFailureLine(_acknowledge) : null,
          onAcknowledge: _acknowledge,
          sequence: _sequence,
        ),
      );
    }
    final subjects = GroupedSection(
      header: 'BY SUBJECT · WEAKEST FIRST',
      children: [
        for (final (index, subject) in widget.data.subjects.indexed)
          AssessmentSubjectRow(
            name: subject.name,
            correct: subject.correct,
            total: subject.total,
            divider: index < widget.data.subjects.length - 1,
            bar: _sequence.bar(index),
          ),
      ],
    );
    final gauge = Column(
      children: [
        Center(
          child: AssessmentScoreGauge(
            correct: correct,
            total: total,
            sequence: _sequence,
          ),
        ),
        if (elapsed != null) ...[
          const SizedBox(height: PantasSpace.s8),
          Text(
            switch (elapsed.inMinutes) {
              0 => 'in under a minute',
              1 => 'in 1 minute',
              final minutes => 'in $minutes minutes',
            },
            style: context.type.footnote.copyWith(color: c.secondaryLabel),
          ),
        ],
      ],
    );
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s16,
                PantasSpace.s56,
                PantasSpace.s16,
                PantasSpace.s24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ResultsReveal(
                    animation: _sequence.title,
                    child: Text(
                      "Where you're starting",
                      textAlign: TextAlign.center,
                      style: context.type.pageTitleCompact,
                    ),
                  ),
                  const SizedBox(height: PantasSpace.s6),
                  ResultsReveal(
                    animation: _sequence.subtitle,
                    child: Text(
                      '${widget.data.examName} · $total questions',
                      textAlign: TextAlign.center,
                      style: context.type.subhead
                          .copyWith(color: c.secondaryLabel),
                    ),
                  ),
                  const SizedBox(height: PantasSpace.s24),
                  ResultsReveal(animation: _sequence.score, child: gauge),
                  const SizedBox(height: PantasSpace.s20),
                  ResultsReveal(animation: _sequence.subjects, child: subjects),
                  if (weakest != null) ...[
                    const SizedBox(height: PantasSpace.s20),
                    ResultsReveal(
                      animation: _sequence.plan,
                      child: GroupedSection(
                        header: 'WEAKEST TOPIC',
                        footer: 'It changes as you study.',
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: PantasSpace.s16,
                              vertical: PantasSpace.s14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        weakest.topic.name,
                                        style: context.type.emphasized,
                                      ),
                                      Text(
                                        '$weakestSubject · '
                                        'lowest score in this check',
                                        style: context.type.footnote
                                            .copyWith(color: c.secondaryLabel),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s14,
              PantasSpace.s16,
              PantasSpace.s28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_failed) saveFailureLine(_acknowledge),
                PantasButton(
                  label: 'Go to Today',
                  busy: _saving,
                  onPressed: _saving ? null : _acknowledge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
