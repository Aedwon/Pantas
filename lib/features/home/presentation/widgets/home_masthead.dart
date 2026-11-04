import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/features/home/presentation/plan_screen.dart';
import 'package:pantas/features/home/presentation/widgets/home_skeletons.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/l10n/app_localizations.dart';

class HomeMasthead extends ConsumerWidget {
  const HomeMasthead({
    required this.examId,
    required this.now,
    this.notice,
    this.greeting,
    this.dayNote,
    this.web = kIsWeb,
    super.key,
  });

  final bool web;
  final ExamId examId;

  /// The notice strip, drawn between the week and the greeting. It supplies
  /// its own spacing and draws nothing when there is no notice.
  final Widget? notice;

  /// Replaces the hour-band greeting, for example "Welcome back".
  final String? greeting;
  final String? dayNote;

  /// Injected so date/greeting states are deterministic in tests.
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headState = ref.watch(homeMastheadProvider);
    final weekState = ref.watch(weekStripProvider(examId));
    if ((headState.hasError || weekState.hasError) && !context.wideWeb) {
      return errorFor(
        'plan',
        () {
          ref
            ..invalidate(homeMastheadProvider)
            ..invalidate(weekStripProvider(examId));
        },
        boardLayout: true,
      );
    }
    final masthead = headState.valueOrNull;
    final week = weekState.valueOrNull;
    if (masthead == null || week == null) {
      if (isWideWebLayout(width: MediaQuery.sizeOf(context).width, web: web)) {
        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 20,
          runSpacing: 20,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d', 'en_US').format(now),
                  style: context.webTokens.sub,
                ),
                const SizedBox(height: 4),
                Text(
                  greeting ?? greetingFor(now, AppLocalizations.of(context)),
                  style: context.webTokens.h1,
                ),
              ],
            ),
            if (!headState.hasError && !weekState.hasError)
              const SizedBox(width: 480, child: HomeWebLoading(header: true)),
          ],
        );
      }
      return const HomeMastheadSkeleton();
    }

    if (isWideWebLayout(width: MediaQuery.sizeOf(context).width, web: web)) {
      final start = PantasDates.weekStart(now);
      final t = context.webTokens;
      return Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 20,
        runSpacing: 20,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d', 'en_US').format(now),
                style: t.sub,
              ),
              const SizedBox(height: 4),
              Text(
                greeting ?? greetingFor(now, AppLocalizations.of(context)),
                style: t.h1,
              ),
              if (dayNote != null) ...[
                const SizedBox(height: 4),
                // Board `.lead`: 17 px.
                Text(
                  dayNote!,
                  style: t.style(
                    17,
                    height: 1.45,
                    color: t.colors.secondaryLabel,
                  ),
                ),
              ],
            ],
          ),
          _WebWeekCard(
            now: now,
            start: start,
            week: week,
            masthead: masthead,
            footer: _footer(
              _stateFor(masthead.examDate, now),
              masthead.examDate,
              now,
            ),
            monthAbbreviation: _monthAbbreviation,
            onDay: (date) =>
                date.isBefore(DateTime(now.year, now.month, now.day))
                    ? showPlanPastDay(context, date)
                    : context.push<void>('/plan/day/${dayKey(date)}'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          foregroundDecoration: Theme.of(context).brightness == Brightness.dark
              ? BoxDecoration(
                  border: Border.all(color: context.colors.cardEdge),
                  borderRadius: BorderRadius.circular(18),
                )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // The dots sit between the last day's number and the tile,
                    // not between the last cell's edge and the tile. The last
                    // number is centered in its cell, so the cell edge is
                    // further right than the number the eye reads.
                    final inset = WeekStrip.lastDayInset(
                      context,
                      width: constraints.maxWidth,
                      today: now,
                      states: week.states,
                      todayFraction: week.todayFraction,
                    );
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        WeekStrip(
                          today: now,
                          states: week.states,
                          todayFraction: week.todayFraction,
                          onSelected: (date) => unawaited(
                            context.push<void>('/plan/day/${dayKey(date)}'),
                          ),
                        ),
                        Positioned(
                          left: constraints.maxWidth +
                              (_stripToChipGap - _BridgeDots.width - inset) / 2,
                          top: 0,
                          child: const _BridgeDots(
                            key: ValueKey('masthead-bridge-dots'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: _stripToChipGap),
              _ExamChip(
                key: const ValueKey('masthead-exam-chip'),
                examShortName: masthead.examShortName,
                examDate: masthead.examDate,
                now: now,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (notice != null) notice!,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            greeting ?? greetingFor(now, AppLocalizations.of(context)),
            style: context.type.largeTitle,
          ),
        ),
      ],
    );
  }
}

/// Space between the week strip's right edge and the exam tile. The dots sit
/// in it, centered between the last day's number and the tile.
const double _stripToChipGap = 29;

class _BridgeDots extends StatelessWidget {
  const _BridgeDots({super.key});

  /// Three 3 px dots with 3 px gaps.
  static const double width = 15;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 29),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < 3; index++) ...[
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: context.colors.chevron,
                shape: BoxShape.circle,
              ),
            ),
            if (index != 2) const SizedBox(width: 3),
          ],
        ],
      ),
    );
  }
}

enum _ExamChipState { noDate, monthOnly, future, today, passed }

class _ExamChip extends StatelessWidget {
  const _ExamChip({
    required this.examShortName,
    required this.examDate,
    required this.now,
    super.key,
  });

  final String examShortName;
  final ExamDate? examDate;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final calendarWidth = 40 + (32 * (scale - 1));
    final calendarHeight = 32 + (16 * (scale - 1));
    final state = _stateFor(examDate, now);
    final filled = state == _ExamChipState.today;
    final passed = state == _ExamChipState.passed;
    final borderColor = passed
        ? colors.inactiveDateLabel
        : state == _ExamChipState.noDate
            ? colors.accent
            : filled
                ? colors.accentFill
                : colors.label;
    final foreground = filled
        ? colors.onAccent
        : passed
            ? colors.secondaryLabel
            : colors.label;

    return SizedBox(
      width: calendarWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            examShortName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.captionStrong.copyWith(
              color: colors.label,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: calendarWidth,
            height: calendarHeight,
            decoration: BoxDecoration(
              color: filled ? colors.accentFill : colors.transparent,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            alignment: Alignment.center,
            child: _calendarContent(context, state, foreground),
          ),
          const SizedBox(height: 2),
          Text(
            _footer(state, examDate, now),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.captionSmall.copyWith(
              fontSize: 9,
              height: 1.1,
              color: switch (state) {
                _ExamChipState.today || _ExamChipState.noDate => colors.accent,
                _ => colors.secondaryLabel,
              },
              fontWeight: state == _ExamChipState.today
                  ? FontWeight.w700
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarContent(
    BuildContext context,
    _ExamChipState state,
    Color foreground,
  ) {
    if (state == _ExamChipState.noDate) {
      return Text(
        '+',
        style: context.type.emphasized.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: context.colors.accent,
        ),
      );
    }

    final date = examDate!;
    if (state == _ExamChipState.monthOnly) {
      return Text(
        _monthAbbreviation(date.month),
        style: context.type.captionStrong.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    final day = date.day!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${day.day}',
          style: context.type.footnote.copyWith(
            fontWeight: FontWeight.w700,
            color: foreground,
            height: 1,
          ),
        ),
        Text(
          _monthAbbreviation(day.month),
          style: context.type.captionSmall.copyWith(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: state == _ExamChipState.today
                ? context.colors.onAccent
                : context.colors.secondaryLabel,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

_ExamChipState _stateFor(ExamDate? date, DateTime now) {
  if (date == null) return _ExamChipState.noDate;
  if (date.precision == ExamDatePrecision.month) {
    return _ExamChipState.monthOnly;
  }
  final days = date.daysUntil(now)!;
  if (days < 0) return _ExamChipState.passed;
  if (days == 0) return _ExamChipState.today;
  return _ExamChipState.future;
}

String _footer(_ExamChipState state, ExamDate? date, DateTime now) {
  return switch (state) {
    _ExamChipState.noDate => 'Add date',
    _ExamChipState.monthOnly => 'in ${_monthTitle(date!.month)}',
    _ExamChipState.today => 'Today',
    _ExamChipState.passed => 'Passed',
    _ExamChipState.future => () {
        final days = date!.daysUntil(now)!;
        return '$days ${days == 1 ? 'day' : 'days'}';
      }(),
  };
}

String _monthAbbreviation(int month) => const [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ][month - 1];

String _monthTitle(int month) => const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];

@visibleForTesting
String greetingFor(DateTime now, [AppLocalizations? l10n]) {
  final h = now.hour;
  final timeOfDay = h < 12
      ? 'umaga'
      : h < 18
          ? 'hapon'
          : 'gabi';
  if (l10n != null) return l10n.greeting(timeOfDay);
  return 'Magandang $timeOfDay';
}

/// Board `.week`: day cells 44 px wide with 4 px gaps, then the exam tile.
class _WebWeekCard extends StatefulWidget {
  const _WebWeekCard({
    required this.now,
    required this.start,
    required this.week,
    required this.masthead,
    required this.footer,
    required this.monthAbbreviation,
    required this.onDay,
  });
  final DateTime now;
  final DateTime start;
  final HomeWeekStripData week;
  final HomeMastheadData masthead;
  final String footer;
  final String Function(int month) monthAbbreviation;

  /// Resolves when what the tap opened is closed again.
  final Future<void> Function(DateTime) onDay;

  @override
  State<_WebWeekCard> createState() => _WebWeekCardState();
}

class _WebWeekCardState extends State<_WebWeekCard> {
  /// The day whose popover is open: board PL_DayPast marks it in the strip.
  DateTime? _open;

  Future<void> _tap(DateTime date) async {
    setState(() => _open = date);
    try {
      await widget.onDay(date);
    } finally {
      if (mounted) setState(() => _open = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final start = widget.start;
    final week = widget.week;
    final masthead = widget.masthead;
    final footer = widget.footer;
    final monthAbbreviation = widget.monthAbbreviation;
    final off = t.dark ? t.colors.tertiaryLabel : const Color(0xFFC7C7CC);
    final date = masthead.examDate;
    final examState = _stateFor(date, widget.now);
    return WebCard(
      padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 7; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            _WebWeekDay(
              key: ValueKey('web-week-day-$i'),
              label: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][i],
              day: start.add(Duration(days: i)).day,
              state: week.states[i],
              todayFraction: week.todayFraction,
              off: off,
              selected: _open == start.add(Duration(days: i)),
              onPressed: () => unawaited(_tap(start.add(Duration(days: i)))),
            ),
          ],
          // `.exam`: margin-left 4 after the 4 px gap, 12 px padding.
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.only(left: 12, right: 4),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: t.colors.separator,
                  width: webHairline(context),
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _WebExamTile(
                  date: date,
                  state: examState,
                  monthAbbreviation: monthAbbreviation,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      masthead.examShortName,
                      style: t.style(13, weight: FontWeight.w700, height: 1.3),
                    ),
                    Text(
                      footer,
                      style: examState == _ExamChipState.today ||
                              examState == _ExamChipState.noDate
                          ? t.sm.copyWith(color: t.colors.accent)
                          : t.sm,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Board `.exam` tile: 42 by 36. A day to come keeps the label color. Today
/// is teal, a passed date is gray and no date is a dashed gray tile.
class _WebExamTile extends StatelessWidget {
  const _WebExamTile({
    required this.date,
    required this.state,
    required this.monthAbbreviation,
  });
  final ExamDate? date;
  final _ExamChipState state;
  final String Function(int month) monthAbbreviation;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final noDate = state == _ExamChipState.noDate;
    final passed = state == _ExamChipState.passed;
    final today = state == _ExamChipState.today;
    final muted = t.disabledText;
    final text = noDate || passed ? muted : t.colors.label;
    final outline = noDate || passed
        ? muted
        : today
            ? t.colors.accent
            : t.colors.label;
    final day = date?.day;
    final tile = Container(
      width: 42,
      height: 36,
      alignment: Alignment.center,
      decoration: noDate
          ? null
          : BoxDecoration(
              border: Border.all(
                color: outline,
                width: passed ? 1 : 1.5,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            date == null
                ? '+'
                : day == null
                    ? monthAbbreviation(date!.month)
                    : '${day.day}',
            maxLines: 1,
            style: t.style(
              14,
              weight: FontWeight.w700,
              height: 1,
              color: text,
            ),
          ),
          if (day != null)
            Text(
              monthAbbreviation(date!.month),
              style: t.style(
                9,
                weight: FontWeight.w700,
                height: 1.2,
                color: t.colors.secondaryLabel,
              ),
            ),
        ],
      ),
    );
    if (!noDate) return tile;
    return CustomPaint(
      key: const ValueKey('web-exam-tile-dashed'),
      foregroundPainter: _DashedTilePainter(color: outline),
      child: tile,
    );
  }
}

class _DashedTilePainter extends CustomPainter {
  const _DashedTilePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(.6),
          const Radius.circular(9),
        ),
      );
    for (final metric in outline.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += 6) {
        canvas.drawPath(metric.extractPath(at, at + 3), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedTilePainter old) => old.color != color;
}

/// Board `.wd`: 44 px wide, 4 px padding, 2 px gaps: label, 30 px number
/// row, 5 px dot.
class _WebWeekDay extends StatefulWidget {
  const _WebWeekDay({
    required this.label,
    required this.day,
    required this.state,
    required this.todayFraction,
    required this.off,
    required this.onPressed,
    this.selected = false,
    super.key,
  });
  final bool selected;
  final String label;
  final int day;
  final WeekDayState state;
  final double todayFraction;
  final Color off;
  final VoidCallback onPressed;
  @override
  State<_WebWeekDay> createState() => _WebWeekDayState();
}

class _WebWeekDayState extends State<_WebWeekDay> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final today = widget.state == WeekDayState.today;
    final dayOff = widget.state == WeekDayState.dayOff;
    final fraction = widget.todayFraction;
    final dot = switch (widget.state) {
      WeekDayState.done => t.colors.accent,
      WeekDayState.partial => null,
      _ => Colors.transparent,
    };
    final disc = Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: today ? t.colors.accentFill : null,
        shape: BoxShape.circle,
      ),
      child: Text(
        '${widget.day}',
        style: today
            ? t.style(
                14,
                weight: FontWeight.w700,
                color: Colors.white,
              )
            : t.style(
                15,
                weight: FontWeight.w500,
                color: dayOff ? widget.off : null,
              ),
      ),
    );
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: _hover || widget.selected
                ? (t.dark ? t.colors.fill : const Color(0xFFF2F2F5))
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: t.style(
                  11,
                  weight: today ? FontWeight.w700 : FontWeight.w600,
                  height: 1.27,
                  color: dayOff
                      ? widget.off
                      : today
                          ? t.colors.accent
                          : t.colors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 30,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // The ring stays through 100%. The check pops in over the
                    // digit as the ring finishes (420 ms, popC).
                    if (today && fraction > 0)
                      ProgressRing(
                        key: const ValueKey('web-today-progress'),
                        size: 34,
                        fraction: fraction,
                        child: disc,
                      )
                    else
                      disc,
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: dot,
                  shape: BoxShape.circle,
                  gradient: dot == null
                      ? LinearGradient(
                          stops: const [.5, .5],
                          colors: [t.colors.accent, const Color(0xFFD1D1D6)],
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
