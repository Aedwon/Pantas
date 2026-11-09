import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/core/ui/components/day_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/settings/domain/exam_change_result.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_row.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';
import 'package:pantas/features/settings/settings.dart';

// The wide date-mode control's width on the approved board; the system's
// SegmentedControl sets no width of its own.
const double _dateModesWidth = 424;

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
  bool _carried = false;
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
    final telemetry = ref.read(telemetryProvider);
    try {
      await action();
      if (mounted) setState(() => _error = null);
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
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
    var carried = false;
    if (result.carryableCount > 0) {
      carried = (await showCarryOverPrompt(
            context: context,
            examShortName: result.examShortName,
            carryableCount: result.carryableCount,
            previousExam: previous,
            onDecision: ({required bool count}) => ref
                .read(settingsActionsProvider)
                .setCarryOverProgress(enabled: count),
          )) ??
          false;
    }
    if (mounted) {
      setState(() {
        _changedExam = result.examShortName;
        _previousExam = previous;
        _carried = carried;
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
    final examId = ref.watch(activeExamFocusProvider).valueOrNull?.exam?.id;
    final excludedTopics = examId == null
        ? null
        : ref.watch(trackScopeProvider(examId)).valueOrNull;
    final excludedLessons = examId == null
        ? null
        : ref.watch(lessonScopeProvider(examId)).valueOrNull;
    final leftOut = (excludedTopics?.isNotEmpty ?? false) ||
        (excludedLessons?.isNotEmpty ?? false);
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
          final rise = PantasCurves.enter
              .transform((_confirmation.value * 700 / 450).clamp(0, 1));
          final pop = ((_confirmation.value * 700 - 200) / 500).clamp(0.0, 1.0);
          return Transform.translate(
            key: const ValueKey('exam-confirmation-arrival'),
            offset: Offset(0, 14 * (1 - rise)),
            child: Opacity(
              opacity: rise,
              child: SettingsPanePage(
                section: 'Your exam',
                // Wide web keeps the pane's heading; the phone board is a bare
                // page.
                title: context.wideWeb ? 'Your exam' : '',
                children: [
                  const SizedBox(height: PantasSpace.s56),
                  Center(
                    child: Opacity(
                      opacity: pop,
                      child: Transform.scale(
                        scale: .4 + .6 * PantasCurves.spring.transform(pop),
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
                  const SizedBox(height: PantasSpace.s28),
                  Text(
                    "You're now studying for "
                    '$_changedExam',
                    textAlign: TextAlign.center,
                    style: context.type.pageTitle,
                  ),
                  const SizedBox(height: PantasSpace.s12),
                  Text(
                    _carried
                        ? "Everything you've done came with you, and your "
                            'plan is rebuilt for $_changedExam.'
                        : 'Your plan is rebuilt for $_changedExam.',
                    textAlign: TextAlign.center,
                    style: context.type.body,
                  ),
                  const SizedBox(height: PantasSpace.s24),
                  SettingsSection(
                    footer: date == null
                        ? null
                        : 'Kept from $_previousExam. '
                            'Change it if $_changedExam '
                            'falls on a different day.',
                    children: [
                      SettingsRow(
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
                  const SizedBox(height: PantasSpace.s24),
                  Center(
                    child: PantasButton(
                      label: 'Change Exam Date',
                      onPressed: () => setState(() {
                        _changedExam = null;
                        _dateOpen = true;
                      }),
                    ),
                  ),
                  Center(
                    child: PantasButton(
                      label: 'Done',
                      variant: PantasButtonVariant.tertiary,
                      onPressed: () => setState(() => _changedExam = null),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    Widget studyDay(int day) => AnimatedBuilder(
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
                            curve: PantasBoardCurves.easeOut,
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
              // ds-raw: circle day toggle, no system component
              key: ValueKey('study-day-$day'),
              style: TextButton.styleFrom(
                // ds-raw: same button, circle day toggle
                shape: const CircleBorder(),
                minimumSize: const Size.square(PantasSize.targetTouch),
                fixedSize: const Size.square(PantasSize.targetTouch),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: PantasType.webLink,
                padding: EdgeInsets.zero,
                backgroundColor: settings.studyDays.weekdays.contains(day)
                    ? context.colors.accentFill
                    : context.colors.fill,
                foregroundColor: settings.studyDays.weekdays.contains(day)
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
        );

    Widget dateModes() => SegmentedSwitch(
          labels: const [
            'Exact day',
            'Month only',
            "I don't know",
          ],
          selected: mode,
          onChanged: (index) {
            setState(() => _mode = index);
            // With no date set, the pickers open on today but nothing is saved
            // until the student picks one, so no date is made up.
            if (index == 2) {
              unawaited(_save(actions.clearExamDate));
            } else if (date != null) {
              saveDate(
                current.year,
                current.month,
                index == 0 ? current.day : null,
              );
            }
          },
        );

    Widget phoneWheels() => Row(
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
                    if (current.year == now.year && current.month == now.month)
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
                  for (var y = now.year; y <= current.year + 10; y++) '$y',
                ],
                selectedIndex: (current.year - now.year).clamp(0, 999),
                label: 'Year',
                onSelected: (i) => saveDate(
                  now.year + i,
                  current.month,
                  mode == 0 ? current.day : null,
                ),
              ),
            ),
          ],
        );

    Widget webPickers() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WebPickerColumn(
              label: 'Month',
              values: [
                for (var m = 1; m <= 12; m++)
                  DateFormat(mode == 0 ? 'MMM' : 'MMMM')
                      .format(DateTime(2000, m)),
              ],
              selectedIndex: current.month - 1,
              disabledIndices: {
                if (current.year <= now.year)
                  for (var m = 0; m < now.month - 1; m++) m,
              },
              onSelected: (i) => saveDate(
                current.year,
                i + 1,
                mode == 0 ? current.day : null,
              ),
            ),
            if (mode == 0) ...[
              const SizedBox(width: PantasSpace.s12),
              WebPickerColumn(
                label: 'Day',
                values: [
                  for (var d = 1;
                      d <=
                          DateUtils.getDaysInMonth(current.year, current.month);
                      d++)
                    '$d',
                ],
                selectedIndex: current.day - 1,
                disabledIndices: {
                  if (current.year == now.year && current.month == now.month)
                    for (var d = 0; d < now.day - 1; d++) d,
                },
                onSelected: (i) => saveDate(current.year, current.month, i + 1),
              ),
            ],
            const SizedBox(width: PantasSpace.s12),
            WebPickerColumn(
              label: 'Year',
              values: [
                for (var y = now.year; y <= current.year + 10; y++) '$y',
              ],
              selectedIndex: (current.year - now.year).clamp(0, 999),
              onSelected: (i) => saveDate(
                now.year + i,
                current.month,
                mode == 0 ? current.day : null,
              ),
            ),
          ],
        );

    return SettingsPanePage(
      section: 'Your exam',
      title: 'Your exam',
      description:
          "What you're preparing for, when it is, and which days you study.",
      backLabel: 'Settings',
      hero: true,
      onBack: () => leavePage(context, fallback: '/settings'),
      children: [
        SettingsSection(
          // ST_DaysLast: on the wide layout the message is the footer.
          footer: _lastDay != null && context.wideWeb
              ? 'At least one day stays on.'
              : past
                  ? 'This date has passed. Pick your next exam date, or choose '
                      "I don't know."
                  : mode == 2 || date == null
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
            SettingsRow(
              title: 'Exam',
              value: ref.watch(activeExamShortNameProvider),
              divider: true,
              dividerInset: context.wideWeb ? PantasSpace.s0 : PantasSpace.s16,
              onTap: () => unawaited(_changeExam()),
            ),
            SettingsRow(
              title: 'Exam date',
              value: date == null
                  ? 'Not set'
                  : DateFormat(date.day == null ? 'MMMM y' : 'MMM d, y')
                      .format(current),
              // ST_Exam, ST_ExamDate: a gray chip, with green text while the
              // picker is open.
              verticalPadding: context.wideWeb ? 11 : 12,
              valueWidget: context.wideWeb
                  ? null
                  : Container(
                      // At least 34 high; it grows with the text (200%).
                      constraints: const BoxConstraints(minHeight: 34),
                      padding: const EdgeInsets.symmetric(
                        horizontal: PantasSpace.s12,
                        vertical: PantasSpace.s4,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.fill,
                        borderRadius: BorderRadius.circular(PantasRadius.sm),
                      ),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          date == null
                              ? 'Not set'
                              : DateFormat(
                                  date.day == null ? 'MMMM y' : 'MMM d, y',
                                ).format(current),
                          style: context.type.rowValue.copyWith(
                            color: past
                                ? context.colors.destructive
                                : _dateOpen
                                    ? context.colors.accent
                                    : context.colors.label,
                          ),
                        ),
                      ),
                    ),
              valueStyle: context.wideWeb
                  ? PantasType.webRowTitleSettings.copyWith(
                      color: past
                          ? context.webTokens.colors.wrongText
                          : _dateOpen
                              ? context.webTokens.colors.accent
                              : context.webTokens.colors.secondaryLabel,
                    )
                  : context.type.rowValue.copyWith(
                      color: past
                          ? context.colors.destructive
                          : context.colors.secondaryLabel,
                    ),
              variant: ListRowVariant.inlineEditor,
              hideChevron: true,
              // ST_ExamDate: a line under the row while the picker is open too.
              divider: true,
              dividerInset: context.wideWeb ? PantasSpace.s0 : PantasSpace.s16,
              expanded: _dateOpen,
              onTap: () => setState(() => _dateOpen = !_dateOpen),
              editor: Column(
                crossAxisAlignment: context.wideWeb
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  if (context.wideWeb)
                    SizedBox(width: _dateModesWidth, child: dateModes())
                  else
                    dateModes(),
                  if (mode != 2 && context.wideWeb) ...[
                    const SizedBox(height: PantasSpace.s14),
                    webPickers(),
                  ] else if (mode != 2)
                    phoneWheels(),
                ],
              ),
            ),
            if (context.wideWeb && _dateOpen)
              Divider(
                height: PantasBorder.hairline,
                thickness: PantasBorder.hairline,
                color: context.webTokens.colors.separator,
              ),
            if (context.wideWeb)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PantasSpace.s16,
                  vertical: PantasSpace.s14,
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: PantasSpace.s16,
                  runSpacing: PantasSpace.s16,
                  children: [
                    Text(
                      'Study days',
                      style: PantasType.webRowTitleSettings
                          .copyWith(color: context.colors.textPrimary),
                    ),
                    Wrap(
                      spacing: PantasSpace.s8,
                      runSpacing: PantasSpace.s8,
                      children: [
                        for (final day in [7, 1, 2, 3, 4, 5, 6]) studyDay(day),
                      ],
                    ),
                  ],
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s10,
                  PantasSpace.s16,
                  PantasSpace.s8,
                ),
                child: Text('Study days', style: context.type.body),
              ),
              // ST_Exam: seven 38 px circles, 10 px apart.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s0,
                  PantasSpace.s16,
                  PantasSpace.s14,
                ),
                // Seven 44 circles that scroll sideways when the row is too
                // narrow for them (SelectableTile README, D190).
                child: DayRow(
                  order: const [7, 1, 2, 3, 4, 5, 6],
                  selected: settings.studyDays.weekdays.toSet(),
                  fill: false,
                  itemBuilder: studyDay,
                ),
              ),
            ],
            if (_lastDay != null && !context.wideWeb)
              Padding(
                padding: const EdgeInsets.all(PantasSpace.s16),
                child: Text(
                  'At least one day stays on.',
                  style: context.type.footnote,
                ),
              ),
          ],
        ),
        const SizedBox(height: PantasSpace.s24),
        SettingsSection(
          footer: context.wideWeb
              ? null
              : 'Answers from your other exams count toward this one. '
                  'Nothing is ever deleted.',
          children: [
            SettingsRow(
              title: 'Carry over progress',
              subtitle: context.wideWeb
                  ? 'Answers from your other exams count toward this one. '
                      'Nothing is ever deleted.'
                  : null,
              subtitleStyle: context.wideWeb
                  ? context.webTokens.sm.copyWith(height: 1.45)
                  : null,
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
        const SizedBox(height: PantasSpace.s24),
        SettingsSection(
          footer: 'Topics you leave out drop out of your plan.',
          children: [
            SettingsRow(
              title: "What's included",
              value: leftOut ? 'Some topics left out' : 'All subjects',
              onTap: () => push('/settings/exam/included'),
            ),
          ],
        ),
        if (_error != null) Text(_error!, style: context.type.footnote),
      ],
    );
  }
}
