import 'dart:async';
import 'dart:ui' show Rect;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';
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
  testWidgets('web explains server study records on Free', (tester) async {
    await tester.pumpAppWithProviders(
      const BackupPage(),
      overrides: [
        paymentsOnWebProvider.overrideWithValue(true),
        isAnonymousProvider.overrideWith((ref) async => true),
        entitlementProvider
            .overrideWith((ref) => Stream.value(const Entitlement.free())),
      ],
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Your browser saves data on this device. Pantas also keeps '
          'answers and study activity on its servers, including on Free. '
          'Pro adds backup and syncing across your devices.'),
      findsOneWidget,
    );
    expect(find.text('Your progress is saved to your account.'), findsNothing);
  });
  testWidgets('web shows live backup status for signed-in Pro', (tester) async {
    await tester.pumpAppWithProviders(
      const BackupPage(),
      overrides: [
        paymentsOnWebProvider.overrideWithValue(true),
        isAnonymousProvider.overrideWith((ref) async => false),
        entitlementProvider.overrideWith(
          (ref) =>
              Stream.value(const Entitlement(plan: EntitlementPlan.monthly)),
        ),
        syncStatusProvider
            .overrideWith((ref) => Stream.value(const SyncUpToDate())),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Back Up Now'), findsWidgets);
    expect(find.text(webFreeBackupNote), findsNothing);
  });
  testWidgets('a failed backup says so and offers Try Again', (tester) async {
    await tester.pumpAppWithProviders(
      const BackupPage(),
      overrides: [
        paymentsOnWebProvider.overrideWithValue(true),
        isAnonymousProvider.overrideWith((ref) async => false),
        entitlementProvider.overrideWith(
          (ref) =>
              Stream.value(const Entitlement(plan: EntitlementPlan.monthly)),
        ),
        syncStatusProvider
            .overrideWith((ref) => Stream.value(const SyncError())),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text("Couldn't back up"), findsOneWidget);
    expect(find.text('Try Again'), findsWidgets);
  });
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
    await tester.tap(find.byType(PantasButton).last);
    await tester.pump();
    expect(runtime.forceFlushCalls, 1);
    expect(find.text('Backing up'), findsOneWidget);
    expect(
      tester
          .widget<PantasButton>(
            find.byType(PantasButton).last,
          )
          .onPressed,
      isNull,
    );
    runtime.done.complete();
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
  });
  testWidgets('offline backup says Offline and cannot flush', (tester) async {
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
    expect(find.text('Waiting to back up'), findsNothing);
    final button = tester.widgetList<PantasButton>(
      find.byWidgetPredicate(
        (w) => w is PantasButton && w.label == 'Back Up Now' && !w.busy,
      ),
    );
    expect(button.single.onPressed, isNull);
    expect(runtime.forceFlushCalls, 0);
  });

  // Aedwon, Nov 8, with a screen recording: rows came and went and the button
  // moved several times while it was backing up. Every state keeps one layout.
  testWidgets('nothing moves while the backup status changes', (tester) async {
    final statuses = StreamController<SyncStatus>();
    addTearDown(statuses.close);
    await tester.pumpAppWithProviders(
      const BackupPage(),
      overrides: [
        isAnonymousProvider.overrideWith((ref) async => false),
        entitlementProvider.overrideWith(
          (ref) =>
              Stream.value(const Entitlement(plan: EntitlementPlan.monthly)),
        ),
        syncStatusProvider.overrideWith((ref) => statuses.stream),
      ],
    );
    // The visible button is drawn over its hidden width guide.
    final button = find.byType(PantasButton);
    final section = find.byType(SettingsSection);
    Rect? sectionRect;
    Rect? buttonRect;
    for (final status in <SyncStatus>[
      const SyncActivating(),
      const Syncing(pendingCount: 1),
      const SyncActivating(),
      const Syncing(),
      SyncUpToDate(lastSyncedAt: DateTime.now()),
      const SyncOffline(pendingCount: 3),
      const SyncError(),
    ]) {
      statuses.add(status);
      await tester.pump();
      await tester.pump();
      final c = tester.getRect(section.first);
      final b = tester.getRect(button.last);
      expect(c, sectionRect ?? c, reason: '$status resized the status card');
      expect(b, buttonRect ?? b, reason: '$status moved or resized the button');
      sectionRect = c;
      buttonRect = b;
    }
  });
}
