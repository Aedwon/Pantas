import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/dev/local_onboarding_presets.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/core/ui/components/day_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/selectable_tile.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

/// Wide web: the status block under the day row keeps this height, so the
/// buttons below do not move when the text changes (board OB_Days).
const double _statusMinHeight = 96;

class OnboardingStudyDaysStep extends ConsumerStatefulWidget {
  const OnboardingStudyDaysStep({
    required this.onCompleted,
    this.onBack,
    this.now,
    super.key,
  });
  final VoidCallback onCompleted;
  final VoidCallback? onBack;
  final DateTime? now;
  @override
  ConsumerState<OnboardingStudyDaysStep> createState() =>
      _OnboardingStudyDaysStepState();
}

class _OnboardingStudyDaysStepState
    extends ConsumerState<OnboardingStudyDaysStep> {
  final Set<int> _days = {...?takeSeededStudyDays()};
  UserSettings? _settings;
  bool _saving = false;
  bool _failed = false;
  bool _loadFailed = false;
  int _generation = 0;
  late final _today = DateUtils.dateOnly(widget.now ?? DateTime.now());
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final telemetry = ref.read(telemetryProvider);
    if (_loadFailed) setState(() => _loadFailed = false);
    try {
      final settings =
          await ref.read(settingsRepositoryProvider).readUserSettings();
      final db = ref.read(appDatabaseProvider);
      final saved = await (db.select(db.accountPrefs)
            ..where((row) => row.key.equals(SettingsPrefKeys.studyDays)))
          .getSingleOrNull();
      if (mounted) {
        setState(() {
          _settings = settings;
          if (saved != null && _days.isEmpty) {
            _days.addAll(settings.studyDays.weekdays);
          }
        });
      }
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  List<String> get _available {
    final date = _settings?.examDate;
    final end =
        date?.day ?? (date == null ? null : DateTime(date.year, date.month));
    if (end == null || !end.isAfter(_today)) return [];
    return [
      for (var offset = 0; offset < 7; offset++)
        if (DateTime(_today.year, _today.month, _today.day + offset)
            .isBefore(end))
          DateFormat('EEEE', 'en_US')
              .format(DateTime(_today.year, _today.month, _today.day + offset)),
    ];
  }

  bool get _valid {
    if (_days.isEmpty || _settings == null) return false;
    final date = _settings!.examDate;
    final end =
        date?.day ?? (date == null ? null : DateTime(date.year, date.month));
    if (end == null || !end.isAfter(_today)) return true;
    return StudyDays(_days).countInRange(_today, end) > 0;
  }

  Future<void> _save() async {
    if (_saving || !_valid) return;
    final generation = _generation;
    final telemetry = ref.read(telemetryProvider);
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await ref.read(settingsActionsProvider).updateStudyDays(StudyDays(_days));
      if (mounted && generation == _generation) widget.onCompleted();
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final date = _settings?.examDate;
    final dateDescription = date == null
        ? ''
        : date.day != null
            ? 'Your exam is on '
                '${DateFormat('EEEE, MMMM d', 'en_US').format(date.day!)}.'
            : 'Your exam is in '
                '${DateFormat('MMMM y', 'en_US').format(date.monthStart)}.';
    final addDays = _available.join(' or ');
    final dayCountLabel = _days.length == 1 ? 'study day' : 'study days';
    final invalid = _days.isNotEmpty && !_valid && _available.isNotEmpty;
    // O_Days draws the calm line with a real day count. Month-only dates have
    // no count, and an exam today or no date keeps the usual line.
    final untilExam = date?.daysUntil(_today);
    final examDays =
        untilExam != null && untilExam >= 1 && untilExam < 7 ? untilExam : null;
    final examDayWord = examDays == 1 ? 'day' : 'days';
    // Wide web: Aedwon overrode the board's wider day row on Nov 2, 2026. The
    // seven days fit the 580 column that every onboarding step uses.
    return OnboardingWebPage(
      title: 'Which days will you study?',
      bottomGap: PantasSpace.s28,
      detail: 'Your plan only puts work on these days. '
          // A no-break space keeps "Settings." from wrapping alone on the 580
          // column.
          'You can change them later in\u00A0Settings.',
      progress: 5,
      onBack: () {
        _generation++;
        widget.onBack?.call();
      },
      bottom: OnboardingActions(
        children: [
          if (_failed) saveFailureLine(_save),
          OnboardingButton(
            label: 'Continue',
            busy: _saving,
            onPressed: _saving || !_valid ? null : _save,
          ),
          const SizedBox(height: PantasSpace.s6),
          OnboardingButton(
            label: 'Every Day',
            variant: PantasButtonVariant.tertiary,
            onPressed: _saving
                ? null
                : () => setState(() => _days.addAll([1, 2, 3, 4, 5, 6, 7])),
          ),
        ],
      ),
      children: _loadFailed
          ? [errorFor('study days', _load)]
          : [
              Builder(
                builder: (context) {
                  const names = [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday',
                  ];
                  const weekdays = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  // The tile's own text ("Mon", "M") would be read after the
                  // day's name, so the day carries the whole label.
                  Widget tile(int day) => Semantics(
                        label: names[day - 1],
                        selected: _days.contains(day),
                        button: true,
                        excludeSemantics: true,
                        child: SelectableTile.day(
                          key: ValueKey('study-day-$day'),
                          weekday: weekdays[day - 1],
                          name: letters[day - 1],
                          selected: _days.contains(day),
                          onTap: _saving
                              ? null
                              : () => setState(() {
                                    if (!_days.add(day)) _days.remove(day);
                                  }),
                        ),
                      );
                  // Seven day tiles in weekday order (D190).
                  return DayRow(
                    order: const [7, 1, 2, 3, 4, 5, 6],
                    selected: _days,
                    itemWidth: DayRow.tileWidth(context),
                    itemBuilder: tile,
                  );
                },
              ),
              const SizedBox(height: PantasSpace.s28),
              Container(
                key: const ValueKey('study-days-status'),
                constraints: BoxConstraints(
                  minHeight: context.wideWeb ? _statusMinHeight : 0,
                ),
                child: _days.isEmpty
                    ? Padding(
                        // Wide web: flush with the title, as in OB_DaysNone
                        // (7W-4). The phone keeps its 4 px.
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              context.wideWeb ? PantasSpace.s0 : PantasSpace.s4,
                        ),
                        child: Text(
                          'Pick at least one day to continue.',
                          style: context.type.subhead
                              .copyWith(color: c.secondaryLabel),
                        ),
                      )
                    : Container(
                        padding: context.wideWeb && !invalid
                            ? EdgeInsets.zero
                            : EdgeInsets.symmetric(
                                horizontal: PantasSpace.s18,
                                vertical: context.wideWeb
                                    ? PantasSpace.s14
                                    : PantasSpace.s18,
                              ),
                        decoration: BoxDecoration(
                          color: context.wideWeb && !invalid
                              ? Colors.transparent
                              : c.surfaceCard,
                          borderRadius: BorderRadius.circular(
                            PantasRadius.xl,
                          ),
                        ),
                        child: _TooLateRow(
                          icon: context.wideWeb && invalid,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (invalid)
                                Text(
                                  'None of these fall before your exam',
                                  style: context.wideWeb
                                      ? PantasType.webTitleSm.copyWith(
                                          color: c.textPrimary,
                                        )
                                      : context.type.emphasized,
                                )
                              else
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${_days.length}',
                                        style: context.wideWeb
                                            ? PantasType.webBigNumeral.copyWith(
                                                color: c.textPrimary,
                                              )
                                            : context.type.largeTitle,
                                      ),
                                      TextSpan(
                                        text: '  $dayCountLabel a week',
                                        style: context.type.body.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: c.secondaryLabel,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                height: context.wideWeb && invalid
                                    ? PantasSpace.s2
                                    : PantasSpace.s6,
                              ),
                              Text(
                                invalid
                                    ? '$dateDescription Add $addDays '
                                        "so there's time to study first."
                                    : examDays != null
                                        ? 'Your exam is in $examDays '
                                            '$examDayWord. '
                                            "We'll focus on what matters most."
                                        : 'Days off stay free. '
                                            'Questions that come due '
                                            'on a day off '
                                            'wait for your next '
                                            'study day.',
                                style: context.wideWeb
                                    ? PantasType.webSub
                                        .copyWith(color: c.textSecondary)
                                    : context.type.subhead.copyWith(
                                        color: c.textSecondary,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
    );
  }
}

/// Board OB_DaysTooLate: a 22 px outline calendar beside the message (web).
class _TooLateRow extends StatelessWidget {
  const _TooLateRow({required this.icon, required this.child});
  final bool icon;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (!icon) return child;
    final t = context.webTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.string(
          '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" '
          'stroke-width="1.8" stroke-linecap="round" '
          'stroke-linejoin="round"> '
          '<rect x="3.5" y="5" width="17" height="15.5" rx="2.5"/> '
          '<path d="M3.5 9.5h17M8 3v4M16 3v4"/></svg>',
          width: PantasSize.icon,
          height: PantasSize.icon,
          colorFilter: ColorFilter.mode(t.colors.textPrimary, BlendMode.srcIn),
        ),
        const SizedBox(width: PantasSpace.s14),
        Expanded(child: child),
      ],
    );
  }
}
