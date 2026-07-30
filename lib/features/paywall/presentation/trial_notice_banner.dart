import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/domain/trial_notice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrialNoticeBanner extends StatelessWidget {
  const TrialNoticeBanner({required this.notice, super.key});

  final TrialNotice notice;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    final date = DateFormat.MMMd().format(notice.chargeDate);
    final side = BorderSide(
      color: colors.rule,
      // ignore: avoid_redundant_argument_values
      width: AppDimensions.hairline,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(border: Border(top: side, bottom: side)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pro trial ends in ${notice.daysRemaining} days',
            style: styles.bodyMedium,
          ),
          Text(
            'No action needed to keep Pro. ₱499 will be charged on $date.',
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}
