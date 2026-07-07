import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_panel.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/cooldown_label.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_attempt.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_availability.dart';
import 'package:flutter/material.dart';

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// "5 August". The tier line's reopen date and the "taken" figure.
String formatDay(DateTime value) =>
    '${value.day} ${_monthNames[value.month - 1]}';

/// The Quiz tab's second panel.
///
/// Built here rather than in `features/quiz` because it reads
/// [MockAvailability] and [MockAttempt]. The Quiz tab receives it as a plain
/// `Widget` from the router, so no feature imports another.
class MockPanel extends StatelessWidget {
  const MockPanel({
    required this.availability,
    required this.lastAttempt,
    required this.proIsActive,
    required this.onTake,
    required this.onResume,
    required this.onViewResults,
    super.key,
  });

  final MockAvailability availability;

  /// The most recent finished attempt, or null before the first one.
  final MockAttempt? lastAttempt;

  final bool proIsActive;
  final VoidCallback onTake;
  final VoidCallback onResume;
  final VoidCallback onViewResults;

  @override
  Widget build(BuildContext context) {
    final remaining = availability.cooldownRemaining;
    final attempt = lastAttempt;
    final inProgress = availability.state == MockAvailabilityState.inProgress;
    final inCooldown = availability.state == MockAvailabilityState.cooldown;
    final hasHistory = attempt?.submittedAt != null;

    return RuledPanel(
      heading: 'Mock exam',
      count: remaining == null ? null : cooldownLabel(remaining),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (inProgress)
            const _Body(
              "Finish your session first. It runs 3 hours 30 and can't be "
              'paused.',
            )
          else if (!hasHistory)
            const _Body(
              'The whole thing under exam timing. 3 hours 30, and no answers '
              'until the end.',
            )
          else
            _Figures(attempt: attempt!),
          const SizedBox(height: 12),
          _TierLine(
            proIsActive: proIsActive,
            reopensOn: _reopensOn(remaining),
          ),
          if (hasHistory && !inProgress) ...[
            const SizedBox(height: 4),
            BoardButton(
              label: 'View your full results from last time',
              secondary: true,
              onPressed: onViewResults,
            ),
          ],
          if (inProgress) ...[
            const SizedBox(height: 8),
            BoardButton(
              label: 'Resume',
              secondary: true,
              onPressed: onResume,
            ),
          ] else if (!inCooldown) ...[
            const SizedBox(height: 8),
            BoardButton(
              // The heading already says "Mock exam", so the button does not
              // repeat it. It is an exam and you take it.
              label: hasHistory ? 'Take another' : 'Take the exam',
              secondary: true,
              onPressed: onTake,
            ),
          ],
        ],
      ),
    );
  }

  /// Null unless a cooldown is running. A student who has never taken one has
  /// no reopen date, and computing one from no attempt would be a figure this
  /// app made up.
  DateTime? _reopensOn(Duration? remaining) =>
      remaining == null ? null : DateTime.now().add(remaining);
}

class _Body extends StatelessWidget {
  const _Body(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textStyles.bodyMedium
          .copyWith(color: context.colors.inkMuted),
    );
  }
}

/// Two figures, not three.
///
/// The spec drew "parts passed" between them. It was cut on 2 August:
/// `SectionResult` has no pass mark, and the app's only threshold is
/// `ComputeResults.bandFor`'s whole-paper 75%, which the mock spec calls a
/// fallback until per-exam bands load from Sanity.
class _Figures extends StatelessWidget {
  const _Figures({required this.attempt});

  final MockAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final raw = attempt.scoreRaw;
    final total = attempt.scoreTotal;
    final percent = (raw == null || total == null || total == 0)
        ? null
        : (raw / total) * 100;

    return StatsBand(
      centred: true,
      compact: true,
      figures: [
        if (percent != null)
          StatFigure(
            value: '${percent.round()}',
            suffix: '%',
            label: 'last score',
          ),
        StatFigure(
          value: formatDay(attempt.submittedAt!),
          label: 'taken',
        ),
      ],
    );
  }
}

/// Stated in every state, on its own line opened by a hairline.
///
/// Always stated so the cadence is learned as a rule of the app rather than
/// discovered as a wall on the ninth day. This is the only visible paywall in
/// the tab.
class _TierLine extends StatelessWidget {
  const _TierLine({required this.proIsActive, this.reopensOn});

  final bool proIsActive;
  final DateTime? reopensOn;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final muted = styles.bodySmall.copyWith(color: colors.inkMuted);
    final strong =
        muted.copyWith(fontWeight: FontWeight.w700, color: colors.ink);
    final reopens = reopensOn;

    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colors.ruleFaint,
          ),
        ),
      ),
      child: proIsActive
          ? Text.rich(
              TextSpan(
                style: muted,
                children: [
                  TextSpan(text: 'Pro users', style: strong),
                  const TextSpan(text: ' can take as many as they want.'),
                ],
              ),
            )
          : Text.rich(
              TextSpan(
                style: muted,
                children: [
                  TextSpan(text: 'Free users', style: strong),
                  const TextSpan(text: ' get one every two weeks.'),
                  if (reopens != null) ...[
                    const TextSpan(text: ' Your next one opens on '),
                    TextSpan(text: formatDay(reopens), style: strong),
                    const TextSpan(text: '.'),
                  ],
                ],
              ),
            ),
    );
  }
}
