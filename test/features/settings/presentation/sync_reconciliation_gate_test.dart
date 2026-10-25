import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/eligibility/sync_entitlement.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/presentation/widgets/sync_reconciliation_gate.dart';
import 'package:pantas/l10n/app_localizations.dart';

void main() {
  testWidgets('normal states render child without reconciliation overlay',
      (tester) async {
    final runtime = GateRuntime(const SyncUpToDate());
    await tester.pumpWidget(_app(runtime));

    expect(find.text('underlying'), findsOneWidget);
    expect(find.text('Choose which progress to keep'), findsNothing);
  });

  testWidgets('B3 prompt is blocking and exposes exactly two frozen choices',
      (tester) async {
    final runtime = GateRuntime(
      const SyncReconciliationRequired(activeGenerationId: 'gen-cloud'),
    );
    await tester.pumpWidget(_app(runtime));

    expect(find.text('Choose which progress to keep'), findsOneWidget);
    expect(
      find.text(
        'Pantas found progress on this device and in your account. '
        'Choose one copy to keep before syncing starts.',
      ),
      findsOneWidget,
    );
    expect(
      find.byType(CenteredDialog),
      findsOneWidget,
    );
    expect(
      find.text('Keep my account'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is ModalBarrier && !widget.dismissible,
      ),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets(
      'choices delegate to runtime and overlay cannot dismiss by tapping '
      'outside', (tester) async {
    final runtime = GateRuntime(
      const SyncReconciliationRequired(activeGenerationId: 'gen-cloud'),
    );
    await tester.pumpWidget(_app(runtime));

    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(find.text('Choose which progress to keep'), findsOneWidget);

    await tester.tap(find.text('Keep this device'));
    await tester.pump();
    expect(runtime.choices, [SyncReconciliationChoice.keepThisDevice]);
  });
}

Widget _app(GateRuntime runtime) {
  return ProviderScope(
    overrides: [syncRuntimeProvider.overrideWith((ref) => runtime)],
    child: MaterialApp(
      theme: buildLightTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: SyncReconciliationGate(
          child: Text('underlying'),
        ),
      ),
    ),
  );
}

class GateRuntime implements SyncRuntimeSurface {
  GateRuntime(this.currentStatus);

  @override
  final SyncStatus currentStatus;
  final choices = <SyncReconciliationChoice>[];

  @override
  SyncRuntimeKind get runtimeKind => SyncRuntimeKind.configured;

  @override
  Stream<SyncStatus> get statuses => Stream.value(currentStatus);

  @override
  Future<void> update({
    required SyncIdentity identity,
    required SyncEntitlement entitlement,
  }) async {}

  @override
  Future<void> chooseReconciliation(SyncReconciliationChoice choice) async {
    choices.add(choice);
  }

  @override
  Future<void> forceFlush() async {}

  @override
  Future<void> quiesce({required bool flush}) async {}
}
