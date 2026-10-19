import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_mirror.dart';
import 'package:pantas/core/content/remote/content_remote.dart';
import 'package:pantas/core/content/remote/content_service.dart';
import 'package:pantas/core/storage/storage.dart';

/// Built only when read, so native builds never construct it.
final contentRemoteProvider =
    Provider<ContentRemote>((ref) => CallableContentRemote());

final contentCacheProvider = Provider<ContentCache>(
  (ref) => ContentCache(ref.watch(appDatabaseProvider)),
);

/// The web content source. Native builds keep reading the bundled content
/// database and never read this provider.
final contentServiceProvider = Provider<ContentService>((ref) {
  final service = ContentService(
    remote: ref.watch(contentRemoteProvider),
    cache: ref.watch(contentCacheProvider),
  );
  String? lastUid;
  ref
    ..listen<AsyncValue<AuthState>>(
      authStateProvider,
      (_, next) {
        final state = next.value;
        final uid = _uidOf(state);
        // Signing out, or switching accounts, removes Pro-only fields at once.
        if (state is SignedOutAuthState ||
            (lastUid != null && uid != lastUid)) {
          service.onSignedOut();
        }
        if (state is! UnknownAuthState) lastUid = uid;
      },
      fireImmediately: true,
    )
    ..onDispose(service.dispose);
  return service;
});

String? _uidOf(AuthState? state) => switch (state) {
      AnonymousAuthState(:final uid) => uid,
      SignedInAuthState(:final user) => user.uid,
      _ => null,
    };

/// The web content database's filler and fetch hook. Native builds never read
/// it. A new account (or a switch of account) refreshes the catalog, because
/// the first refresh at start may have run before anyone was signed in.
final contentMirrorProvider = Provider<ContentMirror>((ref) {
  final mirror = ContentMirror(
    db: ref.watch(contentDatabaseProvider),
    service: ref.watch(contentServiceProvider),
  );
  ref
    ..listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
      final uid = _uidOf(next.value);
      if (uid != null && uid != _uidOf(previous?.value)) {
        unawaited(mirror.refreshCatalog());
      }
    })
    ..onDispose(() => unawaited(mirror.dispose()));
  return mirror;
});
