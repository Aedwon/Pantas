// lib/features/home/presentation/widgets/home_masthead.dart
import 'package:cse_cet_reviewer/core/storage/domain/exam_date.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/home/presentation/home_providers.dart';
import 'package:cse_cet_reviewer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingFor(now, AppLocalizations.of(context)),
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: 1),
              if (data == null)
                const FaintBars()
              else ...[
                if (data.name == null)
                  // Muted, never board: Home's one primary action is
                  // "Continue lesson". Tapping through is self-healing, so
                  // no install needs a migration prompt.
                  InkWell(
                    onTap: () => context.push('/settings'),
                    child: Text(
                      'Add your name',
                      style:
                          styles.displaySmall.copyWith(color: colors.inkMuted),
                    ),
                  )
                else
                  Text(data.name!, style: styles.displaySmall),
                const SizedBox(height: 2),
                Text(
                  metaLineFor(
                    examShortName: data.examShortName,
                    examDate: data.examDate,
                    now: now,
                  ),
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push('/settings'),
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
  return 'Magandang $timeOfDay,';
}

/// The three states the meta line may print, and no fourth.
///
/// A day count derived from a month would be a figure made of a measurement
/// and an assumption. `ExamDate.day` is null at month precision so that this
/// cannot be got wrong by reaching around the type.
@visibleForTesting
String metaLineFor({
  required String examShortName,
  required ExamDate? examDate,
  required DateTime now,
}) {
  if (examDate == null) return examShortName;
  switch (examDate.precision) {
    case ExamDatePrecision.month:
      return 'Your exam is in ${_monthName(examDate.month)} ${examDate.year}';
    case ExamDatePrecision.day:
      final days = examDate.daysUntil(now);
      if (days == null || days < 0) return examShortName;
      final unit = days == 1 ? 'day' : 'days';
      return '$days $unit to $examShortName';
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
