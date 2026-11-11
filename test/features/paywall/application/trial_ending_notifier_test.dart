import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/application/trial_ending_notifier.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

void main() {
  final chargeAt = DateTime.utc(2026, 10, 14, 12);
  Entitlement trial(DateTime date, {bool renews = true}) => Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_cs_monthly',
        isTrial: true,
        willRenew: renews,
        expiresAt: date,
      );
  test(
      'trial schedules once for 24 hours before its charge '
      'with the store price', () async {
    final notifier = _Notifier();
    final scheduler = TrialEndingScheduler(
      notifier,
      priceTextFor: (_) => '₱149',
    );
    await scheduler.sync(trial(chargeAt));
    await scheduler.sync(trial(chargeAt));
    expect(
      notifier.calls,
      [(chargeAt.subtract(const Duration(hours: 24)), '₱149')],
    );
  });
  test('changed charge date reschedules and cancellation removes the reminder',
      () async {
    final notifier = _Notifier();
    final scheduler = TrialEndingScheduler(
      notifier,
      priceTextFor: (_) => '₱149',
    );
    await scheduler.sync(trial(chargeAt));
    final changed = chargeAt.add(const Duration(days: 1));
    await scheduler.sync(trial(changed));
    expect(notifier.calls.last.$1, changed.subtract(const Duration(hours: 24)));
    await scheduler.sync(trial(changed, renews: false));
    expect(notifier.cancels, 1);
  });
  test('conversion and an unknown price never leave a charge reminder',
      () async {
    final notifier = _Notifier();
    final scheduler = TrialEndingScheduler(
      notifier,
      priceTextFor: (_) => null,
    );
    await scheduler.sync(trial(chargeAt));
    expect(notifier.calls, isEmpty);
    await scheduler.sync(const Entitlement(plan: EntitlementPlan.monthly));
    expect(notifier.cancels, 2);
  });
}

class _Notifier implements TrialEndingNotifier {
  final List<(DateTime, String)> calls = [];
  int cancels = 0;
  @override
  Future<void> schedule(DateTime chargeAt, String priceText) async {
    calls.add((chargeAt, priceText));
  }

  @override
  Future<void> cancel() async {
    cancels++;
  }
}
