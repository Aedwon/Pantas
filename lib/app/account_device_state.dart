import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';

/// Restores the study store and account preferences before auth publishes an
/// identity to the router, study repositories, or sync.
class AccountDeviceState {
  AccountDeviceState({
    required AppDatabase shared,
    required Future<AppDatabase> Function(String uid) openChild,
    required Future<void> Function(AppDatabase database) activate,
  })  : _shared = shared,
        _openChild = openChild,
        _activate = activate;

  final AppDatabase _shared;
  final Future<AppDatabase> Function(String uid) _openChild;
  final Future<void> Function(AppDatabase database) _activate;
  static const _ageOwner = 'age_state_owner_uid';
  static const _accountKeys = [
    'age_group',
    'age_check_notice_version',
    'passed_age_gate',
    'selected_exam_id',
    'onboarding_complete',
    'onboarding.date_answered',
    'setup_acceptance_recorded_for',
    'setup_acceptance_version',
    'guardian_status',
    'guardian_sharing_applied',
    'guardian_contact_name',
    'guardian_contact_email',
  ];

  Future<void> restore(AuthSession? session, String? ageGroup) async {
    final uid = session?.uid;
    final isChild = ageGroup == 'child' && uid != null;
    final database = isChild ? await _openChild(uid) : _shared;
    final prefs = AppPreferencesRepository(database);
    await database.transaction(() async {
      if (isChild) {
        await prefs.clearGuardianContact();
        await prefs.setAgeGroup('child');
        await prefs.setPassedAgeGate(value: true);
        await prefs.clearGuardianSetup();
        return;
      }

      final owner =
          await prefs.deviceValue(_ageOwner) ?? await _legacyOwner(database);
      if (owner != (uid ?? '') &&
          (owner != null || session?.isAnonymous == false)) {
        await clearSharedAccountPreferences();
      }
      await prefs.setDeviceValue(_ageOwner, uid ?? '');
      if (ageGroup != null) {
        final previousGroup = await prefs.ageGroup();
        await prefs.setAgeGroup(ageGroup);
        if (ageGroup == 'adult' || ageGroup != previousGroup) {
          await prefs.setPassedAgeGate(value: ageGroup == 'adult');
        }
      }
    });
    await _activate(database);
  }

  Future<String?> _legacyOwner(AppDatabase database) async {
    final rows = await (database.select(database.syncMeta)
          ..where(
            (row) => row.key.isIn(
              ['local_data_owner_uid', 'currentLocalGenerationUid'],
            ),
          ))
        .get();
    final owners = {for (final row in rows) row.key: row.value};
    return owners['local_data_owner_uid'] ??
        owners['currentLocalGenerationUid'];
  }

  Future<void> completeGuardianSetup() =>
      AppPreferencesRepository(_shared).clearGuardianSetup();

  Future<void> clearSharedAccountPreferences() async {
    await (_shared.delete(_shared.devicePrefs)
          ..where((row) => row.key.isIn([..._accountKeys, _ageOwner])))
        .go();
    await (_shared.delete(_shared.appPreferencesLocal)
          ..where((row) => row.key.isIn(_accountKeys)))
        .go();
  }
}
