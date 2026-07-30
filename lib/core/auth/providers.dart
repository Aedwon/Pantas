import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw UnimplementedError(
    'Override authRepositoryProvider after Firebase is configured',
  ),
);

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authState;
});

final currentUserProvider = FutureProvider<AuthUser?>((ref) async {
  final state = await ref.watch(authStateProvider.future);
  return switch (state) {
    SignedInAuthState(:final user) => user,
    _ => null,
  };
});

final isAnonymousProvider = FutureProvider<bool>((ref) async {
  final state = await ref.watch(authStateProvider.future);
  return state is AnonymousAuthState;
});

final isSignedInProvider = FutureProvider<bool>((ref) async {
  final state = await ref.watch(authStateProvider.future);
  return state is SignedInAuthState;
});
