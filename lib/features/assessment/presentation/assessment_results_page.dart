import 'dart:async';

import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_debrief_loading.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/assessment/application/assessment_result_providers.dart';
import 'package:pantas/features/assessment/domain/models/assessment_result.dart';
import 'package:pantas/features/assessment/presentation/assessment_skeletons.dart';
import 'package:pantas/features/assessment/presentation/web_assessment_layout.dart';

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
    names[mastery.topic.id] = subject.name;
    final previous = subjects[subject.id];
    subjects[subject.id] = (
      name: subject.name,
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

class AssessmentResultsPage extends ConsumerWidget {
  const AssessmentResultsPage({required this.examId, super.key});
  final ExamId examId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_resultDataProvider(examId));
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
                ref.invalidate(_resultDataProvider(examId));
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
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );
  bool _saving = false;
  bool _failed = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _reveal(int start, int duration, Widget child, {double offset = 10}) =>
      AnimatedBuilder(
        animation: _controller,
        child: child,
        builder: (context, child) {
          final p = const Cubic(.3, .9, .3, 1).transform(
            ((_controller.value * 3000 - start) / duration).clamp(0.0, 1.0),
          );
          return ExcludeFocus(
            excluding: p == 0,
            child: ExcludeSemantics(
              excluding: p == 0,
              child: Opacity(
                opacity: p,
                child: Transform.translate(
                  offset: Offset(0, offset * (1 - p)),
                  child: child,
                ),
              ),
            ),
          );
        },
      );
  Future<void> _acknowledge() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await widget.onAcknowledge();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _subjectRow(
    ({String name, int correct, int total}) subject,
    int index,
  ) {
    final percent = subject.total == 0
        ? 0
        : (100 * subject.correct / subject.total).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Semantics(
        label: '${subject.name}, $percent percent',
        excludeSemantics: true,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(subject.name, style: context.type.body)),
                Text('$percent%', style: context.type.body),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final progress = PantasCurves.houseOut.transform(
                  ((_controller.value * 3000 - 1500 - index * 120) / 800)
                      .clamp(0.0, 1.0),
                );
                return ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (subject.total == 0
                            ? 0
                            : subject.correct / subject.total) *
                        progress,
                    minHeight: 5,
                    backgroundColor: context.colors.fill,
                    color: context.colors.chevron,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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
    final weakest = shown.firstOrNull;
    final weakestSubject =
        widget.data.topicSubjectNames[weakest?.topic.id] ?? '';
    final c = context.colors;
    final elapsed = widget.data.elapsed;
    if (context.wideWeb) {
      return SafeArea(
        child: WebAssessmentResults(
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
        ),
      );
    }
    final subjects = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 7),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            children: [
              Text('BY SUBJECT', style: context.type.sectionHeader),
              Text('WEAKEST FIRST', style: context.type.sectionHeader),
            ],
          ),
        ),
        GroupedSection(
          children: [
            for (final (index, subject) in widget.data.subjects.indexed)
              _subjectRow(subject, index),
          ],
        ),
      ],
    );
    final gauge = Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => HalfRingGauge.quizCount(
            correct: correct,
            total: total,
            assessment: true,
            labelOpacity:
                ((_controller.value * 3000 - 1300) / 300).clamp(0.0, 1.0),
          ),
        ),
        if (elapsed != null) ...[
          const SizedBox(height: 6),
          _reveal(
            1500,
            300,
            Text(
              switch (elapsed.inMinutes) {
                0 => 'in under a minute',
                1 => 'in 1 minute',
                final minutes => 'in $minutes minutes',
              },
              style: context.type.footnote.copyWith(color: c.secondaryLabel),
            ),
            offset: 0,
          ),
        ],
      ],
    );
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 52, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _reveal(
                    100,
                    380,
                    Text(
                      "Where you're starting",
                      textAlign: TextAlign.center,
                      style: context.type.pageTitleCompact,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _reveal(
                    200,
                    380,
                    Text(
                      '${widget.data.examName} · $total questions',
                      textAlign: TextAlign.center,
                      style: context.type.subhead
                          .copyWith(color: c.secondaryLabel),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _reveal(300, 380, gauge),
                  const SizedBox(height: 22),
                  _reveal(1300, 380, subjects),
                  if (weakest != null) ...[
                    const SizedBox(height: 22),
                    _reveal(
                      2600,
                      380,
                      GroupedSection(
                        header: 'YOUR PLAN STARTS WITH',
                        footer: 'Weakest first. It changes as you study.',
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
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
                                        '$weakestSubject · your weakest topic',
                                        style: context.type.footnote
                                            .copyWith(color: c.secondaryLabel),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Today',
                                  style: context.type.subheadStrong
                                      .copyWith(color: c.accent),
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
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
