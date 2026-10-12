import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

abstract interface class TrialEndingNotifier {
  /// Register delivery at this instant, 24 hours before the first charge.
  /// W4f composes the charge date from this instant plus 24 hours.
  Future<void> schedule(DateTime chargeAt, String priceText);
  Future<void> cancel();
}

class NoopTrialEndingNotifier implements TrialEndingNotifier {
  const NoopTrialEndingNotifier();
  @override
  Future<void> schedule(DateTime chargeAt, String priceText) async {}
  @override
  Future<void> cancel() async {}
}

class TrialEndingScheduler {
  TrialEndingScheduler(
    this._notifier, {
    required String? Function(Entitlement) priceTextFor,
  }) : _priceTextFor = priceTextFor;

  final TrialEndingNotifier _notifier;
  final String? Function(Entitlement) _priceTextFor;
  DateTime? _lastCharge;
  String? _lastPrice;

  Future<void> sync(Entitlement entitlement) async {
    final charge = entitlement.chargesAt;
    final price = _priceTextFor(entitlement);
    if (entitlement.state != EntitlementState.trial ||
        entitlement.plan != EntitlementPlan.monthly ||
        !entitlement.willRenew ||
        charge == null ||
        price == null ||
        price.isEmpty) {
      await _notifier.cancel();
      _lastCharge = null;
      _lastPrice = null;
      return;
    }
    if (charge == _lastCharge && price == _lastPrice) return;
    await _notifier.schedule(charge.subtract(const Duration(hours: 24)), price);
    _lastCharge = charge;
    _lastPrice = price;
  }
}

final trialEndingNotifierProvider = Provider<TrialEndingNotifier>(
  (_) => const NoopTrialEndingNotifier(),
);

final trialEndingSchedulerProvider = Provider<TrialEndingScheduler>((ref) {
  final packages =
      ref.watch(paywallOfferingProvider).valueOrNull?.recognizedPackages;
  return TrialEndingScheduler(
    ref.watch(trialEndingNotifierProvider),
    priceTextFor: (entitlement) => packages
        ?.where(
          (package) =>
              package.productId.split(':').first ==
              entitlement.productId?.split(':').first,
        )
        .firstOrNull
        ?.priceString,
  );
});
