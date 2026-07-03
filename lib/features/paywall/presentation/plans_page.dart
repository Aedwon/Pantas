import 'package:cse_cet_reviewer/core/storage/domain/exam_date.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_recommendation.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/plan_cost.dart';
import 'package:cse_cet_reviewer/features/paywall/presentation/plan_row.dart';
import 'package:flutter/material.dart';

/// Screen 2 of three. The plans and their arithmetic.
///
/// Computes total cost to cover the student through their exam, or shows
/// published prices if no date is set.
class PlansPage extends StatefulWidget {
  const PlansPage({
    required this.packages,
    required this.examDate,
    required this.today,
    required this.selectedPackage,
    required this.onSelect,
    required this.onContinue,
    super.key,
  });

  final List<PaywallPackage> packages;
  final ExamDate? examDate;
  final DateTime today;
  final PaywallPackage selectedPackage;
  final ValueChanged<PaywallPackage> onSelect;
  final VoidCallback onContinue;

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  late PaywallPackage _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedPackage;
  }

  @override
  void didUpdateWidget(PlansPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPackage != oldWidget.selectedPackage) {
      _selected = widget.selectedPackage;
    }
  }

  String _monthName(int month) {
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
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final examDate = widget.examDate;
    final today = widget.today;

    final String headline;
    final String rightHeader;

    if (examDate == null) {
      headline = 'Choose how long you need it.';
      rightHeader = 'Price';
    } else if (examDate.precision == ExamDatePrecision.day) {
      final days = examDate.daysUntil(today);
      headline = 'Your exam is in $days days.';
      final dayNum = examDate.day!.day;
      final monthStr = _monthName(examDate.day!.month);
      rightHeader = 'Until $dayNum $monthStr';
    } else {
      final monthStr = _monthName(examDate.month);
      headline = 'Your exam is in $monthStr ${examDate.year}.';
      rightHeader = 'Through $monthStr';
    }

    final targetDate = examDate == null
        ? null
        : (examDate.day ?? DateTime(examDate.year, examDate.month + 1, 0));

    final recSku = recommendedSkuForExamDate(
      today: today,
      examDate: targetDate,
    );

    final orderedPackages = paywallDisplayOrder(widget.packages);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: styles.displaySmall.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 24),

              // Table header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Plan',
                      style: styles.labelSmall.copyWith(color: colors.inkMuted),
                    ),
                  ),
                  Text(
                    rightHeader,
                    style: styles.labelSmall.copyWith(color: colors.inkMuted),
                  ),
                ],
              ),
              Container(
                height: 1.6,
                color: colors.ink,
                margin: const EdgeInsets.only(top: 6, bottom: 8),
              ),

              for (final pkg in orderedPackages) ...[
                () {
                  final cost = costForPackage(
                    package: pkg,
                    examDate: examDate,
                    today: today,
                  );

                  final title = switch (pkg.sku) {
                    PaywallSku.weekly => 'Weekly',
                    PaywallSku.monthly => 'Monthly',
                    PaywallSku.yearly => 'Yearly',
                  };

                  final termLine = switch (pkg.sku) {
                    PaywallSku.weekly => '${pkg.priceString} a week',
                    PaywallSku.monthly => '${pkg.priceString} a month',
                    PaywallSku.yearly =>
                      '7-day free trial, then ${pkg.priceString} a year',
                  };

                  final String rightFigure;
                  if (cost.total != null) {
                    rightFigure = '₱${cost.total!.toInt()}';
                  } else {
                    rightFigure = pkg.priceString;
                  }

                  final footnote = (cost.overshootDays != null)
                      ? '${cost.overshootDays} days past your exam'
                      : null;

                  final isRec = pkg.sku == recSku;
                  final badge = isRec
                      ? recommendationBadgeCopy(
                          recommended: recSku,
                          hasExamDate: examDate != null,
                        )
                      : null;

                  return PlanRow(
                    title: title,
                    termLine: termLine,
                    rightFigure: rightFigure,
                    selected: _selected.sku == pkg.sku,
                    onTap: () {
                      setState(() {
                        _selected = pkg;
                      });
                      widget.onSelect(pkg);
                    },
                    badge: badge,
                    footnote: footnote,
                  );
                }(),
              ],

              if (examDate == null) ...[
                const SizedBox(height: 16),
                Text(
                  'Tell us your exam date and we will show what each '
                  'plan costs you.',
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
              ],

              const SizedBox(height: 24),
              BoardButton(
                label: ctaCopyFor(_selected),
                onPressed: widget.onContinue,
              ),
              const SizedBox(height: 9),
              Center(
                child: Text(
                  'Cancel any time. Paid through Google Play.',
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
