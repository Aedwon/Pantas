import 'package:cse_cet_reviewer/features/settings/domain/delete_account_copy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('free named copy omits billing line', () {
    final copy =
        deleteAccountBillingLine(const SettingsEntitlementSnapshot.free());

    expect(copy, isNull);
  });

  test('active monthly or yearly copy warns billing continues', () {
    final copy = deleteAccountBillingLine(
      const SettingsEntitlementSnapshot(plan: SettingsEntitlementPlan.monthly),
    );

    expect(copy, contains("you'll still be charged"));
    expect(copy, contains('Google Play'));
  });

  test('trial copy warns trial ends and future billing needs Play cancellation',
      () {
    final copy = deleteAccountBillingLine(
      const SettingsEntitlementSnapshot(
        plan: SettingsEntitlementPlan.yearly,
        isTrial: true,
      ),
    );

    expect(copy, contains('free trial will end'));
    expect(copy, contains('cancel in Google Play'));
  });

  test('cancelled subscription copy uses end date', () {
    final copy = deleteAccountBillingLine(
      SettingsEntitlementSnapshot(
        plan: SettingsEntitlementPlan.yearly,
        expiresAt: DateTime.utc(2026, 6, 12),
        willRenew: false,
      ),
    );

    expect(copy, contains('ends on Jun 12'));
  });
}
