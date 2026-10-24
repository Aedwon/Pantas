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
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
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
    return PantasPage.onboarding(
      title: 'When is your exam?',
      progress: 4,
      onBack: _back,
      bodyGap: known == null ? 18 : 22,
      detail: known == null
          ? 'Pick the month. Add the day if you know it.'
          : "Here's the date we have for this year's ${entry!.shortName}.",
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_failed) saveFailureLine(() => _save(_retryDate)),
          PantasButton(
            label: known == null ? 'Continue' : "That's Right",
            busy: _saving,
            onPressed: !_loaded || _saving || (known == null && date == null)
                ? null
                : () => _save(known == null ? date : ExamDate.onDay(known)),
          ),
          const SizedBox(height: 6),
          PantasButton(
            label: known == null ? "I don't know" : 'Different Date',
            variant: PantasButtonVariant.tertiary,
            onPressed: _saving
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
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 68,
                  decoration: BoxDecoration(
                    border: Border.all(color: context.colors.label, width: 2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM', 'en_US').format(known).toUpperCase(),
                        style: context.type.caption
                            .copyWith(fontWeight: FontWeight.w700),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, d MMMM y', 'en_US').format(known),
                        style: context.type.emphasized,
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
          const SizedBox(height: 22),
          Text(
            'Is this your exam day?',
            style: context.type.footnote
                .copyWith(color: context.colors.secondaryLabel),
          ),
        ] else ...[
          MonthFirstDatePicker.onboarding(
            value: value,
            today: _today,
            onChanged: (next) => setState(() => _value = next),
          ),
        ],
      ],
    );
  }
}

/// Zero keeps the plural: no board draws this card for an exam today.
String _daysFromToday(int days) =>
    days == 1 ? '1 day from today' : '$days days from today';

final _dateExamIdProvider = FutureProvider<String?>(
  (ref) => ref.watch(appPreferencesRepositoryProvider).selectedExamId(),
);
