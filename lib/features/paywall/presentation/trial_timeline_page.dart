import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';

/// Screen 3 of three. The trial timeline page.
///
/// Shown only when Yearly is chosen.
class TrialTimelinePage extends StatelessWidget {
  const TrialTimelinePage({
    required this.today,
    required this.yearlyPrice,
    required this.onStart,
    this.isBusy = false,
    this.operationStatus,
    this.onRetry,
    super.key,
  });

  final DateTime today;
  final String yearlyPrice;
  final VoidCallback onStart;
  final bool isBusy;
  final PaymentOperationStatus? operationStatus;
  final VoidCallback? onRetry;

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

    return SafeArea(
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
                              border: Border.all(
                                color: colors.ink,
                                width: 1.4,
                              ),
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                          if (i < steps.length - 1)
                            Expanded(
                              child: Container(width: 1, color: colors.rule),
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
                            style: styles.headlineSmall.copyWith(fontSize: 14),
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
            _TrialPurchaseAction(
              isBusy: isBusy,
              status: operationStatus,
              onStart: onStart,
              onRetry: onRetry,
            ),
            const SizedBox(height: 9),
            Center(
              child: Text(
                'No commitment. Cancel any time.',
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

class _TrialPurchaseAction extends StatelessWidget {
  const _TrialPurchaseAction({
    required this.isBusy,
    required this.status,
    required this.onStart,
    required this.onRetry,
  });

  final bool isBusy;
  final PaymentOperationStatus? status;
  final VoidCallback onStart;
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
        BoardButton(label: 'Start my free trial', onPressed: onStart),
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
