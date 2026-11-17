// Checks that one account's study data never reaches another account's
// backup when two people use the same browser.
//
// The pieces are the real ones: the auth repository, the local database and
// its sign-out wipe, and the Sync runtime (full upload included). Only the
// cloud is faked. The account transition gateway is left as the no-op one,
// because that is what the app wires today (auth bootstrap passes no
// builder).
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/sync_runtime_bootstrap.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/eligibility/sync_claim_gateway.dart';
import 'package:pantas/core/sync/eligibility/sync_entitlement.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/functions_gateway.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/sync/providers.dart';

import '../../helpers/in_memory_database.dart';

/// Runs the known-gap test below instead of skipping it:
/// `flutter test --dart-define=RUN_KNOWN_GAPS=true <this file>`.
const _runKnownGaps = bool.fromEnvironment('RUN_KNOWN_GAPS');

const _accountA = 'user-a';
const _accountB = 'user-b';

/// Row ids that only account A ever wrote.
const _aRowIds = ['a-attempt-1', 'a-question-1', 'a-review-1'];

void main() {
  test(
      'signing out of A and signing in as B uploads nothing of A to B '
      '(the Sign Out button path)', () async {
    final h = await _Harness.open();
    addTearDown(h.close);

    h.auth.session = const AuthSession(uid: _accountA);
    await _seedAnswers(h.db);
    await h.syncCurrentSession(pro: true);
    expect(
      h.paths(_accountA),
      containsAll(_aRowIds.map((id) => contains('/$id'))),
      reason: 'the harness must upload A to A, or the check below is empty',
    );

    // Settings > Sign Out.
    await h.repository.signOut();
    expect(h.auth.session?.isAnonymous, isTrue);
    await h.syncCurrentSession(pro: false);

    // B signs in with an email code from the fresh guest session.
    await h.signInWithCode(_accountB);
    expect(h.auth.session?.uid, _accountB);
    await h.syncCurrentSession(pro: true);

    expect(h.leakedInto(_accountB), isEmpty);
    expect(await h.localRowsOf(_aRowIds), isEmpty);
  });

  test(
    'switching from A to B without Sign Out uploads nothing of A to B '
    '(email code entered while A is signed in)',
    () async {
      final h = await _Harness.open();
      addTearDown(h.close);

      h.auth.session = const AuthSession(uid: _accountA);
      await _seedAnswers(h.db);
      await h.syncCurrentSession(pro: true);
      expect(h.paths(_accountA), isNotEmpty);

      // /auth/email-link has no signed-in guard. A signed-in user who opens
      // it and enters another address switches accounts here, and that
      // switch never runs the local wipe.
      await h.signInWithCode(_accountB);
      expect(h.auth.session?.uid, _accountB);
      await h.syncCurrentSession(pro: true);

      expect(h.leakedInto(_accountB), isEmpty);
    },
    skip: _runKnownGaps
        ? false
        : 'Known gap, documented not fixed: an account switch without Sign '
            'Out keeps the old account local rows and the new account first '
            'backup uploads them. Run with --dart-define=RUN_KNOWN_GAPS=true '
            'to see it fail.',
  );
}

class _Harness {
  _Harness._({
    required this.db,
    required this.contentDb,
    required this.container,
    required this.cloud,
    required this.auth,
    required this.repository,
    required this.runtime,
  });

  static Future<_Harness> open() async {
    final db = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    final cloud = FakeFirestoreGateway();
    final runtime = await buildConfiguredSyncRuntime(
      container,
      firestoreGateway: cloud,
      functionsGateway: FakeSyncFunctionsGateway(),
      claimGateway: const _AllowClaims(),
      deviceId: 'shared-browser',
    );
    final auth = _FakeAuth();
    final repository = AuthRepository(
      gateway: auth,
      functionsGateway: const _Functions(),
      emailCodeGateway: const _Codes(),
      customTokenGateway: auth,
      // As auth bootstrap builds it in the app.
      localStateWiper: SyncLocalStateWiper(db),
    );
    return _Harness._(
      db: db,
      contentDb: contentDb,
      container: container,
      cloud: cloud,
      auth: auth,
      repository: repository,
      runtime: runtime,
    );
  }

  final AppDatabase db;
  final ContentDatabase contentDb;
  final ProviderContainer container;
  final FakeFirestoreGateway cloud;
  final _FakeAuth auth;
  final AuthRepository repository;
  final SyncRuntimeSurface runtime;

  /// What the auth-to-Sync binding does on every auth event.
  Future<void> syncCurrentSession({required bool pro}) {
    final session = auth.session;
    return runtime.update(
      identity: session == null
          ? const SyncIdentity(uid: SyncIdentity.signedOutUid)
          : SyncIdentity(uid: session.uid, isAnonymous: session.isAnonymous),
      entitlement: pro ? SyncEntitlement.pro : SyncEntitlement.free,
    );
  }

  Future<void> signInWithCode(String uid) async {
    _Codes.nextUid = uid;
    final result = await repository.verifyCode('challenge-1', '482139');
    expect(result, const SignInResult.switchedToExisting());
  }

  Iterable<String> paths(String uid) =>
      cloud.documents.keys.where((path) => path.startsWith('users/$uid/'));

  /// Every document in [uid]'s cloud that carries one of A's row ids.
  List<String> leakedInto(String uid) => [
        for (final path in paths(uid))
          if (_aRowIds.any((id) => path.endsWith('/$id'))) path,
      ];

  Future<List<String>> localRowsOf(List<String> ids) async {
    final attempts = await db.select(db.attemptsLocal).get();
    final reviews = await db.select(db.reviewLogs).get();
    final cards = await db.select(db.reviewStateLocal).get();
    return [
      ...attempts.map((row) => row.id),
      ...reviews.map((row) => row.id),
      ...cards.map((row) => row.questionId),
    ].where(ids.contains).toList();
  }

  Future<void> close() async {
    await runtime.quiesce(flush: false);
    container.dispose();
    await db.close();
    await contentDb.close();
  }
}

/// A's answers: one quiz attempt, the card it scheduled, and its review.
Future<void> _seedAnswers(AppDatabase db) async {
  final stamp = DateTime.utc(2026, 11, 18);
  await db.into(db.attemptsLocal).insert(
        AttemptsLocalCompanion.insert(
          id: 'a-attempt-1',
          examId: 'cse',
          startedAt: stamp,
          completedAt: Value(stamp),
          itemsJson: '[]',
        ),
      );
  await db.into(db.reviewStateLocal).insert(
        ReviewStateLocalCompanion.insert(
          questionId: 'a-question-1',
          questionVersion: 1,
          stage: 'review',
          stability: 1,
          difficulty: 1,
          due: stamp,
          lastReview: stamp,
          reps: 1,
          lapses: 0,
          elapsedDays: 1,
          scheduledDays: 1,
        ),
      );
  await db.into(db.reviewLogs).insert(
        ReviewLogsCompanion.insert(
          id: 'a-review-1',
          questionId: 'a-question-1',
          rating: 3,
          state: 2,
          due: stamp,
          stability: 1,
          difficulty: 1,
          elapsedDays: 1,
          lastElapsedDays: 1,
          scheduledDays: 1,
          review: stamp,
          durationMs: 1000,
          isCorrect: true,
        ),
      );
}

String _tokenFor(String uid) {
  String part(Object value) =>
      base64Url.encode(utf8.encode(json.encode(value))).replaceAll('=', '');
  return '${part({'alg': 'RS256'})}.${part({'uid': uid})}.signature';
}

class _FakeAuth implements AuthGateway, CustomTokenAuthGateway {
  AuthSession? session;
  var _anonymous = 0;

  @override
  AuthSession? get currentSession => session;

  @override
  Stream<AuthSession?> get authStateChanges => Stream.value(session);

  @override
  Future<AuthSession> signInAnonymously() async {
    _anonymous += 1;
    return session = AuthSession(uid: 'guest-$_anonymous', isAnonymous: true);
  }

  @override
  Future<void> signInWithCustomToken(String token) async {
    session = AuthSession(uid: customTokenUid(token)!);
  }

  @override
  Future<void> signOut() async => session = null;

  @override
  Future<AuthSession> linkWithGoogleCredential(GoogleAuthTokens tokens) =>
      throw UnimplementedError();

  @override
  Future<AuthSession> signInWithGoogleCredential(GoogleAuthTokens tokens) =>
      throw UnimplementedError();

  @override
  Future<void> reauthenticateWithGoogleCredential(GoogleAuthTokens tokens) =>
      throw UnimplementedError();
}

class _Codes implements EmailCodeGateway {
  const _Codes();

  static String nextUid = _accountB;

  @override
  Future<EmailCodeRequest> requestCode(String email) async =>
      const EmailCodeRequest(resendAfterSeconds: 60, challengeId: 'c-1');

  @override
  Future<String> verifyCode(String challengeId, String code) async =>
      _tokenFor(nextUid);
}

class _Functions implements AuthFunctionsGateway {
  const _Functions();

  @override
  Future<void> recordSignInEvent() async {}

  @override
  Future<Uri> exportData() => throw UnimplementedError();

  @override
  Future<void> deleteAccount() => throw UnimplementedError();
}

class _AllowClaims implements SyncClaimGateway {
  const _AllowClaims();

  @override
  Future<bool> refreshProClaim({
    required String uid,
    bool force = true,
  }) async =>
      true;
}
