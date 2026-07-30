// lib/features/home/presentation/widgets/home_masthead.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/l10n/app_localizations.dart';

class HomeMasthead extends ConsumerWidget {
  const HomeMasthead({required this.now, super.key});

  /// Injected so the kicker and the day count are testable without a clock.
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    final data = ref.watch(homeMastheadProvider).valueOrNull;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The name shares the greeting's line and its size. Set
              // large it took a third of the masthead to say something the
              // student already knows, and the exam is what they came for.
              Text(
                greetingLineFor(
                  now,
                  data?.name,
                  AppLocalizations.of(context),
                ),
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: 2),
              if (data == null)
                const FaintBars()
              else ...[
                Text(data.examShortName, style: styles.displaySmall),
                const SizedBox(height: 2),
                Text(
                  countdownLineFor(examDate: data.examDate, now: now),
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
              ],
            ],
          ),
        ),
        // The default IconButton reserves 48px of height around a 20px
        // glyph, which pushed the masthead open with space doing no work.
        // The 44px target is kept and the padding above and below is not.
        IconButton(
          onPressed: () => context.push('/settings'),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          icon: Icon(
            Icons.settings_outlined,
            size: 20,
            color: colors.inkMuted,
          ),
          tooltip: 'Settings',
        ),
      ],
    );
  }
}

@visibleForTesting
String greetingFor(DateTime now, [AppLocalizations? l10n]) {
  final h = now.hour;
  final timeOfDay = h < 12
      ? 'umaga'
      : h < 18
          ? 'hapon'
          : 'gabi';
  if (l10n != null) {
    return l10n.greeting(timeOfDay);
  }
  return 'Magandang $timeOfDay';
}

/// The greeting, with the name on the same line when there is one.
///
/// A comma leads into a name and reads as an unfinished sentence without
/// one, so with nobody to address it closes with an exclamation instead.
@visibleForTesting
String greetingLineFor(DateTime now, String? name, [AppLocalizations? l10n]) {
  final greeting = greetingFor(now, l10n);
  return name == null ? '$greeting!' : '$greeting, $name';
}

/// The three states the line under the exam may print, and no fourth.
///
/// A day count derived from a month would be a figure made of a measurement
/// and an assumption. `ExamDate.day` is null at month precision so that this
/// cannot be got wrong by reaching around the type.
///
/// The exam's name is the headline above this now, so the line no longer
/// repeats it: with no date there is nothing left to say and it is empty.
@visibleForTesting
String countdownLineFor({
  required ExamDate? examDate,
  required DateTime now,
}) {
  if (examDate == null) return '';
  switch (examDate.precision) {
    case ExamDatePrecision.month:
      return 'Your exam is in ${_monthName(examDate.month)} ${examDate.year}';
    case ExamDatePrecision.day:
      final days = examDate.daysUntil(now);
      if (days == null || days < 0) return '';
      final unit = days == 1 ? 'day' : 'days';
      return '$days $unit to go';
  }
}

/// Written out in English rather than through `intl`, because the rest of
/// this screen's copy is English and a device locale would print one month
/// name in a language nothing else here uses.
String _monthName(int month) {
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return names[month - 1];
}
