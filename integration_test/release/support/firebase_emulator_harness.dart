import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_core/firebase_core.dart';
import 'package:pantas/core/auth/firebase_auth_gateway.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/eligibility/sync_claim_gateway.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';
import 'package:pantas/core/sync/firestore/firebase_firestore_gateway.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';
import 'package:pantas/core/sync/runtime/production_sync_runtime_engine.dart';

class FirebaseEmulatorEndpoint {
  const FirebaseEmulatorEndpoint({required this.host, required this.port});

  factory FirebaseEmulatorEndpoint.parse(String? raw, {required String name}) {
    if (raw == null || raw.isEmpty) {
      throw StateError('Missing $name emulator endpoint');
    }
    final separator = raw.lastIndexOf(':');
    if (separator <= 0 || separator == raw.length - 1) {
      throw StateError('Invalid $name emulator endpoint: $raw');
    }
    final host = raw.substring(0, separator);
    final port = int.tryParse(raw.substring(separator + 1));
    if (host != '127.0.0.1' || port == null || port < 1 || port > 65535) {
      throw StateError('Unsafe $name emulator endpoint: $raw');
    }
    return FirebaseEmulatorEndpoint(host: host, port: port);
  }

  final String host;
  final int port;
}

class FirebaseEmulatorConfig {
  const FirebaseEmulatorConfig._({
    required this.projectId,
    required this.authEndpoint,
    required this.firestoreEndpoint,
  });

  factory FirebaseEmulatorConfig.parse({
    required String? projectId,
    required String? authHost,
    required String? firestoreHost,
  }) {
    if (projectId == null ||
        projectId.isEmpty ||
        !RegExp(r'^demo-[a-z0-9][a-z0-9-]*$').hasMatch(projectId)) {
      throw StateError('Unsafe Firebase emulator project id: $projectId');
    }
    final auth = FirebaseEmulatorEndpoint.parse(authHost, name: 'Auth');
    final firestore =
        FirebaseEmulatorEndpoint.parse(firestoreHost, name: 'Firestore');
    if (auth.port == firestore.port) {
      throw StateError('Auth and Firestore emulator ports must differ');
    }
    return FirebaseEmulatorConfig._(
      projectId: projectId,
      authEndpoint: auth,
      firestoreEndpoint: firestore,
    );
  }

  factory FirebaseEmulatorConfig.fromEnvironment() {
    return FirebaseEmulatorConfig.parse(
      projectId: const String.fromEnvironment(
        'RELEASE_E2E_FIREBASE_PROJECT_ID',
      ),
      authHost: const String.fromEnvironment(
        'RELEASE_E2E_AUTH_EMULATOR_HOST',
      ),
      firestoreHost: const String.fromEnvironment(
        'RELEASE_E2E_FIRESTORE_EMULATOR_HOST',
      ),
    );
  }

  String get androidHost => '10.0.2.2';

  Uri authAdminUri(String action) => Uri.parse(
        'http://$androidHost:${authEndpoint.port}'
        '/identitytoolkit.googleapis.com/v1/projects/$projectId/$action',
      );

  final String projectId;
  final FirebaseEmulatorEndpoint authEndpoint;
  final FirebaseEmulatorEndpoint firestoreEndpoint;
}

class NamedFirebaseEmulatorUser {
  const NamedFirebaseEmulatorUser({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class FirebaseEmulatorHarness {
  FirebaseEmulatorHarness._({
    required this.config,
    required this.app,
    required this.auth,
    required this.firestore,
    required this.authGateway,
    required this.claimGateway,
    required this.firestoreGateway,
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  static Future<FirebaseEmulatorHarness> start({
    FirebaseEmulatorConfig? config,
  }) async {
    final resolved = config ?? FirebaseEmulatorConfig.fromEnvironment();
    final app = await Firebase.initializeApp(
      name: 'release-e2e-${DateTime.now().microsecondsSinceEpoch}',
      options: FirebaseOptions(
        apiKey: 'release-e2e-api-key',
        appId: '1:1234567890:android:releasee2e',
        messagingSenderId: '1234567890',
        projectId: resolved.projectId,
      ),
    );
    final auth = firebase.FirebaseAuth.instanceFor(app: app);
    await auth.useAuthEmulator(
      resolved.androidHost,
      resolved.authEndpoint.port,
    );
    final firestore = FirebaseFirestore.instanceFor(app: app)
      ..settings = const Settings(persistenceEnabled: false)
      ..useFirestoreEmulator(
        resolved.androidHost,
        resolved.firestoreEndpoint.port,
      );
    final firestoreGateway = FirebaseFirestoreGateway(
      client: FirebaseFirestoreSdkClient(firestore: firestore),
    );
    return FirebaseEmulatorHarness._(
      config: resolved,
      app: app,
      auth: auth,
      firestore: firestore,
      authGateway: FirebaseAuthGateway(auth: auth),
      claimGateway: FirebaseSyncClaimGateway(auth: auth),
      firestoreGateway: firestoreGateway,
      httpClient: HttpClient(),
    );
  }

  final FirebaseEmulatorConfig config;
  final FirebaseApp app;
  final firebase.FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseAuthGateway authGateway;
  final FirebaseSyncClaimGateway claimGateway;
  final FirebaseFirestoreGateway firestoreGateway;
  final HttpClient _httpClient;

  Future<String> createNamedProUser(NamedFirebaseEmulatorUser user) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );
    final created = credential.user;
    if (created == null || created.isAnonymous) {
      throw StateError('Named emulator user was not created');
    }
    await _setProClaim(created.uid);
    final pro = await claimGateway.refreshProClaim(uid: created.uid);
    if (!pro) {
      throw StateError('Fresh emulator token did not contain Pro claim');
    }
    return created.uid;
  }

  Future<void> signInNamedProUser(NamedFirebaseEmulatorUser user) async {
    await auth.signOut();
    final credential = await auth.signInWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );
    final signedIn = credential.user;
    if (signedIn == null || signedIn.isAnonymous) {
      throw StateError('Named emulator user did not sign in');
    }
    final pro = await claimGateway.refreshProClaim(uid: signedIn.uid);
    if (!pro) {
      throw StateError('Fresh emulator token did not contain Pro claim');
    }
  }

  Future<void> provisionActiveGeneration({
    required String uid,
    required String generationId,
  }) async {
    final createdAt = DateTime.utc(2026);
    await _patchFirestoreDocument(
      'users/$uid/sync_generations/$generationId',
      <String, Object?>{
        'status': 'active',
        'schemaVersion': 1,
        'createdAt': createdAt,
        'createdByDeviceId': 'release-e2e-admin',
        'preferences': <String, Object?>{},
      },
    );
    await _patchFirestoreDocument(
      'users/$uid/sync_state/current',
      <String, Object?>{'activeGenerationId': generationId},
    );
  }

  Future<void> seedSyncDocument({
    required String uid,
    required String generationId,
    required String collection,
    required String rowId,
    required DateTime updatedAt,
    required String originDeviceId,
    required String mutationId,
    required bool deleted,
    Map<String, Object?> payload = const <String, Object?>{},
  }) {
    return _patchFirestoreDocument(
      syncDocumentPath(
        uid: uid,
        generationId: generationId,
        collection: collection,
        rowId: rowId,
      ),
      <String, Object?>{
        ...payload,
        'updatedAt': updatedAt.toUtc(),
        'originDeviceId': originDeviceId,
        'mutationId': mutationId,
        'schemaVersion': 1,
        'deleted': deleted,
      },
    );
  }

  String syncDocumentPath({
    required String uid,
    required String generationId,
    required String collection,
    required String rowId,
  }) =>
      'users/$uid/sync_generations/$generationId/$collection/$rowId';

  AppDatabase openIsolatedDatabase() => AppDatabase(NativeDatabase.memory());

  Future<ProductionSyncRuntimeEngine> startProductionRuntime({
    required AppDatabase db,
    required String uid,
    required String generationId,
    required String deviceId,
  }) async {
    final activeContext = SyncActiveContextStore(db);
    await activeContext.publishStable(uid: uid, generationId: generationId);
    final engine = ProductionSyncRuntimeEngine(
      db: db,
      gateway: firestoreGateway,
      activeContextStore: activeContext,
      deviceId: deviceId,
      localMutationDebounce: const Duration(minutes: 10),
    );
    await engine.start(uid: uid, generationId: generationId);
    return engine;
  }

  Future<SyncCausalBase?> acceptedBase({
    required AppDatabase db,
    required String collection,
    required String rowId,
  }) {
    return SyncRowMetaRepository(db).readAcceptedBase(
      collection: collection,
      rowId: rowId,
    );
  }

  Future<void> waitUntil(
    Future<bool> Function() condition, {
    Duration timeout = const Duration(seconds: 20),
    Duration interval = const Duration(milliseconds: 100),
    String description = 'condition',
  }) async {
    final deadline = DateTime.now().add(timeout);
    Object? lastError;
    while (DateTime.now().isBefore(deadline)) {
      try {
        if (await condition()) return;
      } on Object catch (error) {
        lastError = error;
      }
      await Future<void>.delayed(interval);
    }
    throw StateError(
      'Timed out waiting for $description'
      '${lastError == null ? '' : ': $lastError'}',
    );
  }

  Future<void> close() async {
    _httpClient.close(force: true);
    await auth.signOut();
    await app.delete();
  }

  Future<void> _setProClaim(String uid) {
    final uri = config.authAdminUri('accounts:update');
    return _jsonRequest(
      uri,
      method: 'POST',
      body: <String, Object?>{
        'localId': uid,
        'customAttributes':
            jsonEncode(firebaseEmulatorProClaims(DateTime.now())),
      },
    );
  }

  Future<void> _patchFirestoreDocument(
    String path,
    Map<String, Object?> data,
  ) {
    final uri = Uri.parse(
      'http://${config.androidHost}:${config.firestoreEndpoint.port}'
      '/v1/projects/${config.projectId}/databases/(default)/documents/$path',
    );
    return _jsonRequest(
      uri,
      method: 'PATCH',
      body: <String, Object?>{
        'fields': <String, Object?>{
          for (final entry in data.entries)
            entry.key: _encodeFirestoreValue(entry.value),
        },
      },
    );
  }

  Future<void> _jsonRequest(
    Uri uri, {
    required String method,
    required Map<String, Object?> body,
  }) async {
    final request = await _httpClient.openUrl(method, uri);
    request.headers
      ..set(HttpHeaders.authorizationHeader, 'Bearer owner')
      ..set(HttpHeaders.contentTypeHeader, 'application/json');
    request.write(jsonEncode(body));
    final response = await request.close();
    final responseBody = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Emulator admin request failed (${response.statusCode}): $responseBody',
      );
    }
  }

  Object _encodeFirestoreValue(Object? value) {
    if (value == null) return <String, Object?>{'nullValue': null};
    if (value is String) return <String, Object?>{'stringValue': value};
    if (value is bool) return <String, Object?>{'booleanValue': value};
    if (value is int) {
      return <String, Object?>{'integerValue': value.toString()};
    }
    if (value is double) return <String, Object?>{'doubleValue': value};
    if (value is DateTime) {
      return <String, Object?>{
        'timestampValue': value.toUtc().toIso8601String(),
      };
    }
    if (value is Map) {
      return <String, Object?>{
        'mapValue': <String, Object?>{
          'fields': <String, Object?>{
            for (final entry in value.entries)
              entry.key.toString(): _encodeFirestoreValue(entry.value),
          },
        },
      };
    }
    if (value is Iterable) {
      return <String, Object?>{
        'arrayValue': <String, Object?>{
          'values': <Object>[
            for (final item in value) _encodeFirestoreValue(item),
          ],
        },
      };
    }
    throw ArgumentError.value(value, 'value', 'unsupported Firestore value');
  }
}

Map<String, Object?> firebaseEmulatorProClaims(DateTime now) =>
    <String, Object?>{
      'pro': true,
      'proUntil': now.add(const Duration(hours: 1)).millisecondsSinceEpoch,
    };
