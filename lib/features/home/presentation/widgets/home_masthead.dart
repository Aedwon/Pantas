import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/page_title.dart';
import 'package:pantas/core/ui/components/pantas_tap_area.dart';
import 'package:pantas/core/ui/components/pantas_tooltip.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
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
                const SizedBox(height: PantasSpace.s4),
                Text(
                  greeting ?? greetingFor(now, AppLocalizations.of(context)),
                  style: context.webTokens.h1,
                ),
              ],
            ),
            if (!headState.hasError && !weekState.hasError)
              SizedBox(
                width: PantasLayout.colPrimary.basis,
                child: const HomeWebLoading(header: true),
              ),
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
              const SizedBox(height: PantasSpace.s4),
              Text(
                greeting ?? greetingFor(now, AppLocalizations.of(context)),
                style: t.h1,
              ),
              if (dayNote != null) ...[
                const SizedBox(height: PantasSpace.s4),
                // Board `.lead`: 17 px.
                Text(
                  dayNote!,
                  style: PantasType.webLead
                      .copyWith(height: 1.45, color: t.colors.textSecondary),
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
            onDay: (date) =>
                date.isBefore(DateTime(now.year, now.month, now.day))
                    ? showPlanPastDay(context, date)
                    : context.push<void>('/plan/day/${dayKey(date)}'),
          ),
        ],
      );
    }
    final c = context.colors;
    final examState = _stateFor(masthead.examDate, now);
    final chip = _ExamChip(
      key: const ValueKey('masthead-exam-chip'),
      masthead: masthead,
      state: examState,
      footer: _footer(examState, masthead.examDate, now),
    );
    final strip = WeekStrip(
      today: now,
      states: week.states,
      todayFraction: week.todayFraction,
      onSelected: (date) => unawaited(
        context.push<void>('/plan/day/${dayKey(date)}'),
      ),
    );
    // From 600 up the chip stays beside the days after a hairline; under it
    // the chip takes its own line, 4 px in, with no rule (D185).
    final beside =
        MediaQuery.sizeOf(context).width >= PantasLayout.bpTabletPortrait;
    final footer = _footer(examState, masthead.examDate, now);
    Widget hairlineChip({required double right}) => Container(
          padding: EdgeInsets.only(left: PantasSpace.s12, right: right),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: c.divider, width: PantasBorder.hairline),
            ),
          ),
          child: chip,
        );
    // D196: on the phone the full chip stays on one line and the strip shows
    // as many days as fit (5, 4 or 3), centered on Today; under three the
    // chip drops below.
    Widget phoneBody() => LayoutBuilder(
          builder: (context, box) {
            final plan = WeekStrip.plan(
              width: box.maxWidth,
              cell: WeekStrip.cellWidth(context),
              chip: _chipBlockWidth(context, masthead, footer),
            );
            final today = DateTime(now.year, now.month, now.day);
            final before = (plan.days - 1) ~/ 2;
            final first = DateTime(today.year, today.month, today.day - before);
            final weekStart = PantasDates.weekStart(now);
            final days = WeekStrip.window(
              today: now,
              windowStart: first,
              windowGap: plan.touching ? 0 : null,
              states: [
                for (var i = 0; i < plan.days; i++)
                  week.stateOn(
                    DateTime(first.year, first.month, first.day + i),
                    weekStart,
                  ),
              ],
              todayFraction: week.todayFraction,
              onSelected: (date) => unawaited(
                context.push<void>('/plan/day/${dayKey(date)}'),
              ),
            );
            if (!plan.chipBeside) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  days,
                  const SizedBox(height: PantasSpace.s8),
                  Padding(
                    padding: const EdgeInsets.only(left: PantasSpace.s4),
                    child: chip,
                  ),
                ],
              );
            }
            if (plan.touching) {
              return Row(
                children: [
                  days,
                  const Spacer(),
                  hairlineChip(right: PantasSpace.s0),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: PantasSpace.s4),
                    child: days,
                  ),
                ),
                hairlineChip(right: PantasSpace.s0),
              ],
            );
          },
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: BorderRadius.circular(PantasRadius.xl),
          ),
          foregroundDecoration: Theme.of(context).brightness == Brightness.dark
              ? BoxDecoration(
                  border: Border.all(color: c.edgeCard),
                  borderRadius: BorderRadius.circular(PantasRadius.xl),
                )
              : null,
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s8,
            PantasSpace.s8,
            PantasSpace.s10,
            PantasSpace.s8,
          ),
          child: !beside
              ? phoneBody()
              : Row(
                  children: [
                    Expanded(child: strip),
                    Container(
                      margin: const EdgeInsets.only(left: PantasSpace.s8),
                      padding: const EdgeInsets.only(
                        left: PantasSpace.s12,
                        right: PantasSpace.s4,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: c.divider,
                            width: PantasBorder.hairline,
                          ),
                        ),
                      ),
                      child: chip,
                    ),
                  ],
                ),
        ),
        const SizedBox(height: PantasSpace.s24),
        if (notice != null) notice!,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s4),
          child: PantasTitle(
            greeting ?? greetingFor(now, AppLocalizations.of(context)),
            style: context.type.largeTitle,
          ),
        ),
      ],
    );
  }
}

/// The width of the chip with its hairline and 12 of padding, measured from
/// its text at the current text size (tile, 10 gap, the wider of the name and
/// the days line).
double _chipBlockWidth(
  BuildContext context,
  HomeMastheadData masthead,
  String footer,
) {
  final scaler = MediaQuery.textScalerOf(context);
  double width(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: scaler,
    )..layout();
    final result = painter.width;
    painter.dispose();
    return result;
  }

  final tile =
      (PantasSpace.s40 + PantasSpace.s2) * scaler.scale(1).clamp(1.0, 2.0);
  final text = math.max(
    width(masthead.examShortName, PantasType.webChipName),
    width(footer, PantasType.webSmall),
  );
  return PantasBorder.hairline +
      PantasSpace.s12 +
      tile +
      PantasSpace.s10 +
      text +
      1;
}

enum _ExamChipState { noDate, monthOnly, future, today, passed }

/// ExamChip: the calendar tile and, beside it, the exam name and the days
/// left. Not interactive; the date is changed from the exam row.
class _ExamChip extends StatelessWidget {
  const _ExamChip({
    required this.masthead,
    required this.state,
    required this.footer,
    super.key,
  });

  final HomeMastheadData masthead;
  final _ExamChipState state;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final noDateOrToday =
        state == _ExamChipState.today || state == _ExamChipState.noDate;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WebExamTile(
          date: masthead.examDate,
          state: state,
          monthAbbreviation: _monthAbbreviation,
        ),
        const SizedBox(width: PantasSpace.s10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                masthead.examShortName,
                style: PantasType.webChipName.copyWith(color: c.textPrimary),
              ),
              Text(
                footer,
                style: PantasType.webSmall.copyWith(
                  color: noDateOrToday ? c.accent : c.textSecondary,
                ),
              ),
            ],
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
    required this.onDay,
  });
  final DateTime now;
  final DateTime start;
  final HomeWeekStripData week;
  final HomeMastheadData masthead;
  final String footer;

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
    final examState = _stateFor(masthead.examDate, widget.now);
    return WebCard(
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s8,
        PantasSpace.s8,
        PantasSpace.s10,
        PantasSpace.s8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 7; i++) ...[
            if (i > 0) const SizedBox(width: PantasSpace.s4),
            _WebWeekDay(
              key: ValueKey('web-week-day-$i'),
              label: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][i],
              day: start.add(Duration(days: i)).day,
              date: start.add(Duration(days: i)),
              state: week.states[i],
              todayFraction: week.todayFraction,
              planned: start.add(Duration(days: i)).isAfter(widget.now),
              selected: _open == start.add(Duration(days: i)),
              onPressed: () => unawaited(_tap(start.add(Duration(days: i)))),
            ),
          ],
          // `.exam`: margin-left 4 after the 4 px gap, 12 px padding.
          Container(
            margin: const EdgeInsets.only(left: PantasSpace.s8),
            padding: const EdgeInsets.only(
              left: PantasSpace.s12,
              right: PantasSpace.s4,
            ),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: t.colors.divider,
                  width: webHairline(context),
                ),
              ),
            ),
            child: _ExamChip(
              key: const ValueKey('masthead-exam-chip'),
              masthead: masthead,
              state: examState,
              footer: footer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Board `.exam` tile: 42 wide, 36 tall at least. A day to come keeps the
/// label color. Today is teal, a passed date is gray and no date is a dashed
/// gray tile.
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
    final muted = t.colors.textSecondary;
    final text = noDate || passed ? muted : t.colors.textPrimary;
    final outline = noDate
        ? t.colors.borderControl
        : passed
            ? muted
            : today
                ? t.colors.accent
                : t.colors.textPrimary;
    final day = date?.day;
    // 2.625 rem wide, so "DEC" stays inside the tile at 200% text.
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final tile = Container(
      width: (PantasSpace.s40 + PantasSpace.s2) * scale,
      constraints: const BoxConstraints(minHeight: PantasSize.btnXs),
      alignment: Alignment.center,
      decoration: noDate
          ? null
          : BoxDecoration(
              border: Border.all(
                color: outline,
                width: passed ? PantasBorder.ring : PantasBorder.ringStrong,
              ),
              borderRadius: BorderRadius.circular(PantasRadius.sm),
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
            style: PantasType.webGlyph.copyWith(height: 1, color: text),
          ),
          if (day != null)
            Text(
              monthAbbreviation(date!.month),
              style: PantasType.webPro.copyWith(
                color: t.colors.textSecondary,
              ),
            ),
        ],
      ),
    );
    final name = date == null
        ? 'No exam date'
        : day == null
            ? DateFormat('MMMM', 'en_US').format(DateTime(2000, date!.month))
            : DateFormat('MMMM d', 'en_US').format(day);
    return Semantics(
      image: true,
      label: name,
      excludeSemantics: true,
      child: noDate
          ? CustomPaint(
              key: const ValueKey('web-exam-tile-dashed'),
              foregroundPainter: _DashedTilePainter(color: outline),
              child: tile,
            )
          : tile,
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
          const Radius.circular(PantasRadius.sm),
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
    required this.date,
    required this.state,
    required this.todayFraction,
    required this.planned,
    required this.onPressed,
    this.selected = false,
    super.key,
  });
  final bool selected;
  final String label;
  final int day;
  final DateTime date;
  final WeekDayState state;
  final double todayFraction;

  /// Whether the day is after today, so a day with no mark is "Planned".
  final bool planned;
  final VoidCallback onPressed;
  @override
  State<_WebWeekDay> createState() => _WebWeekDayState();
}

class _WebWeekDayState extends State<_WebWeekDay> {
  bool _hover = false;

  /// The status the day's tooltip states, or null for a day with none
  /// (WeekStrip, D186). Today always reads "Today".
  String? get _status => switch (widget.state) {
        WeekDayState.today => 'Today',
        WeekDayState.done => 'Done',
        WeekDayState.partial => 'Partly done',
        WeekDayState.missed => 'No study',
        WeekDayState.plain => widget.planned ? 'Planned' : null,
        WeekDayState.dayOff => null,
      };

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final c = t.colors;
    final today = widget.state == WeekDayState.today;
    final dayOff = widget.state == WeekDayState.dayOff ||
        widget.state == WeekDayState.missed;
    final fraction = widget.todayFraction;
    final status = _status;
    final dot = switch (widget.state) {
      WeekDayState.done => c.accent,
      WeekDayState.partial => null,
      _ => Colors.transparent,
    };
    final disc = Container(
      width: PantasSize.task,
      height: PantasSize.task,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: today ? c.accentFill : null,
        shape: BoxShape.circle,
      ),
      child: Text(
        '${widget.day}',
        style: today
            ? PantasType.webGlyph.copyWith(color: c.onAccent)
            : PantasType.webNav.copyWith(
                color: dayOff ? c.textSecondary : c.textPrimary,
                fontWeight: dayOff ? FontWeight.w400 : null,
              ),
      ),
    );
    final radius = BorderRadius.circular(PantasRadius.md);
    final cell = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: WebKeyboardRing(
        borderRadius: radius,
        child: PantasTapArea(
          onTap: widget.onPressed,
          borderRadius: radius,
          wash: false,
          focusRing: false,
          child: Container(
            width: PantasSize.weekDay,
            padding: const EdgeInsets.symmetric(vertical: PantasSpace.s4),
            decoration: BoxDecoration(
              color: _hover ? c.surfaceHover : null,
              borderRadius: radius,
            ),
            foregroundDecoration: widget.selected
                ? BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(
                      color: c.accent,
                      width: PantasBorder.ringSelected,
                    ),
                  )
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: PantasType.webKeyHintSm.copyWith(
                    fontWeight: today
                        ? FontWeight.w700
                        : dayOff
                            ? FontWeight.w400
                            : null,
                    color: today ? c.accent : c.textSecondary,
                  ),
                ),
                const SizedBox(height: PantasSpace.s2),
                SizedBox(
                  height: PantasSpace.s28 + PantasSpace.s2,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // The ring stays through 100%. The check pops in over the
                      // digit as the ring finishes.
                      if (today && fraction > 0)
                        ProgressRing(
                          key: const ValueKey('web-today-progress'),
                          size: PantasSize.avatarLg - PantasSpace.s10,
                          fraction: fraction,
                          child: disc,
                        )
                      else
                        disc,
                    ],
                  ),
                ),
                const SizedBox(height: PantasSpace.s2),
                Container(
                  width: PantasSize.accuracyBar,
                  height: PantasSize.accuracyBar,
                  decoration: BoxDecoration(
                    color: dot,
                    shape: BoxShape.circle,
                    gradient: dot == null
                        ? LinearGradient(
                            stops: const [.5, .5],
                            colors: [c.accent, c.dividerStrong],
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (status == null) {
      return Semantics(
        label: PantasDates.heading(widget.date),
        button: true,
        selected: widget.selected,
        excludeSemantics: true,
        onTap: widget.onPressed,
        child: cell,
      );
    }
    // The status tooltip replaces the legend (D186). It lives in the overlay,
    // so the strip cannot clip it; a pointer waits 500 ms and a keyboard
    // focus shows it at once.
    return Semantics(
      label: '${PantasDates.heading(widget.date)}, ${status.toLowerCase()}',
      button: true,
      selected: widget.selected,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: PantasTooltip(
        message: status,
        describesAnchor: false,
        child: cell,
      ),
    );
  }
}
