// Checks that one account's study data never reaches another account's
// backup when two people use the same browser.
//
// The pieces are the real ones: the auth repository, the local database and
// its sign-out wipe, the Sync runtime (full upload included) and the account
// transition gateway, wired as auth bootstrap wires them. Only the cloud is
// faked.
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/account_device_state.dart';
import 'package:pantas/app/sync_runtime_bootstrap.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/eligibility/sync_claim_gateway.dart';
import 'package:pantas/core/sync/eligibility/sync_entitlement.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/functions_gateway.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/runtime/production_sync_runtime_engine.dart';
import 'package:pantas/core/sync/runtime/sync_account_transition_gateway.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';

import '../../helpers/in_memory_database.dart';

const _accountA = 'user-a';
const _accountB = 'user-b';

/// Row ids that only account A ever wrote.
const _aRowIds = ['a-attempt-1', 'a-question-1', 'a-review-1'];

void main() {
  test('sign-in restores the server age group for the current account',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final device = AccountDeviceState(
      shared: db,
      openChild: (_) => throw StateError('Unexpected child'),
      activate: (_) async {},
    );
    final auth = _FakeAuth();
    final repository = AuthRepository(
      gateway: auth,
      readAgeGroup: (session) async =>
          session.uid == _accountA ? 'adult' : 'minor',
      restoreDeviceState: device.restore,
    );
    final prefs = AppPreferencesRepository(db);
    auth.session = const AuthSession(uid: _accountA, isAnonymous: true);
    await repository.authState.first;
    expect(await prefs.readAgeGroup(), AgeGroup.unset);

    auth.session = const AuthSession(uid: _accountA);
    await repository.authState.first;
    expect(await prefs.readAgeGroup(), AgeGroup.adult);
    expect(await prefs.hasPassedAgeGate(), isTrue);
    await prefs.setSelectedExamId('exam-cse');
    await prefs.setAgeCheckNoticeVersion('previous-notice');
    await prefs.setGuardianContact(
      name: 'Previous contact',
      email: 'previous@example.com',
    );

    auth.session = const AuthSession(uid: _accountB);
    await repository.authState.first;
    expect(await prefs.readAgeGroup(), AgeGroup.minor);
    expect(await prefs.hasPassedAgeGate(), isFalse);
    expect(await prefs.selectedExamId(), isNull);
    expect(await prefs.ageCheckNoticeVersion(), isNull);
    expect(await prefs.guardianContact(), isNull);
  });

  test('holder and Free and Pro siblings keep separate local records',
      () async {
    final h = await _Harness.open();
    addTearDown(h.close);
    final stores = <String, AppDatabase>{};
    addTearDown(() async {
      for (final db in stores.values) {
        await db.close();
      }
    });
    var db = h.db;
    final device = AccountDeviceState(
      shared: h.db,
      openChild: (uid) async => stores.putIfAbsent(uid, inMemoryDatabase),
      activate: (database) async => db = database,
    );
    final auth = h.auth;
    final repository = AuthRepository(
      gateway: auth,
      functionsGateway: const _Functions(),
      customTokenGateway: auth,
      readAgeGroup: (session) async =>
          session.uid.startsWith('child-') ? 'child' : null,
      restoreDeviceState: device.restore,
      childAccounts: const _Children(),
      activeStateWiper: () => SyncLocalStateWiper(db),
    );

    auth.session = const AuthSession(
      uid: 'holder',
      email: 'holder@example.com',
    );
    await AppPreferencesRepository(db).setGuardianContact(
      name: 'Holder',
      email: 'holder@example.com',
    );
    Future<void> open(String uid) async {
      expect(
        await repository.openChildSession(uid),
        const SignInResult.switchedToExisting(),
      );
      await repository.authState.first;
      expect(auth.session?.uid, uid);
      expect(auth.session?.email, isNull);
      final prefs = AppPreferencesRepository(db);
      expect(await prefs.readAgeGroup(), AgeGroup.child);
      expect(await prefs.hasPassedAgeGate(), isTrue);
      expect(await prefs.guardianContact(), isNull);
    }

    Future<void> expectAttempts(List<String> ids) async {
      final rows = await db.select(db.attemptsLocal).get();
      expect(rows.map((row) => row.id), unorderedEquals(ids));
    }

    Future<void> seedPending(String id) async {
      await db.into(db.attemptsLocal).insert(
            AttemptsLocalCompanion.insert(
              id: id,
              examId: 'cse',
              startedAt: DateTime.utc(2026, 11, 18),
              itemsJson: '[]',
            ),
          );
      await db.into(db.pendingSync).insert(
            PendingSyncCompanion.insert(
              tableType: 'attempts',
              rowId: id,
              op: 'upsert',
              queuedAt: DateTime.utc(2026, 11, 18),
            ),
          );
    }

    await open('child-free');
    expect(await AppPreferencesRepository(h.db).guardianContact(), isNull);
    await seedPending('free-attempt');
    await AppPreferencesRepository(db).setSelectedExamId('exam_pshs_nce');

    await open('child-pro');
    await expectAttempts([]);
    expect(await AppPreferencesRepository(db).selectedExamId(), isNull);
    final proContainer = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(h.contentDb),
      ],
    );
    addTearDown(proContainer.dispose);
    final proRuntime = await buildConfiguredSyncRuntime(
      proContainer,
      firestoreGateway: h.cloud,
      functionsGateway: FakeSyncFunctionsGateway(),
      claimGateway: const _AllowClaims(),
      deviceId: 'pro-child-device',
    );
    addTearDown(() => proRuntime.quiesce(flush: false));
    await seedPending('pro-attempt');

    await open('child-free');
    await expectAttempts(['free-attempt']);
    expect(
      await AppPreferencesRepository(db).selectedExamId(),
      'exam_pshs_nce',
    );
    expect(
      (await db.select(db.pendingSync).get()).single.rowId,
      'free-attempt',
    );

    await repository.signOut();
    await repository.authState.first;
    expect(auth.session?.isAnonymous, isTrue);
    auth.session = const AuthSession(uid: 'holder');
    await open('child-free');
    await expectAttempts(['free-attempt']);
    expect(
      (await db.select(db.pendingSync).get()).single.rowId,
      'free-attempt',
    );

    await open('child-pro');
    await expectAttempts(['pro-attempt']);
    expect((await db.select(db.pendingSync).get()).single.rowId, 'pro-attempt');
    await proRuntime.update(
      identity: const SyncIdentity(uid: 'child-pro'),
      entitlement: SyncEntitlement.pro,
    );
    expect(h.paths('child-pro'), anyElement(endsWith('/pro-attempt')));
    expect(h.paths('child-pro'), isNot(anyElement(endsWith('/free-attempt'))));
    expect(h.paths('child-free'), isEmpty);
  });

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
      expect(await h.localRowsOf(_aRowIds), isEmpty);
    },
  );

  test(
      'a switch from A to B that bypasses the app (another tab, say) '
      'uploads nothing of A to B', () async {
    final h = await _Harness.open();
    addTearDown(h.close);

    h.auth.session = const AuthSession(uid: _accountA);
    await _seedAnswers(h.db);
    await h.syncCurrentSession(pro: true);
    expect(h.paths(_accountA), isNotEmpty);

    // Firebase reports B with no call through the auth repository.
    h.auth.session = null;
    await h.syncCurrentSession(pro: true);
    h.auth.session = const AuthSession(uid: _accountB);
    await h.syncCurrentSession(pro: true);

    expect(h.leakedInto(_accountB), isEmpty);
    expect(await h.localRowsOf(_aRowIds), isEmpty);
  });

  test(
      'on a device older than the owner record, a switch from A to B '
      'uploads nothing of A to B', () async {
    final h = await _Harness.open();
    addTearDown(h.close);

    h.auth.session = const AuthSession(uid: _accountA);
    await _seedAnswers(h.db);
    await h.syncCurrentSession(pro: true);
    expect(h.paths(_accountA), isNotEmpty);
    // The app that synced A predates the record.
    await (h.db.delete(h.db.syncMeta)
          ..where(
            (row) => row.key.equals(SyncRuntimeController.localDataOwnerKey),
          ))
        .go();

    await h.signInWithCode(_accountB);
    await h.syncCurrentSession(pro: true);

    expect(h.leakedInto(_accountB), isEmpty);
    expect(await h.localRowsOf(_aRowIds), isEmpty);
  });

  test('Sign Out and an account switch erase the guardian contact', () async {
    final h = await _Harness.open();
    addTearDown(h.close);
    final prefs = AppPreferencesRepository(h.db);
    Future<void> enterContact() => prefs.setGuardianContact(
          name: 'Maria',
          email: 'maria@example.com',
        );

    h.auth.session = const AuthSession(uid: _accountA);
    await _seedAnswers(h.db);
    await h.syncCurrentSession(pro: true);
    await enterContact();

    await h.repository.signOut();
    expect(await prefs.guardianContact(), isNull, reason: 'Sign Out');
    await h.syncCurrentSession(pro: false);

    // A signs in again and enters a contact, then B signs in on top.
    await h.signInWithCode(_accountA);
    await h.syncCurrentSession(pro: true);
    await enterContact();
    await h.signInWithCode(_accountB);
    await h.syncCurrentSession(pro: true);
    expect(await prefs.guardianContact(), isNull, reason: 'account switch');
  });

  test('a guest who signs in keeps the guardian contact for Resend', () async {
    final h = await _Harness.open();
    addTearDown(h.close);
    final prefs = AppPreferencesRepository(h.db);

    await h.repository.ensureAnonymous();
    await h.syncCurrentSession(pro: false);
    await prefs.setGuardianContact(name: 'Maria', email: 'maria@example.com');

    await h.signInWithCode(_accountB);
    await h.syncCurrentSession(pro: true);

    expect((await prefs.guardianContact())?.email, 'maria@example.com');
  });

  test('the wipe stops answers still arriving for A from being written',
      () async {
    final h = await _Harness.open();
    addTearDown(h.close);

    h.auth.session = const AuthSession(uid: _accountA);
    await h.syncCurrentSession(pro: true);
    Future<String?> run() async => (await (h.db.select(h.db.syncMeta)
              ..where(
                (row) => row.key.equals(ProductionSyncRuntimeEngine.runKey),
              ))
            .getSingleOrNull())
        ?.value;
    expect(await run(), startsWith('$_accountA/'));

    await SyncLocalStateWiper(h.db).wipeAll();

    // The download and upload paths check this key before each write.
    expect(await run(), isNull);
  });

  test('a Free B never sees A progress after a switch', () async {
    final h = await _Harness.open();
    addTearDown(h.close);

    h.auth.session = const AuthSession(uid: _accountA);
    await _seedAnswers(h.db);
    await h.syncCurrentSession(pro: false);

    await h.signInWithCode(_accountB);
    await h.syncCurrentSession(pro: false);

    expect(await h.localRowsOf(_aRowIds), isEmpty);
  });

  test('a guest who signs in to an existing account keeps their progress',
      () async {
    final h = await _Harness.open();
    addTearDown(h.close);

    await h.repository.ensureAnonymous();
    await h.syncCurrentSession(pro: false);
    await _seedAnswers(h.db);

    await h.signInWithCode(_accountB);
    await h.syncCurrentSession(pro: true);

    expect(await h.localRowsOf(_aRowIds), hasLength(_aRowIds.length));
    expect(
      h.paths(_accountB),
      containsAll(_aRowIds.map((id) => contains('/$id'))),
      reason: "the guest's progress is backed up to the account it joined",
    );
  });

  test('a guest who upgrades keeps their progress', () async {
    final h = await _Harness.open();
    addTearDown(h.close);

    await h.repository.ensureAnonymous();
    final guest = h.auth.session!;
    await h.syncCurrentSession(pro: false);
    await _seedAnswers(h.db);

    // Linking keeps the guest's uid and makes it a real account.
    h.auth.session = AuthSession(uid: guest.uid);
    await h.syncCurrentSession(pro: true);

    expect(await h.localRowsOf(_aRowIds), hasLength(_aRowIds.length));
  });

  test('the same account signed in again keeps its own progress', () async {
    final h = await _Harness.open();
    addTearDown(h.close);

    h.auth.session = const AuthSession(uid: _accountA);
    await _seedAnswers(h.db);
    await h.syncCurrentSession(pro: false);

    // Firebase drops the session (it expired, say), a guest session starts,
    // and A signs in again.
    h.auth.session = null;
    await h.syncCurrentSession(pro: false);
    await h.repository.ensureAnonymous();
    await h.syncCurrentSession(pro: false);
    await h.signInWithCode(_accountA);
    await h.syncCurrentSession(pro: false);

    expect(await h.localRowsOf(_aRowIds), hasLength(_aRowIds.length));
  });

  test('Sign Out backs up a change A made seconds before', () async {
    final h = await _Harness.open();
    addTearDown(h.close);

    h.auth.session = const AuthSession(uid: _accountA);
    await _seedAnswers(h.db);
    await h.syncCurrentSession(pro: true);
    expect(h.paths(_accountA), isNotEmpty);

    // A finishes one more quiz. The engine waits a few seconds before it
    // uploads a change, and A signs out inside that wait.
    final stamp = DateTime.utc(2026, 11, 18, 1);
    await LocalSyncMutationRecorder.forDatabase(h.db).runRecorded<void>(
      collection: 'quiz_attempts',
      rowId: 'a-attempt-2',
      op: SyncLocalMutationOp.upsert,
      mutate: () => h.db.into(h.db.attemptsLocal).insert(
            AttemptsLocalCompanion.insert(
              id: 'a-attempt-2',
              examId: 'cse',
              startedAt: stamp,
              completedAt: Value(stamp),
              itemsJson: '[]',
            ),
          ),
    );
    await h.repository.signOut();

    expect(h.paths(_accountA), contains(endsWith('/a-attempt-2')));
    expect(await h.localRowsOf(['a-attempt-2']), isEmpty);
  });
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
      // As auth bootstrap builds them in the app.
      accountTransitionGateway: SyncAccountTransitionGateway(() => runtime),
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

class _Children implements ChildAccountsGateway {
  const _Children();

  @override
  Future<ChildList> listChildren() async =>
      (children: const <LinkedChild>[], maskedHolderEmail: null);

  @override
  Future<String> openChildSession(
    String childId, {
    String? guardianProofId,
  }) async =>
      _tokenFor(childId);
}
