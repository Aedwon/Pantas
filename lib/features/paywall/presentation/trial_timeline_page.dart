import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Screen 3 of three. The trial timeline page.
///
/// Shown only when Yearly is chosen.
class TrialTimelinePage extends StatelessWidget {
  const TrialTimelinePage({
    required this.today,
    required this.yearlyPrice,
    required this.onStart,
    super.key,
  });

  final DateTime today;
  final String yearlyPrice;
  final VoidCallback onStart;

  String _formatDate(DateTime dt) {
    const months = [
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final chargeDateStr = _formatDate(today.add(const Duration(days: 7)));

    final steps = <(String, String)>[
      (
        'Today',
        'Everything unlocks. Every explanation, every level of your '
            'progress, and mock exams with no waiting.',
      ),
      (
        'Day 5',
        'We remind you here in the app that the trial is ending.',
      ),
      (
        'Day 7',
        'Your first charge of $yearlyPrice begins on $chargeDateStr. '
            'Cancel any time before then and you pay nothing.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How your free trial works',
                style: styles.displaySmall.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'Full access to everything in Pantas. The first 7 days are '
                'free, then $yearlyPrice a year.',
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: 28),
              for (var i = 0; i < steps.length; i++) ...[
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 12,
                        child: Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(top: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: colors.ink, width: 1.4),
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                            if (i < steps.length - 1)
                              Expanded(
                                child: Container(
                                  width: 1,
                                  color: colors.rule,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              steps[i].$1,
                              style:
                                  styles.headlineSmall.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              steps[i].$2,
                              style: styles.bodySmall.copyWith(
                                fontSize: 11.5,
                                color: colors.inkMuted,
                              ),
                            ),
                            if (i < steps.length - 1)
                              const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              BoardButton(
                label: 'Start my free trial',
                onPressed: onStart,
              ),
              const SizedBox(height: 9),
              Center(
                child: Text(
                  'No commitment. Cancel any time.',
                  style: styles.bodySmall.copyWith(
                    fontSize: 11.5,
                    color: colors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
