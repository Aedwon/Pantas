import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/platform/account_access.dart';
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

final accountAccessProvider = Provider<AccountAccess>((ref) => accountAccess);

/// Held before sign-out, so a failed cleanup cannot reopen the app.
final guardianAccountClosedProvider = StateProvider<String?>((ref) => null);

Future<void> _closeAccount(Ref ref, String? uid) async {
  final auth = ref.read(authRepositoryProvider);
  if (uid == null || auth.currentSession?.uid != uid) return;
  if (ref.read(guardianAccountClosedProvider) == uid) return;
  ref.read(guardianAccountClosedProvider.notifier).state = uid;
  await ref.read(appPreferencesRepositoryProvider).setDeviceValue(
        'guardian_closed_uid',
        uid,
      );
  ref.read(accountAccessProvider).close(uid);
  if (auth.currentSession?.uid != uid) return;
  try {
    await auth.signOut();
  } on Object {
    // Keep the end state even if local cleanup or sign-out is unavailable.
  }
}

/// Listen before bootstrap finishes and refresh consent when the app resumes.
final guardianAccountLifecycleProvider = Provider<void>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final access = ref.watch(accountAccessProvider);
  final subscription = access.closures.listen((uid) {
    unawaited(_closeAccount(ref, uid));
  });
  ref
    ..onDispose(() => unawaited(subscription.cancel()))
    ..listen(authStateProvider, (_, next) {
      final session = auth.currentSession;
      if (session != null && access.isClosed(session.uid)) {
        unawaited(_closeAccount(ref, session.uid));
      } else if (session != null &&
          !session.isAnonymous &&
          ref.read(guardianAccountClosedProvider) != session.uid) {
        ref.read(guardianAccountClosedProvider.notifier).state = null;
        ref.invalidate(guardianGateProvider);
      }
    });
  final lifecycle = AppLifecycleListener(
    onResume: () {
      ref.invalidate(guardianGateProvider);
    },
  );
  ref.onDispose(lifecycle.dispose);
  scheduleMicrotask(() {
    final uid = auth.currentSession?.uid;
    if (uid != null && access.isClosed(uid)) {
      unawaited(_closeAccount(ref, uid));
    }
  });
});

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

  /// Consent was withdrawn or the server closed the account.
  withdrawn,
}

/// The server owns the status. The device only remembers the last answer, so
/// an offline start does not strand a student who was already cleared.
final guardianGateProvider = FutureProvider<GuardianGate>((ref) async {
  if (ref.read(guardianAccountClosedProvider) != null) {
    return GuardianGate.withdrawn;
  }
  final session = ref.read(authRepositoryProvider).currentSession;
  final uid = session?.uid;
  final prefs = ref.watch(appPreferencesRepositoryProvider);
  final closedUid = await prefs.deviceValue('guardian_closed_uid');
  if (ref.read(authRepositoryProvider).currentSession?.uid != uid) {
    return GuardianGate.notRequired;
  }
  if (closedUid != null && closedUid.isNotEmpty) {
    if (uid == null || uid == closedUid || session!.isAnonymous) {
      ref.read(guardianAccountClosedProvider.notifier).state = closedUid;
      ref.read(accountAccessProvider).close(closedUid);
      return GuardianGate.withdrawn;
    }
    // The cached withdrawal belongs to the closed account. Clear it before
    // releasing its marker, so a failed request cannot close this new uid.
    await prefs.setGuardianStatusCache('none');
    await prefs.setDeviceValue('guardian_closed_uid', '');
  }
  if (await prefs.ageGroup() != 'minor') return GuardianGate.notRequired;
  GuardianConsentStatus status;
  try {
    status = (await ref.watch(guardianGatewayProvider).status()).status;
    if (ref.read(authRepositoryProvider).currentSession?.uid != uid) {
      return ref.read(guardianAccountClosedProvider) != null
          ? GuardianGate.withdrawn
          : GuardianGate.notRequired;
    }
    await prefs.setGuardianStatusCache(status.wire);
  } on GuardianGatewayException catch (error) {
    if (error.code == 'account-closed') {
      if (ref.read(authRepositoryProvider).currentSession?.uid != uid &&
          ref.read(guardianAccountClosedProvider) == null) {
        return GuardianGate.notRequired;
      }
      await _closeAccount(ref, uid);
      return GuardianGate.withdrawn;
    }
    status = GuardianConsentStatus.parse(await prefs.guardianStatusCache());
  } on Object {
    status = GuardianConsentStatus.parse(await prefs.guardianStatusCache());
  }
  if (status == GuardianConsentStatus.withdrawn) {
    await _closeAccount(ref, uid);
    return GuardianGate.withdrawn;
  }
  if (ref.read(guardianAccountClosedProvider) != null) {
    return GuardianGate.withdrawn;
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
    final uid = _ref.read(authRepositoryProvider).currentSession?.uid;
    GuardianStatus status;
    try {
      status = await _ref.read(guardianGatewayProvider).status();
    } on GuardianGatewayException catch (error) {
      if (error.code != 'account-closed') rethrow;
      status = const GuardianStatus(status: GuardianConsentStatus.withdrawn);
    }
    if (_ref.read(guardianAccountClosedProvider) != null) {
      return const GuardianStatus(status: GuardianConsentStatus.withdrawn);
    }
    if (_ref.read(authRepositoryProvider).currentSession?.uid != uid) {
      throw const GuardianGatewayException('account-changed');
    }
    if (status.status == GuardianConsentStatus.withdrawn) {
      await _closeAccount(_ref, uid);
      _ref.invalidate(guardianGateProvider);
      return status;
    }
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
