import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/platform/firebase_report_sender.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/storage/storage.dart';

/// Where queued reports go. Tests replace it.
final reportSenderProvider = Provider<ReportSender>(
  (ref) => FirebaseReportSender(),
);

/// The one queue the app shares. It tries a failed send again every minute
/// while the app is open.
final reportQueueProvider = Provider<ReportQueue>((ref) {
  final queue = ReportQueue(
    ref.watch(appDatabaseProvider),
    sender: ref.watch(reportSenderProvider),
    // Read at each use, so a report is always tied to whoever is signed in
    // then. A guest counts as an account.
    account: () => switch (ref.read(authStateProvider).valueOrNull) {
      AnonymousAuthState(:final uid) => uid,
      SignedInAuthState(:final user) => user.uid,
      _ => null,
    },
    retryEvery: const Duration(minutes: 1),
  );
  ref.onDispose(queue.dispose);
  return queue;
});

/// Sends the queued reports at the moments the app can: when it starts, when an
/// account signs in (a guest counts), and each time it returns to the front.
/// Read once at startup to keep it alive. A failure leaves the reports queued.
final reportSyncProvider = Provider<void>((ref) {
  final queue = ref.watch(reportQueueProvider);
  void send() => unawaited(
        queue.sendPending().then<void>(
              (_) {},
              onError: (Object _, StackTrace __) {},
            ),
      );
  ref.listen<AsyncValue<AuthState>>(
    authStateProvider,
    (_, next) {
      final state = next.valueOrNull;
      if (state is SignedInAuthState || state is AnonymousAuthState) send();
    },
    fireImmediately: true,
  );
  final observer = _ResumeObserver(send);
  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));
});

class _ResumeObserver extends WidgetsBindingObserver {
  _ResumeObserver(this._onResume);
  final VoidCallback _onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onResume();
  }
}
