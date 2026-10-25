import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/settings/domain/delete_account_copy.dart';

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

    expect(copy, contains('you’ll still be charged'));
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

  test('no delete copy anywhere mentions a lifetime purchase', () {
    for (final plan in SettingsEntitlementPlan.values) {
      final copy = deleteAccountBillingLine(
        SettingsEntitlementSnapshot(plan: plan),
      );
      if (copy != null) {
        expect(copy.toLowerCase().contains('lifetime'), isFalse);
        expect(copy.contains('—'), isFalse);
      }
    }
  });
}
