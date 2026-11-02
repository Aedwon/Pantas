import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/content_access_bridge.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_checks.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_mirror.dart';
import 'package:pantas/core/content/remote/content_remote.dart';
import 'package:pantas/core/content/remote/content_service.dart';
import 'package:pantas/core/content/remote/content_service_providers.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

import '../helpers/in_memory_database.dart';

class _Remote implements ContentRemote {
  final calls = <String>[];
  String tier = 'free';

  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> known,
  ) async {
    calls.add('${kind.wire}:${ids.join(",")}');
    final suffix = tier == 'pro' ? 'p' : 'f';
    return ContentFetch(
      tier: tier,
      entries: {
        for (final id in ids)
          id: RemoteEntry.ok(version: 'v1.$suffix', data: {'id': id}),
      },
    );
  }
}

void main() {
  test('the fingerprint changes with what is covered, not with renewals', () {
    final free = contentAccessFingerprint(const Entitlement.free());
    final monthly = Entitlement(
      plan: EntitlementPlan.monthly,
      productId: 'pantas_cs_monthly',
      expiresAt: DateTime.utc(2026, 12),
    );
    final renewed = Entitlement(
      plan: EntitlementPlan.monthly,
      productId: 'pantas_cs_monthly',
      expiresAt: DateTime.utc(2027),
    );
    final pass = const Entitlement.free()
        .withPasses({'exam_cse_pro': DateTime.utc(2027)});
    expect(contentAccessFingerprint(monthly), isNot(free));
    expect(
      contentAccessFingerprint(monthly),
      contentAccessFingerprint(renewed),
    );
    expect(contentAccessFingerprint(pass), isNot(free));
    expect(
      contentAccessFingerprint(pass),
      isNot(contentAccessFingerprint(monthly)),
    );
  });

  test('a purchase fetches the sets held on this device after it settles',
      () async {
    final appDb = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    addTearDown(appDb.close);
    addTearDown(contentDb.close);
    final remote = _Remote();
    final service = ContentService(
      remote: remote,
      cache: ContentCache(appDb),
      checks: ContentChecks(store: DevicePrefsCheckStore(appDb)),
    );
    final mirror = ContentMirror(db: contentDb, service: service);
    final entitlement = StreamController<Entitlement>();
    addTearDown(entitlement.close);
    final container = ProviderContainer(
      overrides: [
        contentServiceProvider.overrideWithValue(service),
        contentMirrorProvider.overrideWithValue(mirror),
        entitlementProvider.overrideWith((ref) => entitlement.stream),
        contentAccessSettleProvider
            .overrideWithValue(const Duration(milliseconds: 20)),
      ],
    );
    addTearDown(container.dispose);

    container.read(contentAccessBridgeProvider);
    entitlement.add(const Entitlement.free());
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await service.refresh(ContentKind.questions, ['s1']);
    remote.calls.clear();

    // A brief flicker that settles back to the same level does nothing.
    entitlement
      ..add(const Entitlement(plan: EntitlementPlan.monthly, productId: 'x'))
      ..add(const Entitlement.free());
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(remote.calls, isEmpty);

    remote.tier = 'pro';
    entitlement
        .add(const Entitlement(plan: EntitlementPlan.monthly, productId: 'x'));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await mirror.idle;
    expect(remote.calls.first, 'questions:s1');
    expect((await service.stored(ContentKind.questions, 's1'))!.tier, 'pro');
    await mirror.dispose();
  });
}
