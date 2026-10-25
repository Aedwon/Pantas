import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';
import '../../../helpers/pump_app.dart';

class _Runtime extends FakeSyncEngine {
  final done = Completer<void>();
  @override
  Future<void> forceFlush() async {
    forceFlushCalls++;
    await done.future;
  }
}

void main() {
  testWidgets('Back Up Now calls the current runtime and blocks duplicate taps',
      (tester) async {
    final runtime = _Runtime();
    await tester.pumpAppWithProviders(
      const BackupPage(),
      overrides: [
        isAnonymousProvider.overrideWith((ref) async => false),
        entitlementProvider.overrideWith(
          (ref) =>
              Stream.value(const Entitlement(plan: EntitlementPlan.monthly)),
        ),
        syncRuntimeProvider.overrideWith((ref) => runtime),
        syncStatusProvider
            .overrideWith((ref) => Stream.value(const SyncUpToDate())),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
    await tester.tap(find.text('Back Up Now'));
    await tester.pump();
    expect(runtime.forceFlushCalls, 1);
    expect(find.text('Backing up'), findsOneWidget);
    expect(
      tester
          .widget<PantasButton>(
            find.byWidgetPredicate(
              (w) => w is PantasButton && w.label == 'Back Up Now',
            ),
          )
          .onPressed,
      isNull,
    );
    runtime.done.complete();
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
  });
  testWidgets('offline backup shows the actual queue and cannot flush',
      (tester) async {
    final runtime = _Runtime();
    await tester.pumpAppWithProviders(
      const BackupPage(),
      overrides: [
        isAnonymousProvider.overrideWith((ref) async => false),
        entitlementProvider.overrideWith(
          (ref) =>
              Stream.value(const Entitlement(plan: EntitlementPlan.monthly)),
        ),
        syncRuntimeProvider.overrideWith((ref) => runtime),
        syncStatusProvider.overrideWith(
          (ref) => Stream.value(const SyncOffline(pendingCount: 3)),
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('3 changes'), findsOneWidget);
    expect(find.text('You need a connection to back up.'), findsOneWidget);
    expect(
      tester
          .widget<PantasButton>(
            find.byWidgetPredicate(
              (w) => w is PantasButton && w.label == 'Back Up Now',
            ),
          )
          .onPressed,
      isNull,
    );
    expect(runtime.forceFlushCalls, 0);
  });
}
