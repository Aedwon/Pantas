import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/guardian/application/minor_sharing.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

final guardianGatewayProvider = Provider<GuardianGateway>(
  (ref) => const CallableGuardianGateway(),
);

final minorSharingGateProvider = Provider<MinorSharingGate>(
  (ref) => MinorSharingGate(
    prefs: ref.watch(appPreferencesRepositoryProvider),
    settings: ref.watch(settingsRepositoryProvider),
    guardian: ref.watch(guardianGatewayProvider),
  ),
);

/// Applies the guardian's sharing choice and says whether the student's own
/// switch is locked. Settings watches it.
final minorSharingProvider = FutureProvider<MinorSharing>(
  (ref) => ref.watch(minorSharingGateProvider).sync(),
);

/// Where a student stands against the guardian requirement.
enum GuardianGate {
  /// An adult, or a student from before the requirement existed.
  notRequired,

  /// Under 18 with no request sent yet.
  needsContact,

  /// A request exists and is not confirmed. Declined and expired stay here.
  waiting,

  /// A guardian confirmed.
  cleared,
}

/// The server owns the status. The device only remembers the last answer, so
/// an offline start does not strand a student who was already cleared.
final guardianGateProvider = FutureProvider<GuardianGate>((ref) async {
  final prefs = ref.watch(appPreferencesRepositoryProvider);
  if (await prefs.ageGroup() != 'minor') return GuardianGate.notRequired;
  GuardianConsentStatus status;
  try {
    status = (await ref.watch(guardianGatewayProvider).status()).status;
    await prefs.setGuardianStatusCache(status.wire);
  } on Object {
    status = GuardianConsentStatus.parse(await prefs.guardianStatusCache());
  }
  return switch (status) {
    GuardianConsentStatus.none => GuardianGate.needsContact,
    GuardianConsentStatus.confirmed => GuardianGate.cleared,
    _ => GuardianGate.waiting,
  };
});

final guardianControllerProvider = Provider<GuardianController>(
  GuardianController.new,
);

class GuardianController {
  GuardianController(this._ref);
  final Ref _ref;

  /// Asks the server to mail a fresh link. The contact is kept on this device
  /// so Resend works without typing it again.
  Future<GuardianStatus> sendLink({
    required String guardianName,
    required String guardianEmail,
  }) async {
    final name = guardianName.trim();
    final email = guardianEmail.trim().toLowerCase();
    final prefs = _ref.read(appPreferencesRepositoryProvider);
    final status = await _ref.read(guardianGatewayProvider).sendLink(
          guardianName: name,
          guardianEmail: email,
          ageCheckNoticeVersion: await prefs.ageCheckNoticeVersion(),
        );
    await prefs.setGuardianContact(name: name, email: email);
    await prefs.setGuardianStatusCache(status.status.wire);
    _ref.invalidate(guardianGateProvider);
    return status;
  }

  /// Resends to the contact kept on this device, or null if there is none.
  Future<GuardianStatus?> resend() async {
    final contact =
        await _ref.read(appPreferencesRepositoryProvider).guardianContact();
    if (contact == null) return null;
    return sendLink(
      guardianName: contact.name,
      guardianEmail: contact.email,
    );
  }

  /// Asks the server again. A confirmation opens the age gate for good.
  Future<GuardianStatus> refresh() async {
    final status = await _ref.read(guardianGatewayProvider).status();
    final prefs = _ref.read(appPreferencesRepositoryProvider);
    await prefs.setGuardianStatusCache(status.status.wire);
    if (status.status == GuardianConsentStatus.confirmed) {
      await prefs.setPassedAgeGate(value: true);
      await prefs.clearGuardianContact();
      _ref
        ..invalidate(appPreferencesRepositoryProvider)
        ..invalidate(passedAgeGateProvider);
    }
    _ref.invalidate(guardianGateProvider);
    return status;
  }
}
