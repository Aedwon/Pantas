import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/remote/content_service_providers.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

/// How long an entitlement must stay the same before the content layer acts
/// on it. At start the entitlement briefly reads Free before the store
/// answers, and that must not look like Pro ending.
final contentAccessSettleProvider =
    Provider<Duration>((ref) => const Duration(seconds: 5));

/// A short text that changes when what the account has paid for changes. It
/// names the covered exams and plans, not the dates, so a renewal does not
/// change it.
String contentAccessFingerprint(Entitlement entitlement) {
  final passes = entitlement.passes.keys.toList()..sort();
  final beta = entitlement.betaPasses.keys.toList()..sort();
  final subscriptions = [
    for (final source in entitlement.subscriptions)
      if (source.active) source.id,
  ]..sort();
  final promotions = [
    for (final source in entitlement.promotions)
      if (source.active) source.id,
  ]..sort();
  final level = entitlement.proIsActive ? 'pro' : 'free';
  return [
    level,
    entitlement.tier?.name ?? '-',
    passes.join(','),
    beta.join(','),
    subscriptions.join(','),
    promotions.join(','),
  ].join('|');
}

/// Web only. Tells the content layer when what the account has paid for
/// changes: it drops the day's checks and fetches the question sets held on
/// this device again, so Pro notes arrive at once after a purchase and leave
/// when Pro ends.
final contentAccessBridgeProvider = Provider<void>((ref) {
  Timer? settle;
  ref
    ..listen<AsyncValue<Entitlement>>(
      entitlementProvider,
      (_, next) {
        final entitlement = next.valueOrNull;
        if (entitlement == null) return;
        final fingerprint = contentAccessFingerprint(entitlement);
        settle?.cancel();
        settle = Timer(ref.read(contentAccessSettleProvider), () {
          unawaited(_apply(ref, fingerprint));
        });
      },
      fireImmediately: true,
    )
    ..onDispose(() => settle?.cancel());
});

Future<void> _apply(Ref ref, String fingerprint) async {
  final changed = await ref.read(contentServiceProvider).useAccess(fingerprint);
  if (changed) await ref.read(contentMirrorProvider).onAccessChanged();
}
