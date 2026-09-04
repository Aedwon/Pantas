import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/revenuecat_config.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';

class RevenueCatBootstrapper {
  RevenueCatBootstrapper(this._gateway);

  final RevenueCatGateway _gateway;
  String? _lastUid;

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

  Future<void> associateUid(String? uid) async {
    if (uid == null || uid == _lastUid) return;
    try {
      await _gateway.logIn(uid);
      _lastUid = uid;
    } catch (_) {
      // Keep the session usable and allow a later auth update to retry.
    }
  }
}

class RevenueCatAuthBinding {
  RevenueCatAuthBinding(this._bootstrapper);

  final RevenueCatBootstrapper _bootstrapper;
  StreamSubscription<AuthState>? _subscription;
  Future<void> _pending = Future<void>.value();

  Future<void> start({
    required AuthState initialState,
    required Stream<AuthState> changes,
  }) async {
    await _subscription?.cancel();
    _subscription = null;

    await _enqueue(initialState);
    _subscription = changes.listen(_queue);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _pending;
  }

  Future<void> _enqueue(AuthState state) {
    final next = _pending.then((_) => _associate(state));
    _pending = next;
    return next;
  }

  void _queue(AuthState state) {
    _pending = _pending.then((_) => _associate(state));
  }

  Future<void> _associate(AuthState state) {
    return _bootstrapper.associateUid(_uidFor(state));
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
  final binding =
      RevenueCatAuthBinding(ref.watch(revenueCatBootstrapperProvider));
  ref.onDispose(() {
    unawaited(binding.dispose());
  });
  return binding;
});

Future<void> bootstrapRevenueCat(ProviderContainer container) async {
  final bootstrapper = container.read(revenueCatBootstrapperProvider);
  await bootstrapper.configure(container.read(revenueCatConfigProvider));

  try {
    final initialState = await container.read(authStateProvider.future);
    final binding = container.read(revenueCatAuthBindingProvider);
    await binding.start(
      initialState: initialState,
      changes: container.read(authRepositoryProvider).authState,
    );
  } catch (_) {
    // RevenueCat identity association is optional startup infrastructure.
    // Auth and the rest of the app must remain usable when it is unavailable.
  }
}
