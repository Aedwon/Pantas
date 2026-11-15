import 'package:pantas/core/storage/storage.dart';

/// Remembers, for each learner on this device, that the Home notice about
/// screen counts was shown. The record stays in device storage under the
/// account id and is never sent anywhere.
///
/// Counting starts on the learner's next visit after the notice was shown, so
/// they have time to turn the reports off first. A visit is one run of the
/// app: one instance of this class. Dismissing the notice is a record that it
/// was shown, not consent.
class ScreenCountsNoticeStore {
  ScreenCountsNoticeStore(this._preferences);

  final AppPreferencesRepository _preferences;

  static const _shown = 'shown';
  static const _dismissed = 'dismissed';

  // Learners the notice was first shown to in this visit.
  final Set<String> _shownThisVisit = {};

  /// The device-storage key for one account.
  static String keyFor(String accountId) => 'screen_counts_notice_$accountId';

  Future<String?> _value(String accountId) =>
      _preferences.deviceValue(keyFor(accountId));

  /// True once the notice was shown to [accountId] in an earlier visit.
  Future<bool> countingAllowed(String accountId) async =>
      !_shownThisVisit.contains(accountId) && await _value(accountId) != null;

  /// True when [accountId] closed the notice.
  Future<bool> isDismissed(String accountId) async =>
      await _value(accountId) == _dismissed;

  /// Records that the notice is on screen for [accountId].
  Future<void> markShown(String accountId) async {
    if (await _value(accountId) != null) return;
    _shownThisVisit.add(accountId);
    await _preferences.setDeviceValue(keyFor(accountId), _shown);
  }

  /// Records that [accountId] closed the notice.
  Future<void> markDismissed(String accountId) async {
    if (await _value(accountId) == null) _shownThisVisit.add(accountId);
    await _preferences.setDeviceValue(keyFor(accountId), _dismissed);
  }
}
