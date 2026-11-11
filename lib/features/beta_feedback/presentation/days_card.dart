import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/beta_feedback/presentation/fb_kit.dart';

const surveyPath = '/settings/beta-feedback/survey';

/// The device-local key for the last day count this device showed.
const shownDaysKey = 'beta_feedback_shown_days';

enum SurveyStatus { notYet, open, sent, closed }

SurveyStatus surveyStatus(BetaReward reward, DateTime now) {
  if (reward.surveySubmitted) return SurveyStatus.sent;
  if (now.isBefore(reward.surveyOpensAt)) return SurveyStatus.notYet;
  if (!now.isBefore(reward.surveyClosesAt)) return SurveyStatus.closed;
  return SurveyStatus.open;
}

/// The last day the survey takes answers: the day before it closes.
DateTime surveyLastDay(BetaReward reward) =>
    reward.surveyClosesAt.subtract(const Duration(milliseconds: 1));

/// The days card: the count, the seven beta days and the Exit Survey row.
///
/// With [condensed] (under the reward card) the card is the 17 px title and
/// the strip only.
class DaysCard extends ConsumerStatefulWidget {
  const DaysCard({
    required this.reward,
    required this.now,
    this.condensed = false,
    super.key,
  });
  final BetaReward reward;
  final DateTime now;
  final bool condensed;

  @override
  ConsumerState<DaysCard> createState() => _DaysCardState();
}

class _DaysCardState extends ConsumerState<DaysCard> {
  /// False until the stored count is known; the digit waits so it does not
  /// show and then roll.
  bool _known = false;

  /// The count to roll up from, while a roll runs.
  int? _from;

  int get _count => math.min(5, widget.reward.days.length);

  @override
  void initState() {
    super.initState();
    unawaited(_loadShown());
  }

  Future<void> _loadShown() async {
    final prefs = ref.read(appPreferencesRepositoryProvider);
    int? last;
    try {
      last = int.tryParse(await prefs.deviceValue(shownDaysKey) ?? '');
    } on Object {
      last = null;
    }
    if (!mounted) return;
    final roll = !widget.condensed &&
        last != null &&
        _count > last &&
        !MediaQuery.disableAnimationsOf(context);
    setState(() {
      _known = true;
      _from = roll ? last : null;
    });
    if (last != _count) {
      try {
        await prefs.setDeviceValue(shownDaysKey, '$_count');
      } on Object {
        // Remembering is a nicety. The count is already on screen.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = context.fbWide;
    final c = context.fb;
    final reward = widget.reward;
    final today = phKey(widget.now);
    final condensed = widget.condensed;
    final status = surveyStatus(reward, widget.now);

    final countStyle = condensed
        ? context.fbTitle
        : (wide ? PantasType.webH3Lg : PantasType.phoneTitle2)
            .copyWith(color: c.textPrimary);
    final header = Padding(
      padding: condensed
          ? const EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s18,
              PantasSpace.s16,
              PantasSpace.s4,
            )
          : wide
              ? const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s18,
                  PantasSpace.s16,
                  PantasSpace.s6,
                )
              : const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s18,
                  PantasSpace.s16,
                  PantasSpace.s16,
                ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: _known || condensed ? 1 : 0,
            child: _from == null
                ? Text('$_count of 5 days', style: countStyle)
                : _RollingCount(
                    from: _from!,
                    to: _count,
                    style: countStyle,
                    onDone: () => setState(() => _from = null),
                  ),
          ),
          if (!condensed) ...[
            const SizedBox(height: PantasSpace.s4),
            Text(
              'A day counts when you finish your whole Today plan.',
              style: context.fbSub,
            ),
          ],
        ],
      ),
    );

    var counted = 0;
    final cells = <Widget>[];
    for (var j = 0; j < reward.betaDays.length; j++) {
      final key = reward.betaDays[j];
      final done = reward.days.contains(key);
      final delay = condensed
          ? (wide ? Duration(milliseconds: 80 + 60 * j) : null)
          : Duration(milliseconds: 100 + 80 * counted);
      if (done) counted++;
      cells.add(
        _DayCell(
          dayKey: key,
          counted: done,
          today: key == today,
          popDelay: delay,
          condensed: condensed,
        ),
      );
    }
    final strip = wide
        ? Padding(
            padding: EdgeInsets.fromLTRB(
              PantasSpace.s16,
              condensed ? PantasSpace.s12 : PantasSpace.s14,
              PantasSpace.s16,
              PantasSpace.s18,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final cell in cells)
                  SizedBox(width: PantasSpace.s40, child: cell),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsets.fromLTRB(
              PantasSpace.s12,
              condensed ? PantasSpace.s10 : PantasSpace.s4,
              PantasSpace.s12,
              PantasSpace.s18,
            ),
            child: Row(
              children: [
                for (var i = 0; i < cells.length; i++) ...[
                  if (i > 0) const SizedBox(width: PantasSpace.s4),
                  Expanded(child: cells[i]),
                ],
              ],
            ),
          );

    return FbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          strip,
          Padding(
            padding: EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s0,
              wide ? PantasSpace.s16 : PantasSpace.s0,
              PantasSpace.s0,
            ),
            child: Container(height: PantasBorder.hairline, color: c.divider),
          ),
          ExitSurveyRow(reward: reward, status: status),
        ],
      ),
    );
  }
}

/// The count with its digit rolling up: the old one slides up and fades out
/// while the new one comes in from below (240 ms, shared ease).
class _RollingCount extends StatelessWidget {
  const _RollingCount({
    required this.from,
    required this.to,
    required this.style,
    required this.onDone,
  });
  final int from;
  final int to;
  final TextStyle style;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final rise = style.fontSize ?? PantasSpace.s24;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: PantasDurations.medium1,
      curve: PantasCurves.move,
      onEnd: onDone,
      builder: (context, e, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Opacity(
                  key: const ValueKey('count-old'),
                  opacity: 1 - e,
                  child: Transform.translate(
                    offset: Offset(0, -rise * e),
                    child: Text('$from', style: style),
                  ),
                ),
              ),
              Opacity(
                key: const ValueKey('count-new'),
                opacity: e,
                child: Transform.translate(
                  offset: Offset(0, rise * (1 - e)),
                  child: Text('$to', style: style),
                ),
              ),
            ],
          ),
          Text(' of 5 days', style: style),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.dayKey,
    required this.counted,
    required this.today,
    required this.popDelay,
    required this.condensed,
  });
  final String dayKey;
  final bool counted;
  final bool today;
  final Duration? popDelay;
  final bool condensed;

  @override
  Widget build(BuildContext context) {
    final wide = context.fbWide;
    final c = context.fb;
    final number = int.parse(dayKey.substring(8));
    final label = today
        ? 'Today'
        : wide
            ? '${weekdayOf(dayKey)} $number'
            : weekdayOf(dayKey);
    final size = wide ? 40.0 : 36.0;
    final date = monthDayOfKey(dayKey);

    final Widget circle;
    if (counted) {
      circle = Semantics(
        label: '$date, counted',
        image: true,
        excludeSemantics: true,
        child: Container(
          key: ValueKey('day-$dayKey'),
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: c.accentFill, shape: BoxShape.circle),
          child: FbGlyph(
            FbGlyphKind.check,
            size: wide ? 20 : 18,
            color: c.onAccent,
            stroke: 2.6,
          ),
        ),
      );
    } else if (today) {
      circle = Container(
        key: ValueKey('day-$dayKey'),
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c.accent, width: PantasBorder.ringStrong),
        ),
        child: Text(
          '$number',
          style: PantasType.webLink.copyWith(color: c.accent),
        ),
      );
    } else {
      circle = Semantics(
        label: condensed ? '$date, not counted' : null,
        child: Container(
          key: ValueKey('day-$dayKey'),
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c.fill, shape: BoxShape.circle),
          child: Text(
            '$number',
            style: PantasType.webSub.copyWith(color: c.textSecondary),
          ),
        ),
      );
    }
    final delay = popDelay;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          style: (today ? PantasType.webTag : PantasType.webCaption).copyWith(
            color: today ? c.accent : c.textSecondary,
          ),
        ),
        const SizedBox(height: PantasSpace.s6),
        if (counted && delay != null)
          FbPop(delay: delay, child: circle)
        else
          circle,
      ],
    );
  }
}

/// The Exit Survey row at the foot of the days card.
class ExitSurveyRow extends StatelessWidget {
  const ExitSurveyRow({required this.reward, required this.status, super.key});
  final BetaReward reward;
  final SurveyStatus status;

  void _open(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router != null) unawaited(router.push<void>(surveyPath));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fb;
    final wide = context.fbWide;
    final open = status == SurveyStatus.open;
    final muted =
        status == SurveyStatus.notYet || status == SurveyStatus.closed;
    final value = switch (status) {
      SurveyStatus.notYet => 'Opens ${monthDay(reward.surveyOpensAt)}',
      SurveyStatus.open => 'Until ${monthDay(surveyLastDay(reward))}',
      SurveyStatus.sent => 'Sent',
      SurveyStatus.closed => 'Closed',
    };
    final titleColor = muted ? c.textSecondary : c.textPrimary;
    final valueColor = c.textSecondary;
    final sentValue = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sent',
          style: context.fbBody.copyWith(color: valueColor),
        ),
        const SizedBox(width: PantasSpace.s6),
        FbGlyph(FbGlyphKind.check, size: 16, color: c.accent, stroke: 2.6),
      ],
    );
    if (wide) {
      return WebRow(
        title: 'Exit Survey',
        titleStyle: PantasType.webBody.copyWith(color: titleColor),
        value: status == SurveyStatus.sent ? null : value,
        valueStyle: PantasType.webBody.copyWith(color: valueColor),
        trailing: status == SurveyStatus.sent ? sentValue : null,
        horizontalPadding: 16,
        compact: true,
        divider: false,
        chevron: open ? WebRowChevron.always : WebRowChevron.none,
        onPressed: open ? () => _open(context) : null,
      );
    }
    return ListRow(
      title: 'Exit Survey',
      titleColor: titleColor,
      value: status == SurveyStatus.sent ? null : value,
      valueWidget: status == SurveyStatus.sent ? sentValue : null,
      valueStyle: PantasType.phoneBody.copyWith(color: valueColor),
      hideTrailing: !open,
      onTap: open ? () => _open(context) : null,
    );
  }
}
