import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/client_report.dart';
import 'package:pantas/core/telemetry/screen_counts.dart';
import 'package:pantas/core/telemetry/screen_counts_notice.dart';

/// Whether this build counts screens at all. Tests override it.
final screenCountsFlagProvider =
    Provider<bool>((ref) => screenCountsInClientReports);

/// What this device remembers about the screen counts notice, for each
/// learner. One store lives as long as the app is open, so it knows which
/// learners saw the notice first in this visit.
final screenCountsNoticeStoreProvider = Provider<ScreenCountsNoticeStore>(
  (ref) => ScreenCountsNoticeStore(ref.watch(appPreferencesRepositoryProvider)),
);

/// The id of the account that is using the app, or null when nobody is.
final screenCountsAccountIdProvider = FutureProvider<String?>((ref) async {
  final state = await ref.watch(authStateProvider.future);
  return switch (state) {
    SignedInAuthState(:final user) => user.uid,
    AnonymousAuthState(:final uid) => uid,
    _ => null,
  };
});

/// Opens the reporter's screen counts for the current learner once they saw
/// the notice in an earlier visit, and closes them for anyone else. Watched
/// by the app.
final screenCountsGateProvider = Provider<void>((ref) {
  if (!ref.watch(screenCountsFlagProvider)) return;
  final store = ref.watch(screenCountsNoticeStoreProvider);
  var latest = 0;
  Future<void> apply(String? accountId) async {
    final mine = ++latest;
    if (accountId == null) {
      ClientReporter.active?.screenCountsAllowed = false;
      return;
    }
    final allowed = await store.countingAllowed(accountId);
    if (mine == latest) ClientReporter.active?.screenCountsAllowed = allowed;
  }

  ref.listen(
    screenCountsAccountIdProvider,
    (previous, next) {
      // While the account is not known yet, or changing, nobody is counted.
      if (next.isLoading) {
        ++latest;
        ClientReporter.active?.screenCountsAllowed = false;
        return;
      }
      apply(next.valueOrNull);
    },
    fireImmediately: true,
  );
});
