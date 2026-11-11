import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:pantas/core/ui/components/pantas_tag.dart';
import 'package:pantas/core/ui/components/progress_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

enum PantasTimerState { running, warning, paused }

/// The clock of the mock exam (design system Timer): the time left over a thin
/// bar. Under five minutes the time and the bar turn `warning-text` and a
/// visible tag says so; a paused clock is `text-secondary` with a gray tag.
/// The warning is on the clock itself, never a toast.
///
/// The clock is not a live region, so a running clock does not announce every
/// second. The five-minute warning is announced once, when [state] first
/// becomes [PantasTimerState.warning].
class PantasTimer extends StatefulWidget {
  const PantasTimer({
    required this.timeText,
    required this.fractionLeft,
    this.state = PantasTimerState.running,
    this.inline = false,
    this.semanticLabel = 'Time left',
    this.warningLabel = '5 min left',
    this.pausedLabel = 'Paused',
    this.warningAnnouncement = 'Five minutes left.',
    this.announceWarning = true,
    super.key,
  }) : assert(
          fractionLeft >= 0 && fractionLeft <= 1,
          'Fraction must be from 0 to 1.',
        );

  /// The clock text: `h:mm:ss`, or `m:ss` under one hour.
  final String timeText;

  /// The share of the time still left, 0 to 1.
  final double fractionLeft;
  final PantasTimerState state;

  /// The time and a 60 px bar on one line (the focus header).
  final bool inline;
  final String semanticLabel;
  final String warningLabel;
  final String pausedLabel;
  final String warningAnnouncement;

  /// False when the page already announces the warning another way (the
  /// mock's status-role proctor call), so it is spoken once.
  final bool announceWarning;

  @override
  State<PantasTimer> createState() => _PantasTimerState();
}

class _PantasTimerState extends State<PantasTimer> {
  @override
  void didUpdateWidget(PantasTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.announceWarning &&
        oldWidget.state != PantasTimerState.warning &&
        widget.state == PantasTimerState.warning) {
      unawaited(
        SemanticsService.sendAnnouncement(
          View.of(context),
          widget.warningAnnouncement,
          Directionality.of(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final warning = widget.state == PantasTimerState.warning;
    final paused = widget.state == PantasTimerState.paused;
    final timeColor = warning
        ? colors.warningText
        : paused
            ? colors.textSecondary
            : colors.textPrimary;
    final time = Text(
      widget.timeText,
      key: const ValueKey('timer-time'),
      style: PantasType.webTimer.copyWith(color: timeColor),
    );
    final barWidth =
        widget.inline ? PantasSize.timerBar / 2 : PantasSize.timerBar;
    final bar = SizedBox(
      width: barWidth,
      child: PantasProgressBar(
        value: widget.fractionLeft,
        warning: warning,
      ),
    );
    final tag = warning
        ? PantasTag(widget.warningLabel, tone: PantasTagTone.warning)
        : paused
            ? PantasTag(widget.pausedLabel, tone: PantasTagTone.gray)
            : null;
    return Semantics(
      label: widget.semanticLabel,
      value: warning
          ? '${widget.timeText}, ${widget.warningLabel}'
          : paused
              ? '${widget.timeText}, ${widget.pausedLabel}'
              : widget.timeText,
      liveRegion: false,
      child: ExcludeSemantics(
        child: widget.inline
            ? Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: PantasSpace.s10,
                runSpacing: PantasSpace.s6,
                children: [time, bar, if (tag != null) tag],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  time,
                  const SizedBox(height: PantasSpace.s6),
                  bar,
                  if (tag != null) ...[
                    const SizedBox(height: PantasSpace.s6),
                    tag,
                  ],
                ],
              ),
      ),
    );
  }
}
