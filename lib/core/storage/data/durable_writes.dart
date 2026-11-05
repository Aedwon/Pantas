import 'dart:async';

import 'package:drift/drift.dart';

/// Saves browser writes that would otherwise wait in memory.
///
/// On IndexedDB, Drift flushes to storage after a plain statement but not after
/// committing a transaction, and a batch is a transaction. The commit stays in
/// memory until the next plain write, and a reload or a closed tab loses it. So
/// the last answer on a step, or the last setting changed, could vanish.
///
/// [flush] runs a plain statement soon after any write. Writes close together
/// share one flush. The subscription lasts as long as the database.
StreamSubscription<void> flushAfterWrites(
  GeneratedDatabase database, {
  required Future<void> Function() flush,
  Duration delay = const Duration(milliseconds: 50),
}) {
  Timer? pending;
  final subscription =
      database.tableUpdates(TableUpdateQuery.any()).listen((_) {
    pending ??= Timer(delay, () {
      pending = null;
      unawaited(flush().catchError((Object _) {}));
    });
  })
        ..onDone(() => pending?.cancel());
}
