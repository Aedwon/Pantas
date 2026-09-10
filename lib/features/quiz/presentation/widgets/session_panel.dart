import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/ruled_panel.dart';
import 'package:pantas/core/ui/components/stats_band.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

/// The Quiz tab's first panel: one of four states, one per condition of the
/// day.
class SessionPanel extends ConsumerStatefulWidget {
  const SessionPanel({
    required this.exam,
    this.onStart,
    super.key,
  });

  final Exam exam;

  /// Runs before the session opens. The tab passes its study-first nudge.
  /// Null starts the session directly, which is what the widget tests do.
  final ValueChanged<PreparedTodaySession>? onStart;

  @override
  ConsumerState<SessionPanel> createState() => _SessionPanelState();
}

class _SessionPanelState extends ConsumerState<SessionPanel>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(sessionPanelProvider(widget.exam.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final exam = widget.exam;
    final onStart = widget.onStart;
    final async = ref.watch(sessionPanelProvider(exam.id));

    return async.when(
      loading: () => const RuledPanel(
        heading: "Today's session",
        child: FaintBars(),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (state) => switch (state) {
        SessionPanelNeedsAssessment(:final questionCount) =>
          _NeedsAssessment(exam: exam, questionCount: questionCount),
        SessionPanelInProgress() => _InProgress(exam: exam, state: state),
        SessionPanelCaughtUp() => _CaughtUp(state: state),
        SessionPanelAvailable() =>
          _Available(exam: exam, state: state, onStart: onStart),
      },
    );
  }
}

class _NeedsAssessment extends ConsumerWidget {
  const _NeedsAssessment({required this.exam, required this.questionCount});

  final Exam exam;
  final int questionCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;

    return RuledPanel(
      heading: 'Start with the assessment',
      count: '$questionCount questions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A few questions from every subject, to find out where you '
            'stand. Everything Pantas gives you afterwards is built on it.',
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 16),
          BoardButton(
            label: 'Take the assessment',
            onPressed: () async {
              await context.push('/assessment/${exam.id}');
              if (!context.mounted) return;
              ref.invalidate(sessionPanelProvider(exam.id));
            },
          ),
        ],
      ),
    );
  }
}

class _Available extends ConsumerWidget {
  const _Available({
    required this.exam,
    required this.state,
    this.onStart,
  });

  final Exam exam;
  final SessionPanelAvailable state;
  final ValueChanged<PreparedTodaySession>? onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    final averageMinutes = state.averageMinutes;

    return RuledPanel(
      heading: "Today's session",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatsBand(
            centred: true,
            compact: true,
            figures: [
              StatFigure(value: '${state.plan.length}', label: 'questions'),
              if (averageMinutes != null)
                StatFigure(
                  value: '$averageMinutes',
                  suffix: ' min',
                  label: 'your average',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            compositionLine(
              dueCount: state.plan.dueCount,
              weaknessCount: state.plan.weaknessCount,
              freshCount: state.plan.freshCount,
            ),
            textAlign: TextAlign.center,
            style: styles.bodySmall.copyWith(
              fontSize: 12.5,
              color: colors.inkMuted,
            ),
          ),
          const SizedBox(height: 6),
          _BoardTextAction(
            label: 'Change how sessions are built',
            onTap: () => context.push('/settings/sessions'),
          ),
          const SizedBox(height: 12),
          BoardButton(
            label: 'Start',
            onPressed: () {
              final prepared = state.prepared;
              if (onStart != null && prepared != null) {
                onStart!(prepared);
                return;
              }
              unawaited(
                context.push(
                  '/quiz/today/${exam.id}',
                  extra: prepared,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CaughtUp extends StatelessWidget {
  const _CaughtUp({required this.state});

  final SessionPanelCaughtUp state;

  @override
  Widget build(BuildContext context) {
    return RuledPanel(
      heading: "Today's session",
      child: StatsBand(
        centred: true,
        compact: true,
        figures: [
          StatFigure(value: '${state.answeredToday}', label: 'answered today'),
          StatFigure(value: '${state.correctToday}', label: 'got right'),
        ],
      ),
    );
  }
}

class _InProgress extends ConsumerWidget {
  const _InProgress({required this.exam, required this.state});

  final Exam exam;
  final SessionPanelInProgress state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    final body = styles.bodyMedium.copyWith(color: colors.inkMuted);
    final topicName = state.topicName;

    return RuledPanel(
      heading: 'Still going',
      count: '${state.answered} of ${state.total}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (topicName == null)
            Text(
              'You stopped partway through this session. '
              'Every answer was saved.',
              style: body,
            )
          else
            Text.rich(
              TextSpan(
                style: body,
                children: [
                  const TextSpan(text: 'You stopped partway through '),
                  TextSpan(
                    text: topicName,
                    style: body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
                    ),
                  ),
                  const TextSpan(text: '. Every answer was saved.'),
                ],
              ),
            ),
          const SizedBox(height: 16),
          BoardButton(
            label: 'Resume',
            onPressed: () => unawaited(context.push('/quiz/resume/${exam.id}')),
          ),
          const SizedBox(height: 8),
          _BoardTextAction(
            label: 'Discard this session',
            onTap: () => unawaited(_discard(ref)),
          ),
        ],
      ),
    );
  }

  Future<void> _discard(WidgetRef ref) async {
    await ref.read(quitSessionProvider)(
      userId: todayUserId,
      examId: exam.id,
      now: ref.read(nowProvider)(),
    );
    ref.invalidate(sessionPanelProvider(exam.id));
  }
}

class _BoardTextAction extends StatelessWidget {
  const _BoardTextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colors.board,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
String compositionLine({
  required int dueCount,
  required int weaknessCount,
  required int freshCount,
}) {
  final parts = <String>[
    if (dueCount > 0) '$dueCount due',
    if (weaknessCount > 0)
      '$weaknessCount weak ${weaknessCount == 1 ? 'spot' : 'spots'}',
    if (freshCount > 0) '$freshCount new',
  ];
  return parts.join(' · ');
}
