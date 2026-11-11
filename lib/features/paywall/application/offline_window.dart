import 'dart:async';

import 'package:collection/collection.dart';
import 'package:pantas/features/paywall/application/trusted_clock.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/products.dart';

class OfflineWindow {
  static Stream<Entitlement> watch(
    Stream<Entitlement> updates, {
    required Entitlement Function() confirmed,
    required TrustedClock clock,
    void Function()? onFreshCheckRequired,
  }) async* {
    await clock.start();
    final events = StreamController<void>();
    final subscription = updates.listen(
      (_) => events.add(null),
      onError: events.addError,
    );
    var observing = false;
    List<Object?>? lastAccess;
    var wasPaused = false;
    var lastRollback = Duration.zero;
    final timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (observing) return;
      observing = true;
      try {
        await clock.observe();
        if (!events.isClosed) events.add(null);
      } catch (error, stack) {
        if (!events.isClosed) events.addError(error, stack);
      } finally {
        observing = false;
      }
    });
    events.add(null);
    try {
      await for (final _ in events.stream) {
        final raw = confirmed();
        final view = apply(
          raw,
          effectiveTime: clock.effectiveTime,
          windowConsumed: clock.windowConsumed,
        );
        final paused = view.state == EntitlementState.paused;
        final rollback = clock.rollbackTotal;
        final needsCheck = paused && !wasPaused || rollback > lastRollback;
        wasPaused = paused;
        lastRollback = rollback;
        if (needsCheck) onFreshCheckRequired?.call();
        final coverage = view.coverage();
        final access = <Object?>[
          raw,
          view.state,
          coverage.subscriptionTier,
          coverage.grantTier,
          coverage.passes,
        ];
        if (!const DeepCollectionEquality().equals(lastAccess, access)) {
          lastAccess = access;
          yield view;
        }
      }
    } finally {
      timer.cancel();
      await subscription.cancel();
      await events.close();
    }
  }

  static Entitlement apply(
    Entitlement confirmed, {
    required DateTime effectiveTime,
    required bool windowConsumed,
  }) {
    if (!confirmed.proIsActive) return confirmed;
    final ends = [
      if (confirmed.productId != null &&
          confirmed.expiresAt != null &&
          productForId(confirmed.productId!)?.kind == ProductKind.subscription)
        confirmed.expiresAt!,
      for (final period in confirmed.subscriptions)
        if (period.active &&
            productForId(period.id)?.kind == ProductKind.subscription)
          period.endsAt,
      for (final grant in confirmed.promotions)
        if (grant.active &&
            productForId(grant.id)?.kind == ProductKind.promotional)
          grant.endsAt,
      ...confirmed.passes.values,
      ...confirmed.betaPasses.values,
    ];
    final latestEnd =
        ends.isEmpty ? null : ends.reduce((a, b) => a.isAfter(b) ? a : b);
    final paused = windowConsumed ||
        (latestEnd != null &&
            !effectiveTime.isBefore(latestEnd.add(const Duration(days: 3))));
    return confirmed.withOfflineWindow(effectiveTime, paused: paused);
  }
}
