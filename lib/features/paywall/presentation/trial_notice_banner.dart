import 'package:cse_cet_reviewer/features/paywall/domain/trial_notice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrialNoticeBanner extends StatelessWidget {
  const TrialNoticeBanner({required this.notice, super.key});

  final TrialNotice notice;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.MMMd().format(notice.chargeDate);
    return MaterialBanner(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Pro trial ends in ${notice.daysRemaining} days'),
          Text('No action needed to keep Pro. ₱499 will be charged on $date.'),
        ],
      ),
      actions: const [SizedBox.shrink()],
    );
  }
}
