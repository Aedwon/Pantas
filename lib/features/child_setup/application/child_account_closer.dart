import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

/// What the device does once the server has closed a child's account
/// (withdraw or delete). The server call comes first, so a failure leaves the
/// device exactly as it was and never a half state.
// Single-method interface is intentional so tests can fake the device.
// ignore: one_member_abstracts
abstract interface class ChildAccountCloser {
  /// Erases the closed child's records from this device, signs out, and puts
  /// the device back at the start, as Delete Account does.
  ///
  /// The closed child's own store file is deleted too, not only emptied.
  ///
  /// [holderSession] is true when the parent's own sign-in (the receipt link)
  /// did the closing. The sign-out then erases everything the parent's session
  /// left on the device (rule 4d), the way sign-out does. With the child's own
  /// session the child's own store is erased here first, because a child's
  /// sign-out keeps its store for the next time that child opens.
  Future<void> finish({required bool holderSession, required String childId});
}

final childAccountCloserProvider = Provider<ChildAccountCloser>(
  _DeviceChildAccountCloser.new,
);

class _DeviceChildAccountCloser implements ChildAccountCloser {
  const _DeviceChildAccountCloser(this._ref);

  final Ref _ref;

  @override
  Future<void> finish({
    required bool holderSession,
    required String childId,
  }) async {
    final notifications = _ref.read(notificationServiceProvider);
    await notifications.cancelAll();
    if (!holderSession) {
      // The active store is this child's own (appDatabaseProvider follows the
      // active child store).
      await SyncLocalStateWiper(
        _ref.read(appDatabaseProvider),
        notifications: notifications,
        clearCustomExams: () =>
            deleteCustomContentExams(_ref.read(contentDatabaseProvider)),
      ).wipeAll();
    }
    await _ref.read(authRepositoryProvider).signOut();
    // The account is gone, so its store file goes too. A failure to remove it
    // does not undo the closing: the file holds nothing the server needs.
    try {
      await _ref.read(childStoreDeleterProvider)(childId);
    } on Object {
      // The rows were already erased above for the child's own session.
    }
    // The same reset Delete Account does, on the shared device store.
    final preferences = _ref.read(appPreferencesRepositoryProvider);
    await preferences.setCompletedOnboarding(value: false);
    await preferences.setPassedAgeGate(value: false);
    _ref
      ..invalidate(passedAgeGateProvider)
      ..invalidate(onboardingCompleteProvider)
      ..invalidate(userSettingsProvider);
  }
}
