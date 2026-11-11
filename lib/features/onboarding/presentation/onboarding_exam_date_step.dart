import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/dev/local_onboarding_presets.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_calendar.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

/// The calendar tile of the date card: wide, and on the phone (boards
/// OB_DateKnown, O_DateKnown).
const double _tileWide = 84;
const double _tilePhoneWidth = 64;
const double _tilePhoneHeight = 68;

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

  /// The phone field holds text that is not a valid date.
  bool _unresolved = false;
  bool _saving = false;
  bool _failed = false;
  ExamDate? _retryDate;
  int _generation = 0;
  final LocalPresetSeed? _seed = takeSeededExamDate();

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
        _value = _seed?.pickedDate ?? _value;
        _declined = _seed?.differentDate ?? _declined;
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
      gap: known == null ? PantasSpace.s24 : PantasSpace.s28,
      bottomGap: known == null ? PantasSpace.s40 : PantasSpace.s32,
      progress: 4,
      onBack: _back,
      bodyGap: known == null ? PantasSpace.s18 : PantasSpace.s20,
      // The phone field has no subtitle: the field and its label say it.
      detail: known == null
          ? (context.wideWeb
              ? 'Pick the month. Add the day if you know it.'
              : null)
          : "Here's the date we have for this year's ${entry!.shortName}.",
      bottom: OnboardingActions(
        leading: known == null
            ? null
            : Text(
                'Is this your exam day?',
                style: PantasType.webTitleSm
                    .copyWith(color: context.webTokens.colors.textPrimary),
              ),
        children: [
          if (_failed) saveFailureLine(() => _save(_retryDate)),
          OnboardingButton(
            label: known == null ? 'Continue' : "That's Right",
            busy: _saving,
            onPressed: !_loaded ||
                    _saving ||
                    (known == null && (date == null || _unresolved))
                ? null
                : () => _save(known == null ? date : ExamDate.onDay(known)),
          ),
          const SizedBox(height: PantasSpace.s6),
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
            padding: EdgeInsets.all(
              context.wideWeb ? PantasSpace.s28 : PantasSpace.s18,
            ),
            decoration: BoxDecoration(
              color: context.colors.surfaceCard,
              borderRadius: BorderRadius.circular(PantasRadius.xl),
            ),
            child: Row(
              children: [
                Container(
                  key: const ValueKey('exam-date-tile'),
                  // The tile grows with the text instead of clipping it
                  // (D175: sized so the month fits at 200%), and the month
                  // keeps 8 clear on each side.
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PantasSpace.s8,
                  ),
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.textScalerOf(context).scale(
                      context.wideWeb ? _tileWide : _tilePhoneWidth,
                    ),
                    minHeight: context.wideWeb ? _tileWide : _tilePhoneHeight,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.colors.textPrimary,
                      width: PantasBorder.ringSelected,
                    ),
                    borderRadius: BorderRadius.circular(PantasRadius.lg),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('MMM', 'en_US').format(known).toUpperCase(),
                        style: context.wideWeb
                            ? PantasType.webChipName.copyWith(
                                color: context.colors.textSecondary,
                              )
                            : context.type.caption.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                      ),
                      Text(
                        '${known.day}',
                        style: PantasType.webH2
                            .copyWith(color: context.colors.textPrimary),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: context.wideWeb ? PantasSpace.s24 : PantasSpace.s16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // A no-break space keeps the year with the day.
                        DateFormat('EEEE, MMMM d,\u00A0y', 'en_US')
                            .format(known),
                        style: context.wideWeb
                            ? PantasType.webH3.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
                              )
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
          if (!context.wideWeb) const SizedBox(height: PantasSpace.s20),
          // The page pads the title and the subtitle 4 px inside the card's
          // edge; the caption starts at their edge too.
          if (!context.wideWeb)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s4),
              child: Text(
                'Is this your exam day?',
                style: context.type.footnote
                    .copyWith(color: context.colors.secondaryLabel),
              ),
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
              onUnresolvedChanged: (unresolved) =>
                  setState(() => _unresolved = unresolved),
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
