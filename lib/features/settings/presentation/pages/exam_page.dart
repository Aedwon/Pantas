import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/domain/exam_change_result.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';
import 'package:pantas/features/settings/settings.dart';

class ExamPage extends ConsumerStatefulWidget {
  const ExamPage({super.key});
  @override
  ConsumerState<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends ConsumerState<ExamPage>
    with TickerProviderStateMixin {
  bool _dateOpen = false;
  String? _changedExam;
  String? _previousExam;
  int? _mode;
  String? _error;
  int? _lastDay;
  late final _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final _confirmation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  @override
  void dispose() {
    _confirmation.dispose();
    _shake.dispose();
    super.dispose();
  }

  Future<void> _save(Future<void> Function() action) async {
    try {
      await action();
      if (mounted) setState(() => _error = null);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not save. Please try again.');
    }
  }

  Future<void> _changeExam() async {
    final previous = ref.read(activeExamShortNameProvider);
    final result =
        await context.push<ExamChangeResult>('/settings/exam/change');
    if (result == null) return;
    await result.routeSettled;
    if (!mounted) return;
    ref
      ..invalidate(appPreferencesRepositoryProvider)
      ..invalidate(activeExamFocusProvider);
    await ref.read(activeExamFocusProvider.future);
    if (!mounted) return;
    if (result.carryableCount > 0) {
      await showCarryOverPrompt(
        context: context,
        examShortName: result.examShortName,
        carryableCount: result.carryableCount,
        previousExam: previous,
        onDecision: ({required bool count}) => ref
            .read(settingsActionsProvider)
            .setCarryOverProgress(enabled: count),
      );
    }
    if (mounted) {
      setState(() {
        _changedExam = result.examShortName;
        _previousExam = previous;
      });
      if (MediaQuery.disableAnimationsOf(context)) {
        _confirmation.value = 1;
      } else {
        unawaited(_confirmation.forward(from: 0));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(userSettingsProvider).valueOrNull ?? UserSettings.defaults();
    final actions = ref.read(settingsActionsProvider);
    final date = settings.examDate;
    final now = DateUtils.dateOnly(DateTime.now());
    final mode = _mode ??
        (date == null
            ? 2
            : date.day == null
                ? 1
                : 0);
    final current = date?.day ?? date?.monthStart ?? now;
    final past = date?.day?.isBefore(now) ?? false;
    final monthName = DateFormat.MMMM().format(current);
    void push(String path) => unawaited(context.push<void>(path));
    void saveDate(int year, int month, int? day) {
      final validYear = year < now.year ? now.year : year;
      final validMonth =
          validYear == now.year && month < now.month ? now.month : month;
      final validDay = day?.clamp(
        validYear == now.year && validMonth == now.month ? now.day : 1,
        DateUtils.getDaysInMonth(validYear, validMonth),
      );
      final next = validDay == null
          ? ExamDate.inMonth(year: validYear, month: validMonth)
          : ExamDate.onDay(DateTime(validYear, validMonth, validDay));
      unawaited(_save(() => actions.setExamDate(next, today: now)));
    }

    if (_changedExam != null) {
      return AnimatedBuilder(
        animation: _confirmation,
        builder: (context, _) {
          final rise = PantasCurves.riseIn
              .transform((_confirmation.value * 700 / 450).clamp(0, 1));
          final pop = ((_confirmation.value * 700 - 200) / 500).clamp(0.0, 1.0);
          return Transform.translate(
            key: const ValueKey('exam-confirmation-arrival'),
            offset: Offset(0, 14 * (1 - rise)),
            child: Opacity(
              opacity: rise,
              child: PantasPage(
                title: '',
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Opacity(
                      opacity: pop,
                      child: Transform.scale(
                        scale: .4 + .6 * PantasCurves.popC.transform(pop),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colors.accentFill,
                          ),
                          child: Icon(
                            Icons.check,
                            color: context.colors.onAccent,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    "You're now studying for "
                    '$_changedExam',
                    textAlign: TextAlign.center,
                    style: context.type.pageTitle,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Everything you've done came with you, "
                    'and your plan is rebuilt '
                    'for $_changedExam.',
                    style: context.type.body,
                  ),
                  const SizedBox(height: 24),
                  GroupedSection(
                    footer:
                        'Kept from $_previousExam. Change it if $_changedExam '
                        'falls on a different day.',
                    children: [
                      ListRow(
                        title: 'Exam Date',
                        value: date == null
                            ? 'Not set'
                            : DateFormat(
                                date.day == null ? 'MMMM y' : 'MMM d, y',
                              ).format(current),
                        variant: ListRowVariant.value,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PantasButton(
                    label: 'Change Exam Date',
                    onPressed: () => setState(() {
                      _changedExam = null;
                      _dateOpen = true;
                    }),
                  ),
                  PantasButton(
                    label: 'Done',
                    variant: PantasButtonVariant.tertiary,
                    onPressed: () => setState(() => _changedExam = null),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    return PantasPage(
      title: 'Your exam',
      backLabel: 'Settings',
      onBack: () => Navigator.of(context).maybePop(),
      children: [
        Text(
          "What you're preparing for, when it is, and which days you study.",
          style:
              context.type.body.copyWith(color: context.colors.secondaryLabel),
        ),
        const SizedBox(height: 24),
        GroupedSection(
          footer: past
              ? 'This date has passed. Pick your next exam date, or choose '
                  "I don't know."
              : mode == 2
                  ? 'Your plan keeps a steady pace until you add a date.'
                  : mode == 1
                      ? 'Without a day, your plan defaults to '
                          '$monthName 1 as the '
                          'last day and asks you again later.'
                      : 'When you change your exam date or study days, '
                          'the roadmap '
                          'rebuilds your plan right away. At least one '
                          'day should be '
                          'selected.',
          children: [
            ListRow(
              title: 'Exam',
              value: ref.watch(activeExamShortNameProvider),
              divider: true,
              onTap: () => unawaited(_changeExam()),
            ),
            ListRow(
              title: 'Exam date',
              value: date == null
                  ? 'Not set'
                  : DateFormat(date.day == null ? 'MMMM y' : 'MMM d, y')
                      .format(current),
              valueStyle: context.type.rowValue.copyWith(
                color: past
                    ? context.colors.destructive
                    : context.colors.secondaryLabel,
              ),
              variant: ListRowVariant.inlineEditor,
              expanded: _dateOpen,
              onTap: () => setState(() => _dateOpen = !_dateOpen),
              editor: Column(
                children: [
                  SegmentedSwitch(
                    labels: const [
                      'Exact day',
                      'Month only',
                      "I don't know",
                    ],
                    selected: mode,
                    onChanged: (index) {
                      setState(() => _mode = index);
                      if (index == 2) {
                        unawaited(_save(actions.clearExamDate));
                      } else {
                        saveDate(
                          current.year,
                          current.month,
                          index == 0 ? current.day : null,
                        );
                      }
                    },
                  ),
                  if (mode != 2)
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ValueWheel(
                            values: [
                              for (var m = 1; m <= 12; m++)
                                DateFormat(mode == 0 ? 'MMM' : 'MMMM')
                                    .format(DateTime(2000, m)),
                            ],
                            selectedIndex: current.month - 1,
                            label: 'Month',
                            invalidIndices: {
                              if (current.year <= now.year)
                                for (var m = 0; m < now.month - 1; m++) m,
                            },
                            onSelected: (i) => saveDate(
                              current.year,
                              i + 1,
                              mode == 0 ? current.day : null,
                            ),
                          ),
                        ),
                        if (mode == 0)
                          Expanded(
                            child: ValueWheel(
                              values: [
                                for (var d = 1;
                                    d <=
                                        DateUtils.getDaysInMonth(
                                          current.year,
                                          current.month,
                                        );
                                    d++)
                                  '$d',
                              ],
                              selectedIndex: current.day - 1,
                              label: 'Day',
                              invalidIndices: {
                                if (current.year == now.year &&
                                    current.month == now.month)
                                  for (var d = 0; d < now.day - 1; d++) d,
                              },
                              onSelected: (i) => saveDate(
                                current.year,
                                current.month,
                                i + 1,
                              ),
                            ),
                          ),
                        Expanded(
                          child: ValueWheel(
                            values: [
                              for (var y = now.year;
                                  y <= current.year + 10;
                                  y++)
                                '$y',
                            ],
                            selectedIndex:
                                (current.year - now.year).clamp(0, 999),
                            label: 'Year',
                            onSelected: (i) => saveDate(
                              now.year + i,
                              current.month,
                              mode == 0 ? current.day : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Study days', style: context.type.body),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Row(
                children: [
                  for (final day in [7, 1, 2, 3, 4, 5, 6])
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _shake,
                        builder: (context, child) {
                          final t = _shake.value;
                          final offset = _lastDay == day
                              ? TweenSequence<double>([
                                  for (final p in [
                                    (0.0, -5.0),
                                    (-5.0, 5.0),
                                    (5.0, -3.0),
                                    (-3.0, 3.0),
                                    (3.0, 0.0),
                                  ])
                                    TweenSequenceItem(
                                      tween: Tween(
                                        begin: p.$1,
                                        end: p.$2,
                                      ).chain(
                                        CurveTween(
                                          curve: PantasCurves.easeOut,
                                        ),
                                      ),
                                      weight: 1,
                                    ),
                                ]).transform(t)
                              : 0.0;
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: child,
                          );
                        },
                        child: Semantics(
                          label: DateFormat.EEEE().format(
                            DateTime(2026, 10, 18 + day % 7),
                          ),
                          selected: settings.studyDays.weekdays.contains(day),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: const CircleBorder(),
                              minimumSize: const Size(40, 44),
                              padding: EdgeInsets.zero,
                              backgroundColor:
                                  settings.studyDays.weekdays.contains(day)
                                      ? context.colors.accentFill
                                      : context.colors.fill,
                              foregroundColor:
                                  settings.studyDays.weekdays.contains(day)
                                      ? context.colors.onAccent
                                      : context.colors.secondaryLabel,
                            ),
                            onPressed: () {
                              final next = settings.studyDays.weekdays.toSet();
                              if (!next.add(day)) next.remove(day);
                              if (next.isEmpty) {
                                setState(() => _lastDay = day);
                                if (!MediaQuery.disableAnimationsOf(
                                  context,
                                )) {
                                  _shake.forward(from: 0);
                                }
                                return;
                              }
                              setState(() => _lastDay = null);
                              unawaited(
                                _save(
                                  () => actions.updateStudyDays(
                                    StudyDays(next),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              const [
                                'M',
                                'T',
                                'W',
                                'T',
                                'F',
                                'S',
                                'S',
                              ][day - 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_lastDay != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'At least one day stays on.',
                  style: context.type.footnote,
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        GroupedSection(
          footer: 'Answers from your other exams count toward this one. '
              'Nothing is ever deleted.',
          children: [
            ListRow(
              title: 'Carry over progress',
              variant: ListRowVariant.switchControl,
              selected: settings.carryOverProgress,
              onTap: () => unawaited(
                _save(
                  () => actions.setCarryOverProgress(
                    enabled: !settings.carryOverProgress,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GroupedSection(
          footer: 'Topics you leave out drop out of your plan.',
          children: [
            ListRow(
              title: "What's included",
              value: 'All subjects',
              onTap: () => push('/settings/exam/included'),
            ),
          ],
        ),
        if (_error != null) Text(_error!, style: context.type.footnote),
      ],
    );
  }
}
