import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_calendar.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

class OnboardingExamDateStep extends ConsumerStatefulWidget {
  const OnboardingExamDateStep({
    required this.onCompleted,
    this.onBack,
    this.now,
    super.key,
  });
  final VoidCallback onCompleted;
  final VoidCallback? onBack;
  final DateTime? now;
  @override
  ConsumerState<OnboardingExamDateStep> createState() =>
      _OnboardingExamDateStepState();
}

class _OnboardingExamDateStepState
    extends ConsumerState<OnboardingExamDateStep> {
  late final DateTime _today = DateUtils.dateOnly(widget.now ?? DateTime.now());
  MonthFirstDate? _value;
  bool _loaded = false;
  bool _loadFailed = false;
  bool _declined = false;
  bool _saving = false;
  bool _failed = false;
  ExamDate? _retryDate;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final telemetry = ref.read(telemetryProvider);
    if (_loadFailed) setState(() => _loadFailed = false);
    try {
      final saved =
          await ref.read(settingsRepositoryProvider).readUserSettings();
      if (!mounted) return;
      setState(() {
        final date = saved.examDate;
        _value = date == null
            ? MonthFirstDate(year: _today.year)
            : MonthFirstDate(
                year: date.year,
                month: date.month,
                day: date.day?.day,
              );
        _declined = date != null;
        _loaded = true;
      });
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  void _back() {
    _generation++;
    widget.onBack?.call();
  }

  Future<void> _save(ExamDate? date) async {
    if (_saving) return;
    final generation = _generation;
    final repo = ref.read(settingsRepositoryProvider);
    final prefs = ref.read(appPreferencesRepositoryProvider);
    final telemetry = ref.read(telemetryProvider);
    setState(() {
      _saving = true;
      _failed = false;
      _retryDate = date;
    });
    try {
      if (date == null) {
        await repo.clearExamDate();
      } else {
        await repo.updateExamDate(date, today: _today);
      }
      await prefs.setDeviceValue(onboardingDateAnsweredKey, 'true');
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
    final catalog = ref.watch(examPickerCatalogProvider);
    final selected = ref.watch(_dateExamIdProvider);
    final id = selected.valueOrNull;
    ExamCatalogEntry? entry;
    for (final item in catalog.valueOrNull ?? <ExamCatalogEntry>[]) {
      if (item.id == id) entry = item;
    }
    final sittings = entry?.publishedSittings
            .where((s) => !DateUtils.dateOnly(s.firstDay).isBefore(_today))
            .toList() ??
        <PublishedExamSitting>[];
    // The catalog can contain multiple future sittings. Use its earliest.
    final ordered = sittings..sort((a, b) => a.firstDay.compareTo(b.firstDay));
    final known = !_declined && ordered.isNotEmpty
        ? DateUtils.dateOnly(ordered.first.firstDay)
        : null;
    final value = _value ?? MonthFirstDate(year: _today.year);
    final date = value.month == null
        ? null
        : value.day == null
            ? ExamDate.inMonth(year: value.year, month: value.month!)
            : ExamDate.onDay(DateTime(value.year, value.month!, value.day!));
    return OnboardingWebPage(
      title: 'When is your exam?',
      width: known == null ? 780 : 580,
      gap: known == null ? 24 : 28,
      bottomGap: known == null ? 40 : 32,
      progress: 4,
      onBack: _back,
      bodyGap: known == null ? 18 : 22,
      detail: known == null
          ? 'Pick the month. Add the day if you know it.'
          : "Here's the date we have for this year's ${entry!.shortName}.",
      bottom: OnboardingActions(
        leading: known == null
            ? null
            : Text(
                'Is this your exam day?',
                style: context.webTokens.style(17, weight: FontWeight.w600),
              ),
        children: [
          if (_failed) saveFailureLine(() => _save(_retryDate)),
          OnboardingButton(
            label: known == null ? 'Continue' : "That's Right",
            busy: _saving,
            onPressed: !_loaded || _saving || (known == null && date == null)
                ? null
                : () => _save(known == null ? date : ExamDate.onDay(known)),
          ),
          const SizedBox(height: 6),
          OnboardingButton(
            label: known == null ? "I don't know" : 'Different Date',
            variant: context.wideWeb && known != null
                ? PantasButtonVariant.neutral
                : PantasButtonVariant.tertiary,
            // Until the stored date has loaded, this would overwrite it unseen.
            onPressed: _saving || !_loaded
                ? null
                : () => known == null
                    ? _save(null)
                    : setState(() => _declined = true),
          ),
        ],
      ),
      children: [
        if (_loadFailed)
          errorFor('exam date', _restore)
        else if (!_loaded)
          loadingFor(const AsyncLoading<void>())
        else if (known != null) ...[
          Container(
            padding: EdgeInsets.all(context.wideWeb ? 28 : 18),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: context.wideWeb ? 84 : 64,
                  height: context.wideWeb ? 84 : 68,
                  decoration: BoxDecoration(
                    border: Border.all(color: context.colors.label, width: 2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM', 'en_US').format(known).toUpperCase(),
                        style: context.type.caption.copyWith(
                          fontSize: context.wideWeb ? 13 : null,
                          fontWeight: FontWeight.w700,
                          color: context.wideWeb
                              ? context.webTokens.colors.secondaryLabel
                              : null,
                          letterSpacing: context.wideWeb ? .78 : null,
                        ),
                      ),
                      Text(
                        '${known.day}',
                        style: context.type.emphasized.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: context.wideWeb ? 24 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat(
                          context.wideWeb
                              ? 'EEEE, MMMM d, y'
                              : 'EEEE, d MMMM y',
                          'en_US',
                        ).format(known),
                        style: context.wideWeb
                            ? context.webTokens
                                .style(21, weight: FontWeight.w600)
                            : context.type.emphasized,
                      ),
                      Text(
                        _daysFromToday(known.difference(_today).inDays),
                        style: context.type.subhead
                            .copyWith(color: context.colors.secondaryLabel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!context.wideWeb) const SizedBox(height: 22),
          if (!context.wideWeb)
            Text(
              'Is this your exam day?',
              style: context.type.footnote
                  .copyWith(color: context.colors.secondaryLabel),
            ),
        ] else ...[
          if (context.wideWeb)
            OnboardingWebCalendar(
              value: value,
              today: _today,
              onChanged: (next) => setState(() => _value = next),
            )
          else
            MonthFirstDatePicker.onboarding(
              value: value,
              today: _today,
              dayNote: (day) =>
                  '${DateFormat('EEEE, d MMMM', 'en_US').format(day)}'
                  ' · ${_daysFromToday(day.difference(_today).inDays)}',
              onChanged: (next) => setState(() => _value = next),
            ),
        ],
      ],
    );
  }
}

/// O_DateKnown and O_DateToday: "42 days from today", and "today" for zero.
String _daysFromToday(int days) => switch (days) {
      0 => 'today',
      1 => '1 day from today',
      _ => '$days days from today',
    };

final _dateExamIdProvider = FutureProvider<String?>(
  (ref) => ref.watch(appPreferencesRepositoryProvider).selectedExamId(),
);
