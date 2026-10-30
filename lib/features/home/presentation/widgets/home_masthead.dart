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
                Text(dayNote!, style: t.sub),
              ],
            ],
          ),
          WebCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 7; i++)
                  SizedBox(
                    width: 44,
                    child: TextButton(
                      key: ValueKey('web-week-day-$i'),
                      onPressed: () {
                        final date = start.add(Duration(days: i));
                        unawaited(
                          date.isBefore(
                            DateTime(now.year, now.month, now.day),
                          )
                              ? showPlanPastDay(context, date)
                              : context.push<void>('/plan/day/${dayKey(date)}'),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(44, 50),
                      ),
                      child: Opacity(
                        opacity:
                            week.states[i] == WeekDayState.dayOff ? .35 : 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              const [
                                'Sun',
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                              ][i],
                              style: t.style(
                                11,
                                weight: FontWeight.w600,
                                color: t.colors.secondaryLabel,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                if (week.states[i] == WeekDayState.today &&
                                    week.todayFraction > 0 &&
                                    week.todayFraction < 1)
                                  SizedBox.square(
                                    dimension: 34,
                                    child: CircularProgressIndicator(
                                      key: const ValueKey('web-today-progress'),
                                      value: week.todayFraction,
                                      strokeWidth: 2,
                                      strokeCap: StrokeCap.round,
                                      color: t.colors.accent,
                                      backgroundColor: t.colors.separator,
                                    ),
                                  ),
                                Container(
                                  width: 27,
                                  height: 27,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: week.states[i] == WeekDayState.today
                                        ? t.colors.accentFill
                                        : null,
                                    shape: BoxShape.circle,
                                  ),
                                  child: week.states[i] == WeekDayState.today &&
                                          week.todayFraction >= 1
                                      ? const Icon(
                                          Icons.check,
                                          size: 15,
                                          color: Colors.white,
                                        )
                                      : Text(
                                          '${start.add(Duration(days: i)).day}',
                                          style: t.style(
                                            14,
                                            weight: FontWeight.w600,
                                            color: week.states[i] ==
                                                    WeekDayState.today
                                                ? Colors.white
                                                : t.colors.label,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: week.states[i] == WeekDayState.done ||
                                        week.states[i] == WeekDayState.partial
                                    ? t.colors.accent
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: t.colors.separator),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: t.strongDivider),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              child: Text(
                                masthead.examDate == null
                                    ? '+'
                                    : masthead.examDate!.day == null
                                        ? _monthAbbreviation(
                                            masthead.examDate!.month,
                                          )
                                        : '${masthead.examDate!.day!.day}',
                                maxLines: 1,
                                style: t.style(16, weight: FontWeight.w700),
                              ),
                            ),
                            if (masthead.examDate?.day != null)
                              Text(
                                _monthAbbreviation(
                                  masthead.examDate!.month,
                                ),
                                style: t.style(
                                  9,
                                  weight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            masthead.examShortName,
                            style: t.style(13, weight: FontWeight.w700),
                          ),
                          Text(
                            _footer(
                              _stateFor(masthead.examDate, now),
                              masthead.examDate,
                              now,
                            ),
                            style: t.sm,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                child: WeekStrip(
                  today: now,
                  states: week.states,
                  todayFraction: week.todayFraction,
                  onSelected: (date) => unawaited(
                    context.push<void>('/plan/day/${dayKey(date)}'),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const _BridgeDots(),
              const SizedBox(width: 8),
              _ExamChip(
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

class _BridgeDots extends StatelessWidget {
  const _BridgeDots();

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
