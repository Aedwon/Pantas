import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/sync/eligibility/sync_claim_gateway.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/revenuecat_config.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';

class RevenueCatBootstrapper {
  RevenueCatBootstrapper(this._gateway);

  final RevenueCatGateway _gateway;
  String? _lastUid;
  int _identityEpoch = 0;

  Future<void> configure(RevenueCatConfig config) async {
    try {
      // Hydration is independent from SDK configuration. A build with a
      // missing RevenueCat key must still recover the last confirmed local
      // entitlement instead of silently failing closed to Free.
      await _gateway.initialize();

      final apiKey = config.androidApiKey;
      if (apiKey == null) return;
      await _gateway.configure(androidApiKey: apiKey);
    } catch (_) {
      // Payment startup is optional infrastructure. A persistence,
      // configuration, or initial refresh failure must not prevent the rest
      // of the app from starting.
    }
  }

  Future<void> prepareForIdentityChange() async {
    _identityEpoch++;
    _lastUid = null;
    final gateway = _gateway;
    if (gateway is RevenueCatAccountGateway) await gateway.clearIdentity();
  }

  Future<void> associateUid(String? uid, {bool force = false}) async {
    if (!force && uid != null && uid == _lastUid) return;
    try {
      if (uid == null) {
        await prepareForIdentityChange();
        final gateway = _gateway;
        if (gateway is RevenueCatAccountGateway) await gateway.logOut();
      } else {
        final epoch = _identityEpoch;
        await _gateway.logIn(uid);
        if (epoch == _identityEpoch) _lastUid = uid;
      }
    } catch (_) {
      // The old account was cleared before the SDK call. Purchases remain
      // blocked until a later auth update can finish the identity change.
    }
  }
}

class RevenueCatAuthBinding {
  RevenueCatAuthBinding(
    this._bootstrapper, {
    String? Function()? currentFirebaseUid,
    ClaimsChangeBinding? claimsBinding,
  })  : _currentFirebaseUid = currentFirebaseUid,
        _claimsBinding = claimsBinding;

  final RevenueCatBootstrapper _bootstrapper;
  final String? Function()? _currentFirebaseUid;
  final ClaimsChangeBinding? _claimsBinding;
  StreamSubscription<AuthState>? _subscription;
  Future<void> _pending = Future<void>.value();
  AuthState? _latestState;
  AuthState? _associatedState;

  Future<void> start({
    required AuthState initialState,
    required Stream<AuthState> changes,
  }) async {
    await _subscription?.cancel();
    _subscription = null;

    _latestState = initialState;
    _subscription = changes.listen(_queue);
    await _enqueue(initialState);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _pending;
    await _claimsBinding?.dispose();
  }

  Future<void> _enqueue(AuthState state) {
    final next = _pending.then((_) => _associate(state));
    _pending = next;
    return next;
  }

  void _queue(AuthState state) {
    final previous = _latestState;
    _latestState = state;
    // Clear synchronously before the next queued SDK association. An old
    // in-flight login cannot restore the account once its epoch changed.
    final clear = state is! UnknownAuthState &&
            (previous == null || _uidFor(previous) != _uidFor(state))
        ? _bootstrapper.prepareForIdentityChange()
        : Future<void>.value();
    _pending = _pending.then((_) async {
      await clear;
      await _associate(state);
    });
  }

  Future<void> _associate(AuthState state) async {
    if (state != _latestState || state is UnknownAuthState) return;
    final uid =
        _currentFirebaseUid == null ? _uidFor(state) : _currentFirebaseUid();
    await _bootstrapper.associateUid(
      uid,
      force: uid == _uidFor(state) &&
          _associatedState is AnonymousAuthState &&
          state is SignedInAuthState,
    );
    await _claimsBinding?.associate(state is SignedInAuthState ? uid : null);
    if (_latestState != null && _uidFor(state) == _uidFor(_latestState!)) {
      _associatedState = state;
    }
  }

  String? _uidFor(AuthState state) {
    return switch (state) {
      AnonymousAuthState(:final uid) => uid,
      SignedInAuthState(:final user) => user.uid,
      _ => null,
    };
  }
}

final revenueCatBootstrapperProvider = Provider<RevenueCatBootstrapper>((ref) {
  return RevenueCatBootstrapper(ref.watch(revenueCatGatewayProvider));
});

final revenueCatAuthBindingProvider = Provider<RevenueCatAuthBinding>((ref) {
  final binding = RevenueCatAuthBinding(
    ref.watch(revenueCatBootstrapperProvider),
    currentFirebaseUid: () =>
        ref.read(authRepositoryProvider).currentSession?.uid,
    claimsBinding: ClaimsChangeBinding(
      watchChanges: (uid) => FirebaseFirestore.instance
          .doc('users/$uid')
          .snapshots()
          .map((doc) => doc.data()?['claimsChangedAt']),
      refresh: refreshPaymentClaimToken,
    ),
  );
  ref.onDispose(() {
    unawaited(binding.dispose());
  });
  return binding;
});

/// The gateway can be rebuilt after startup: onboarding and the exam page
/// refresh the app preferences it depends on. The identity hook and the
/// sign-in binding therefore always use the current one, and every rebuilt
/// binding signs its new gateway in at once (staging, Nov 26: a Pro account
/// showed Free after onboarding until a reload).
Future<void> bootstrapRevenueCat(ProviderContainer container) async {
  container.read(authRepositoryProvider).beforeIdentityChange = () =>
      container.read(revenueCatBootstrapperProvider).prepareForIdentityChange();
  // Startup can run twice on one container (the local sample student): one
  // listener only, so a rebuilt binding is started once.
  _bindingListeners[container]?.close();
  _bindingListeners[container] = container.listen<RevenueCatAuthBinding>(
    revenueCatAuthBindingProvider,
    (previous, next) {
      if (!identical(previous, next)) unawaited(_startBinding(container, next));
    },
  );
  await _startBinding(container, container.read(revenueCatAuthBindingProvider));
}

final _bindingListeners =
    Expando<ProviderSubscription<RevenueCatAuthBinding>>('payment sign-in');

Future<void> _startBinding(
  ProviderContainer container,
  RevenueCatAuthBinding binding,
) async {
  // A binding replaced while it was being set up is never started: only the
  // binding of the current gateway may sign in or out.
  bool current() =>
      identical(container.read(revenueCatAuthBindingProvider), binding);
  try {
    await container
        .read(revenueCatBootstrapperProvider)
        .configure(container.read(revenueCatConfigProvider));
    final initialState = await container.read(authStateProvider.future);
    if (!current()) return;
    await binding.start(
      initialState: initialState,
      changes: container.read(authRepositoryProvider).authState,
    );
  } catch (_) {
    // RevenueCat identity association is optional startup infrastructure.
    // Auth and the rest of the app must remain usable when it is unavailable.
  }
}
