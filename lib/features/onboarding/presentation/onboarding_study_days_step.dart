import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

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
  final Set<int> _days = {};
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
    final scale = MediaQuery.textScalerOf(context);
    final date = _settings?.examDate;
    final dateDescription = date == null
        ? ''
        : date.day != null
            ? 'Your exam is on '
                '${DateFormat('EEEE, d MMMM', 'en_US').format(date.day!)}.'
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
    return PantasPage.onboarding(
      title: 'Which days will you study?',
      detail: 'Your plan only puts work on these days. '
          'You can change them later in Settings.',
      progress: 5,
      onBack: () {
        _generation++;
        widget.onBack?.call();
      },
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_failed) saveFailureLine(_save),
          PantasButton(
            label: 'Continue',
            busy: _saving,
            onPressed: _saving || !_valid ? null : _save,
          ),
          const SizedBox(height: 6),
          PantasButton(
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final size = scale.scale(15) > 22 ? 60.0 : 42.0;
                  final children = [
                    for (final day in [7, 1, 2, 3, 4, 5, 6])
                      Semantics(
                        label: DateFormat('EEEE', 'en_US')
                            .format(DateTime(2026, 6, day)),
                        selected: _days.contains(day),
                        button: true,
                        excludeSemantics: true,
                        child: SizedBox(
                          width: size + 2,
                          height: size + 2,
                          child: TextButton(
                            key: ValueKey('study-day-$day'),
                            onPressed: _saving
                                ? null
                                : () => setState(() {
                                      if (!_days.add(day)) _days.remove(day);
                                    }),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _days.contains(day)
                                  ? c.accentFill
                                  : c.surface,
                              shape: CircleBorder(
                                side: BorderSide(
                                  color: _days.contains(day)
                                      ? c.accentFill
                                      : c.controlOutline,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Text(
                              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][day - 1],
                              style: context.type.subheadStrong.copyWith(
                                color:
                                    _days.contains(day) ? c.onAccent : c.label,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ];
                  return constraints.maxWidth < 7 * (size + 2)
                      ? Wrap(spacing: 6, runSpacing: 8, children: children)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: children,
                        );
                },
              ),
              const SizedBox(height: 28),
              if (_days.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Pick at least one day to continue.',
                    style:
                        context.type.subhead.copyWith(color: c.secondaryLabel),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (invalid)
                        Text(
                          'None of these fall before your exam',
                          style: context.type.emphasized,
                        )
                      else
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${_days.length}',
                                style: context.type.largeTitle,
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
                      const SizedBox(height: 6),
                      Text(
                        invalid
                            ? '$dateDescription Add $addDays '
                                "so there's time to study first."
                            : examDays != null
                                ? 'Your exam is in $examDays '
                                    '${examDays == 1 ? 'day' : 'days'}. '
                                    "We'll focus on what matters most."
                                : 'Days off stay free. '
                                    'Questions that come due on a day off '
                                    'wait for your next study day.',
                        style: context.type.subhead
                            .copyWith(color: c.secondaryLabel, height: 1.4),
                      ),
                    ],
                  ),
                ),
            ],
    );
  }
}
