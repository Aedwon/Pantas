import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/l10n/app_localizations.dart';

class HomeMasthead extends ConsumerWidget {
  const HomeMasthead({
    required this.examId,
    required this.now,
    this.notice,
    this.greeting,
    super.key,
  });

  final ExamId examId;

  /// The notice strip, drawn between the week and the greeting. It supplies
  /// its own spacing and draws nothing when there is no notice.
  final Widget? notice;

  /// Replaces the hour-band greeting, for example "Welcome back".
  final String? greeting;

  /// Injected so date/greeting states are deterministic in tests.
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headState = ref.watch(homeMastheadProvider);
    final weekState = ref.watch(weekStripProvider(examId));
    if (headState.hasError || weekState.hasError) {
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
    if (masthead == null || week == null) return const FaintBars();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
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
