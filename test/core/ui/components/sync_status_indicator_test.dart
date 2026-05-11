import 'package:cse_cet_reviewer/core/ui/components/sync_status_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('SyncStatusIndicator', () {
    testWidgets('synced state shows Synced label', (tester) async {
      await tester.pumpApp(
        const SyncStatusIndicator(state: SyncState.synced),
      );
      expect(find.text('Synced'), findsOneWidget);
    });

    testWidgets('syncing state shows Syncing label', (tester) async {
      await tester.pumpApp(
        const SyncStatusIndicator(state: SyncState.syncing),
      );
      expect(find.textContaining('Syncing'), findsOneWidget);
    });

    testWidgets('offline state shows Offline label', (tester) async {
      await tester.pumpApp(
        const SyncStatusIndicator(state: SyncState.offline),
      );
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('fires onTap when tapped in non-synced state', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        SyncStatusIndicator(
          state: SyncState.offline,
          onTap: () => tapped = true,
        ),
      );
      await tester.tap(find.byType(SyncStatusIndicator));
      expect(tapped, isTrue);
    });
  });
}
