import 'package:flutter/material.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:pantas/features/paywall/domain/paywall_recommendation.dart';
import 'package:pantas/features/paywall/domain/plan_cost.dart';
import 'package:pantas/features/paywall/presentation/plan_row.dart';

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
    this.isBusy = false,
    this.operationStatus,
    this.onRetry,
    super.key,
  });

  final List<PaywallPackage> packages;
  final ExamDate? examDate;
  final DateTime today;
  final PaywallPackage selectedPackage;
  final ValueChanged<PaywallPackage> onSelect;
  final VoidCallback onContinue;
  final bool isBusy;
  final PaymentOperationStatus? operationStatus;
  final VoidCallback? onRetry;

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

    return SafeArea(
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
                final rightFigure = cost.total != null
                    ? '₱${cost.total!.toInt()}'
                    : pkg.priceString;
                final footnote = cost.overshootDays == null
                    ? null
                    : '${cost.overshootDays} days past your exam';
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
                  enabled: !widget.isBusy,
                  onTap: () {
                    if (widget.isBusy) return;
                    setState(() => _selected = pkg);
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
                'Tell us your exam date and we will show what each plan '
                'costs you.',
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),
            ],
            const SizedBox(height: 24),
            _PurchaseActionArea(
              label: ctaCopyFor(_selected),
              isBusy: widget.isBusy,
              status: widget.operationStatus,
              onPressed: widget.onContinue,
              onRetry: widget.onRetry,
            ),
            const SizedBox(height: 9),
            Center(
              child: Text(
                'Cancel any time. Paid through Google Play.',
                textAlign: TextAlign.center,
                style: styles.bodySmall.copyWith(
                  fontSize: 11.5,
                  color: colors.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseActionArea extends StatelessWidget {
  const _PurchaseActionArea({
    required this.label,
    required this.isBusy,
    required this.status,
    required this.onPressed,
    required this.onRetry,
  });

  final String label;
  final bool isBusy;
  final PaymentOperationStatus? status;
  final VoidCallback onPressed;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return Semantics(
        liveRegion: true,
        label: 'Purchase in progress',
        child: const BoardButton(label: 'Processing...', onPressed: null),
      );
    }

    final message = _messageFor(status);
    if (status == PaymentOperationStatus.networkFailure) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message!,
            textAlign: TextAlign.center,
            style: context.textStyles.bodySmall.copyWith(
              color: context.colors.inkMuted,
            ),
          ),
          const SizedBox(height: 6),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (message != null) ...[
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textStyles.bodySmall.copyWith(
              color: context.colors.inkMuted,
            ),
          ),
          const SizedBox(height: 8),
        ],
        BoardButton(label: label, onPressed: onPressed),
      ],
    );
  }

  String? _messageFor(PaymentOperationStatus? status) {
    return switch (status) {
      null ||
      PaymentOperationStatus.success ||
      PaymentOperationStatus.userCancelled ||
      PaymentOperationStatus.operationAlreadyInProgress =>
        null,
      PaymentOperationStatus.networkFailure =>
        'You need a connection to subscribe. Try again when '
            "you're back online.",
      PaymentOperationStatus.storeFailure =>
        "Google Play couldn't complete this purchase. Try again.",
      PaymentOperationStatus.entitlementNotActive =>
        "Your subscription couldn't be confirmed yet. Try again in a moment.",
      PaymentOperationStatus.noActiveSubscription ||
      PaymentOperationStatus.revenueCatFailure ||
      PaymentOperationStatus.configurationFailure ||
      PaymentOperationStatus.developerFailure ||
      PaymentOperationStatus.unknownFailure =>
        "Subscriptions aren't available right now. Try again later.",
    };
  }
}
