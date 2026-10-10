import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/dev/dev_pro_switch.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/paywall/application/paywall_controller.dart';
import 'package:pantas/features/paywall/application/trusted_clock.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/data/pending_purchase_store.dart';
import 'package:pantas/features/paywall/data/revenuecat_config.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/paywall_recommendation.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

final revenueCatConfigProvider = Provider<RevenueCatConfig>(
  (ref) => RevenueCatConfig.fromEnvironment(),
);

final entitlementSnapshotStoreProvider =
    Provider<EntitlementSnapshotStore>((ref) {
  final preferences = ref.watch(appPreferencesRepositoryProvider);
  return EntitlementSnapshotStore(
    readValue: preferences.deviceValue,
    writeValue: preferences.setDeviceValue,
  );
});

final paymentEntitlementStateProvider =
    Provider<PaymentEntitlementState>((ref) {
  return PaymentEntitlementState(ref.watch(entitlementSnapshotStoreProvider));
});

final pendingPurchaseStoreProvider = Provider<PendingPurchaseStore>((ref) {
  final preferences = ref.watch(appPreferencesRepositoryProvider);
  final store = PendingPurchaseStore(
    readValue: preferences.deviceValue,
    writeValue: preferences.setDeviceValue,
  );
  ref.onDispose(() => unawaited(store.dispose()));
  return store;
});

final _pendingForAccountProvider =
    StreamProvider.family<PendingPurchase?, String>((ref, uid) {
  return ref.watch(pendingPurchaseStoreProvider).watch(uid);
});

final pendingPurchaseProvider = Provider<AsyncValue<PendingPurchase?>>((ref) {
  final authAsync = ref.watch(authStateProvider);
  if (authAsync.isLoading || authAsync.hasError) return const AsyncData(null);
  final auth = authAsync.valueOrNull;
  final uid = switch (auth) {
    SignedInAuthState(:final user) => user.uid,
    AnonymousAuthState(:final uid) => uid,
    _ => null,
  };
  if (uid == null) return const AsyncData(null);
  return ref.watch(_pendingForAccountProvider(uid));
});

final trustedClockProvider = Provider<TrustedClock>((ref) {
  final preferences = ref.watch(appPreferencesRepositoryProvider);
  return TrustedClock(
    readValue: preferences.deviceValue,
    writeValue: preferences.setDeviceValue,
  );
});

final revenueCatGatewayProvider = Provider<RevenueCatGateway>((ref) {
  final config = ref.watch(revenueCatConfigProvider);
  final entitlementState = ref.watch(paymentEntitlementStateProvider);
  final clock = ref.watch(trustedClockProvider);
  if (!config.isEnabled) {
    return DisabledRevenueCatGateway(entitlementState, clock);
  }
  return LiveRevenueCatGateway(
    entitlementState: entitlementState,
    pendingStore: ref.watch(pendingPurchaseStoreProvider),
    trustedClock: clock,
  );
});

final entitlementProvider = StreamProvider<Entitlement>((ref) {
  if (kDebugMode) {
    // The switch `tools/pro` flips, which beats FAKE_PRO because it does not
    // need a rebuild to change.
    final override = ref.watch(devProOverrideProvider);
    if (override != null) {
      return Stream.value(
        override
            ? const Entitlement(plan: EntitlementPlan.monthly)
            : const Entitlement.free(),
      );
    }
  }
  if (kDebugMode && const bool.fromEnvironment('FAKE_PRO')) {
    return Stream.value(const Entitlement(plan: EntitlementPlan.monthly));
  }
  final gateway = ref.watch(revenueCatGatewayProvider);
  final cached = gateway.cachedEntitlement ?? const Entitlement.free();
  return gateway.customerInfoUpdates
      .handleError((Object error, StackTrace stack) {
        // Stream errors are treated as no news; entitlement never fails closed.
      })
      .distinct()
      .startWith(cached);
});

final paywallOfferingProvider = FutureProvider<PaywallOfferingResult>((ref) {
  return ref.watch(revenueCatGatewayProvider).currentOffering();
});

final examCatalogRepositoryProvider = Provider<ExamCatalogRepository>((ref) {
  return ExamCatalogRepository(ref.watch(contentDatabaseProvider));
});

final proForActiveExamProvider = FutureProvider<bool>((ref) async {
  if (kDebugMode) {
    final override = ref.watch(devProOverrideProvider);
    if (override != null) return override;
  }
  if (kDebugMode && const bool.fromEnvironment('FAKE_PRO')) return true;
  final entitlement = await ref.watch(entitlementProvider.future);
  final focus = await ref.watch(activeExamFocusProvider.future);
  final exam = focus.exam;
  if (exam == null) return false;
  final catalog =
      await ref.watch(examCatalogRepositoryProvider).watchAll().first;
  final entry = catalog.where((entry) => entry.id == exam.id).firstOrNull;
  // An exam absent from the published catalog has no inferred price tier.
  if (entry == null) return false;
  return entitlement.coversExam(
    exam.id,
    examTier: PriceTier.fromCatalog(entry.priceTier),
  );
});

final paywallPackagesProvider = FutureProvider((ref) async {
  final offering = await ref.watch(paywallOfferingProvider.future);
  return paywallDisplayOrder(offering.recognizedPackages);
});

final paywallControllerProvider = Provider<PaywallController>((ref) {
  return PaywallController(
    ref.watch(revenueCatGatewayProvider),
    telemetry: ref.watch(telemetryProvider),
  );
});

extension _StartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
