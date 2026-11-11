import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

/// Where optional usage sharing stands for this device.
enum MinorSharing {
  /// An adult, or no age group yet. The student's own choice applies.
  notMinor,

  /// A minor whose guardian has not allowed sharing. Sharing stays off and the
  /// student cannot turn it on.
  locked,

  /// A minor whose guardian allowed sharing. The student may turn it off.
  allowed,
}

/// Applies the guardian's sharing choice to a minor's device.
///
/// The guardian's choice is read from the server. When it is on, sharing turns
/// on once and a local flag records that, so a student who turns it off stays
/// off. When it is off, sharing turns off and the flag clears, so a later
/// re-allow applies once again.
class MinorSharingGate {
  MinorSharingGate({
    required AppPreferencesRepository prefs,
    required DriftSettingsRepository settings,
    required GuardianGateway guardian,
  })  : _prefs = prefs,
        _settings = settings,
        _guardian = guardian;

  final AppPreferencesRepository _prefs;
  final DriftSettingsRepository _settings;
  final GuardianGateway _guardian;

  Future<MinorSharing> sync() async {
    if (await _prefs.ageGroup() != 'minor') return MinorSharing.notMinor;
    final applied = await _prefs.guardianSharingApplied();
    bool allowed;
    try {
      allowed = (await _guardian.status()).sharingAllowed;
    } on Object {
      // Offline or a server error: change nothing. Without a guardian grant
      // already applied here, the switch stays locked.
      return applied ? MinorSharing.allowed : MinorSharing.locked;
    }
    if (!allowed) {
      if ((await _settings.readUserSettings()).helpImproveApp) {
        await _settings.updateHelpImproveApp(enabled: false);
      }
      if (applied) await _prefs.setGuardianSharingApplied(value: false);
      return MinorSharing.locked;
    }
    if (!applied) {
      await _settings.updateHelpImproveApp(enabled: true);
      await _prefs.setGuardianSharingApplied(value: true);
    }
    return MinorSharing.allowed;
  }
}
