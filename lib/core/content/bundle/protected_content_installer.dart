import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pantas/core/content/content_database_opener.dart';
import 'package:pantas/core/content/security/content_cipher_profile.dart';
import 'package:pantas/core/content/security/content_key_store.dart';
import 'package:pantas/core/content/security/content_package_verifier.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const _contentSchemaVersion = 8;

enum ContentInstallDecision {
  freshInstall,
  idempotent,
  upgrade,
}

enum ProtectedContentInstallFault {
  beforeIntent,
  afterIntentBeforeReplacement,
  afterReplacementBeforeAcceptedState,
  afterAcceptedStateBeforeCleanup,
}

final class ProtectedContentInstallResult {
  const ProtectedContentInstallResult({
    required this.decision,
    required this.activeFile,
    required this.identity,
  });

  final ContentInstallDecision decision;
  final File activeFile;
  final ContentPackageIdentity identity;
}

Future<ProtectedContentInstallResult> ensureProtectedContentInstalled({
  required ContentPackageVerifier verifier,
  ContentKeyStore? keyStore,
  Directory? directory,
  ProtectedContentInstallFault? failAt,
}) async {
  final verified = await verifier.verifyBundled();
  final identity = ContentPackageIdentity.fromVerified(verified);
  final candidateState = _AcceptedPackageState.fromVerified(verified);
  final store = keyStore ?? ContentKeyStore();
  final root = directory ?? await getApplicationSupportDirectory();
  await root.create(recursive: true);

  final active = File(p.join(root.path, contentDbFileName));
  final pending = File(p.join(root.path, '$contentDbFileName.pending'));
  final previous = File(p.join(root.path, '$contentDbFileName.previous'));
  final stateFile = File(p.join(root.path, 'content.install-state.json'));
  final stateTemporary = File('${stateFile.path}.tmp');

  var state = _readInstallState(stateFile);
  ContentPackageChronology.classify(
    accepted: state.accepted?.identity,
    candidate: identity,
  );

  if (state.promotion != null) {
    state = await _recoverPromotion(
      state: state,
      candidate: candidateState,
      store: store,
      active: active,
      pending: pending,
      previous: previous,
      stateFile: stateFile,
      stateTemporary: stateTemporary,
      bundledPayload: verified.payloadBytes,
      bootstrapKey: verified.bootstrapKeyBytes,
    );
  }

  final accepted = state.accepted;
  final chronology = ContentPackageChronology.classify(
    accepted: accepted?.identity,
    candidate: identity,
  );

  var missingKeyRecovery = false;
  if (chronology == ContentPackageChronologyDecision.idempotent) {
    if (!active.existsSync()) {
      throw StateError('accepted protected content has no active database');
    }
    final installKey = await store.read();
    if (installKey != null) {
      _validateProtectedCorpus(active, installKey);
      await _cleanupIfExists(pending);
      await _cleanupIfExists(previous);
      await _cleanupIfExists(stateTemporary);
      return ProtectedContentInstallResult(
        decision: ContentInstallDecision.idempotent,
        activeFile: active,
        identity: identity,
      );
    }
    missingKeyRecovery = true;
  }
  if (active.existsSync() && accepted == null) {
    throw StateError(
      'protected content already exists without acceptance state',
    );
  }

  // A clean accepted state makes these files non-authoritative residue. They
  // are safe to remove only after the accepted active database has already
  // been established by prior validation/recovery.
  await _cleanupIfExists(pending);
  await _cleanupIfExists(previous);
  await _cleanupIfExists(stateTemporary);

  var intentPersisted = false;
  try {
    // The bundled payload is already encrypted under the authenticated
    // bootstrap key. It is written directly to pending; no plaintext staging
    // file is ever created.
    await pending.writeAsBytes(verified.payloadBytes, flush: true);

    _validateProtectedCorpus(pending, verified.bootstrapKeyBytes);
    final installKey = missingKeyRecovery
        ? store.generateCandidate()
        : await store.readOrCreate();

    final bootstrapDb = ContentCipherProfile.open(
      pending,
      verified.bootstrapKeyBytes,
    );
    try {
      ContentCipherProfile.rekey(bootstrapDb, installKey);
    } finally {
      bootstrapDb.close();
    }

    _validateProtectedCorpus(pending, installKey);

    if (failAt == ProtectedContentInstallFault.beforeIntent) {
      throw const _InjectedContentInstallFault('before promotion intent');
    }

    final promotion = _PromotionIntent(
      candidate: candidateState,
      previousAccepted: accepted,
    );
    await _writeInstallState(
      stateFile,
      _InstallState(
        accepted: accepted,
        previousAccepted: accepted,
        promotion: promotion,
      ),
    );
    intentPersisted = true;

    if (missingKeyRecovery) {
      await store.persist(installKey);
    }

    if (failAt == ProtectedContentInstallFault.afterIntentBeforeReplacement) {
      throw const _InjectedContentInstallFault(
        'after promotion intent before replacement',
      );
    }

    if (active.existsSync()) {
      await active.rename(previous.path);
    }
    await pending.rename(active.path);
    _validateProtectedCorpus(active, installKey);

    if (failAt ==
        ProtectedContentInstallFault.afterReplacementBeforeAcceptedState) {
      throw const _InjectedContentInstallFault(
        'after replacement before accepted state',
      );
    }

    await _writeInstallState(
      stateFile,
      _InstallState(
        accepted: candidateState,
        previousAccepted: accepted,
        promotion: promotion,
      ),
    );

    if (failAt ==
        ProtectedContentInstallFault.afterAcceptedStateBeforeCleanup) {
      throw const _InjectedContentInstallFault(
        'after accepted state before cleanup',
      );
    }

    await _cleanupIfExists(previous);
    await _cleanupIfExists(pending);
    await _cleanupIfExists(stateTemporary);
    await _writeInstallState(
      stateFile,
      _InstallState.clean(candidateState),
    );

    return ProtectedContentInstallResult(
      decision: switch (chronology) {
        ContentPackageChronologyDecision.freshInstall =>
          ContentInstallDecision.freshInstall,
        ContentPackageChronologyDecision.idempotent =>
          ContentInstallDecision.idempotent,
        ContentPackageChronologyDecision.upgrade =>
          ContentInstallDecision.upgrade,
      },
      activeFile: active,
      identity: identity,
    );
  } catch (_) {
    if (!intentPersisted) {
      await _cleanupIfExists(pending);
      await _cleanupIfExists(stateTemporary);
    }
    rethrow;
  }
}

Future<_InstallState> _recoverPromotion({
  required _InstallState state,
  required _AcceptedPackageState candidate,
  required ContentKeyStore store,
  required File active,
  required File pending,
  required File previous,
  required File stateFile,
  required File stateTemporary,
  required Uint8List bundledPayload,
  required Uint8List bootstrapKey,
}) async {
  final promotion = state.promotion;
  if (promotion == null) {
    return state;
  }
  if (!promotion.candidate.hasExactState(candidate)) {
    throw const FormatException(
      'protected content promotion intent does not match verified package',
    );
  }
  final previousAccepted = promotion.previousAccepted;
  final sameIdentityPromotion = previousAccepted != null &&
      previousAccepted.hasExactState(candidate) &&
      (state.accepted?.hasExactState(candidate) ?? false) &&
      (state.previousAccepted?.hasExactState(candidate) ?? false);

  if (sameIdentityPromotion) {
    final installKey = await store.read();
    var activeIsAuthoritative = false;
    if (installKey != null && active.existsSync()) {
      try {
        _validateProtectedCorpus(active, installKey);
        activeIsAuthoritative = true;
      } on Object {
        // A persisted recovery key can be newer than the accepted active copy.
      }
    }

    if (activeIsAuthoritative) {
      final clean = _InstallState.clean(candidate);
      await _writeInstallState(stateFile, clean);
      await _cleanupIfExists(previous);
      await _cleanupIfExists(pending);
      await _cleanupIfExists(stateTemporary);
      return clean;
    }

    if (!active.existsSync() && !previous.existsSync()) {
      throw const FormatException(
        'same-identity promotion lost both protected database copies',
      );
    }

    await pending.writeAsBytes(bundledPayload, flush: true);
    _validateProtectedCorpus(pending, bootstrapKey);
    final recoveryKey = installKey ?? store.generateCandidate();
    final bootstrapDb = ContentCipherProfile.open(pending, bootstrapKey);
    try {
      ContentCipherProfile.rekey(bootstrapDb, recoveryKey);
    } finally {
      bootstrapDb.close();
    }
    _validateProtectedCorpus(pending, recoveryKey);

    if (installKey == null) {
      await store.persist(recoveryKey);
    }

    if (active.existsSync()) {
      if (previous.existsSync()) {
        await _cleanupIfExists(active);
      } else {
        await active.rename(previous.path);
      }
    }

    await pending.rename(active.path);
    _validateProtectedCorpus(active, recoveryKey);
    final clean = _InstallState.clean(candidate);
    await _writeInstallState(stateFile, clean);
    await _cleanupIfExists(previous);
    await _cleanupIfExists(pending);
    await _cleanupIfExists(stateTemporary);
    return clean;
  }

  final installKey = await store.read();
  if (installKey == null) {
    throw StateError('protected content key is missing during promotion');
  }

  if (state.accepted?.hasExactState(candidate) ?? false) {
    if (!active.existsSync()) {
      throw const FormatException(
        'finalized protected content promotion has no active database',
      );
    }
    _validateProtectedCorpus(active, installKey);
    await _cleanupIfExists(previous);
    await _cleanupIfExists(pending);
    await _cleanupIfExists(stateTemporary);
    final clean = _InstallState.clean(candidate);
    await _writeInstallState(stateFile, clean);
    return clean;
  }

  if (previousAccepted == null) {
    if (state.accepted != null || state.previousAccepted != null) {
      throw const FormatException(
        'first-install promotion contains previous accepted state',
      );
    }

    if (previous.existsSync()) {
      throw const FormatException(
        'first-install promotion unexpectedly has previous database',
      );
    }

    if (active.existsSync()) {
      try {
        _validateProtectedCorpus(active, installKey);
      } on Object {
        await _cleanupIfExists(active);
        await _cleanupIfExists(pending);
        await _cleanupIfExists(stateTemporary);
        await _cleanupIfExists(stateFile);
        return const _InstallState.empty();
      }

      final finalized = _InstallState(
        accepted: candidate,
        previousAccepted: null,
        promotion: promotion,
      );
      await _writeInstallState(stateFile, finalized);
      await _cleanupIfExists(pending);
      await _cleanupIfExists(stateTemporary);
      final clean = _InstallState.clean(candidate);
      await _writeInstallState(stateFile, clean);
      return clean;
    }

    await _cleanupIfExists(pending);
    await _cleanupIfExists(stateTemporary);
    await _cleanupIfExists(stateFile);
    return const _InstallState.empty();
  }

  if (!(state.accepted?.hasExactState(previousAccepted) ?? false) ||
      !(state.previousAccepted?.hasExactState(previousAccepted) ?? false)) {
    throw const FormatException(
      'protected content promotion previous identity is inconsistent',
    );
  }

  if (previous.existsSync() && active.existsSync()) {
    try {
      _validateProtectedCorpus(active, installKey);
    } on Object {
      await _cleanupIfExists(active);
      await previous.rename(active.path);
      _validateProtectedCorpus(active, installKey);
      await _cleanupIfExists(pending);
      await _cleanupIfExists(stateTemporary);
      final restored = _InstallState.clean(previousAccepted);
      await _writeInstallState(stateFile, restored);
      return restored;
    }

    final finalized = _InstallState(
      accepted: candidate,
      previousAccepted: previousAccepted,
      promotion: promotion,
    );
    await _writeInstallState(stateFile, finalized);
    await _cleanupIfExists(previous);
    await _cleanupIfExists(pending);
    await _cleanupIfExists(stateTemporary);
    final clean = _InstallState.clean(candidate);
    await _writeInstallState(stateFile, clean);
    return clean;
  }

  if (previous.existsSync() && !active.existsSync()) {
    await previous.rename(active.path);
    _validateProtectedCorpus(active, installKey);
    await _cleanupIfExists(pending);
    await _cleanupIfExists(stateTemporary);
    final restored = _InstallState.clean(previousAccepted);
    await _writeInstallState(stateFile, restored);
    return restored;
  }

  if (!previous.existsSync() && active.existsSync()) {
    // Intent was durable but replacement had not started. The accepted active
    // database is still authoritative, so discard the candidate and retry from
    // the authenticated bundle.
    _validateProtectedCorpus(active, installKey);
    await _cleanupIfExists(pending);
    await _cleanupIfExists(stateTemporary);
    final restored = _InstallState.clean(previousAccepted);
    await _writeInstallState(stateFile, restored);
    return restored;
  }

  throw const FormatException(
    'protected content promotion lost both active and previous databases',
  );
}

final class _InstallState {
  const _InstallState({
    required this.accepted,
    required this.previousAccepted,
    required this.promotion,
  });

  const _InstallState.empty()
      : accepted = null,
        previousAccepted = null,
        promotion = null;

  factory _InstallState.clean(_AcceptedPackageState accepted) {
    return _InstallState(
      accepted: accepted,
      previousAccepted: null,
      promotion: null,
    );
  }

  final _AcceptedPackageState? accepted;
  final _AcceptedPackageState? previousAccepted;
  final _PromotionIntent? promotion;

  Map<String, Object?> toJson() => <String, Object?>{
        'accepted': accepted?.toJson(),
        'previousAccepted': previousAccepted?.toJson(),
        'promotion': promotion?.toJson(),
      };
}

final class _PromotionIntent {
  const _PromotionIntent({
    required this.candidate,
    required this.previousAccepted,
  });

  factory _PromotionIntent.fromJson(Map<String, dynamic> json) {
    final candidate = _parseAcceptedState(
      json['candidate'],
      fieldName: 'promotion.candidate',
      requiredValue: true,
    );
    final previous = _parseAcceptedState(
      json['previousAccepted'],
      fieldName: 'promotion.previousAccepted',
    );
    return _PromotionIntent(
      candidate: candidate!,
      previousAccepted: previous,
    );
  }

  final _AcceptedPackageState candidate;
  final _AcceptedPackageState? previousAccepted;

  Map<String, Object?> toJson() => <String, Object?>{
        'candidate': candidate.toJson(),
        'previousAccepted': previousAccepted?.toJson(),
      };
}

final class _AcceptedPackageState {
  const _AcceptedPackageState({
    required this.formatVersion,
    required this.releaseSequence,
    required this.sourceContentSha256,
    required this.contentSeedVersion,
    required this.payloadSha256,
    required this.manifestSha256,
    required this.signatureSha256,
    required this.signingKeyId,
    required this.bootstrapKeyId,
    required this.cipherProfile,
    required this.contentSchemaVersion,
    required this.readerSchemaMin,
    required this.readerSchemaMax,
  });

  factory _AcceptedPackageState.fromVerified(VerifiedContentPackage package) {
    final manifest = package.manifest;
    return _AcceptedPackageState(
      formatVersion: manifest.formatVersion,
      releaseSequence: manifest.releaseSequence,
      sourceContentSha256: manifest.sourceContentSha256,
      contentSeedVersion: manifest.contentSeedVersion,
      payloadSha256: manifest.payloadSha256,
      manifestSha256: package.manifestSha256,
      signatureSha256: package.signatureSha256,
      signingKeyId: manifest.signingKeyId,
      bootstrapKeyId: manifest.bootstrapKeyId,
      cipherProfile: manifest.cipherProfile,
      contentSchemaVersion: manifest.contentSchemaVersion,
      readerSchemaMin: manifest.readerSchemaMin,
      readerSchemaMax: manifest.readerSchemaMax,
    );
  }

  factory _AcceptedPackageState.fromJson(Map<String, dynamic> json) {
    try {
      return _AcceptedPackageState(
        formatVersion: json['formatVersion'] as int,
        releaseSequence: json['releaseSequence'] as int,
        sourceContentSha256: json['sourceContentSha256'] as String,
        contentSeedVersion: json['contentSeedVersion'] as String,
        payloadSha256: json['payloadSha256'] as String,
        manifestSha256: json['manifestSha256'] as String,
        signatureSha256: json['signatureSha256'] as String,
        signingKeyId: json['signingKeyId'] as String,
        bootstrapKeyId: json['bootstrapKeyId'] as String,
        cipherProfile: json['cipherProfile'] as String,
        contentSchemaVersion: json['contentSchemaVersion'] as int,
        readerSchemaMin: json['readerSchemaMin'] as int,
        readerSchemaMax: json['readerSchemaMax'] as int,
      );
    } on Object {
      throw const FormatException('invalid protected package state fields');
    }
  }

  final int formatVersion;
  final int releaseSequence;
  final String sourceContentSha256;
  final String contentSeedVersion;
  final String payloadSha256;
  final String manifestSha256;
  final String signatureSha256;
  final String signingKeyId;
  final String bootstrapKeyId;
  final String cipherProfile;
  final int contentSchemaVersion;
  final int readerSchemaMin;
  final int readerSchemaMax;

  ContentPackageIdentity get identity => ContentPackageIdentity(
        formatVersion: formatVersion,
        releaseSequence: releaseSequence,
        manifestSha256: manifestSha256,
        signatureSha256: signatureSha256,
        payloadSha256: payloadSha256,
      );

  bool hasExactState(_AcceptedPackageState other) =>
      formatVersion == other.formatVersion &&
      releaseSequence == other.releaseSequence &&
      sourceContentSha256 == other.sourceContentSha256 &&
      contentSeedVersion == other.contentSeedVersion &&
      payloadSha256 == other.payloadSha256 &&
      manifestSha256 == other.manifestSha256 &&
      signatureSha256 == other.signatureSha256 &&
      signingKeyId == other.signingKeyId &&
      bootstrapKeyId == other.bootstrapKeyId &&
      cipherProfile == other.cipherProfile &&
      contentSchemaVersion == other.contentSchemaVersion &&
      readerSchemaMin == other.readerSchemaMin &&
      readerSchemaMax == other.readerSchemaMax;

  Map<String, Object> toJson() => <String, Object>{
        'formatVersion': formatVersion,
        'releaseSequence': releaseSequence,
        'sourceContentSha256': sourceContentSha256,
        'contentSeedVersion': contentSeedVersion,
        'payloadSha256': payloadSha256,
        'manifestSha256': manifestSha256,
        'signatureSha256': signatureSha256,
        'signingKeyId': signingKeyId,
        'bootstrapKeyId': bootstrapKeyId,
        'cipherProfile': cipherProfile,
        'contentSchemaVersion': contentSchemaVersion,
        'readerSchemaMin': readerSchemaMin,
        'readerSchemaMax': readerSchemaMax,
      };
}

_InstallState _readInstallState(File file) {
  if (!file.existsSync()) {
    return const _InstallState.empty();
  }

  final Object? decoded;
  try {
    decoded = jsonDecode(file.readAsStringSync());
  } on Object {
    throw const FormatException('invalid protected content install state');
  }
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('invalid protected content install state');
  }

  final accepted = _parseAcceptedState(
    decoded['accepted'],
    fieldName: 'accepted',
  );
  final previousAccepted = _parseAcceptedState(
    decoded['previousAccepted'],
    fieldName: 'previousAccepted',
  );

  final promotionValue = decoded['promotion'];
  _PromotionIntent? promotion;
  if (promotionValue != null) {
    if (promotionValue is! Map<String, dynamic>) {
      throw const FormatException('invalid protected content promotion state');
    }
    promotion = _PromotionIntent.fromJson(promotionValue);
  }

  if (promotion == null) {
    if (previousAccepted != null) {
      throw const FormatException(
        'previous accepted package exists without promotion intent',
      );
    }
    return _InstallState(
      accepted: accepted,
      previousAccepted: null,
      promotion: null,
    );
  }

  final intentPrevious = promotion.previousAccepted;
  if ((previousAccepted == null) != (intentPrevious == null) ||
      (previousAccepted != null &&
          !previousAccepted.hasExactState(intentPrevious!))) {
    throw const FormatException(
      'promotion previous accepted package is inconsistent',
    );
  }

  if (accepted != null &&
      !accepted.hasExactState(promotion.candidate) &&
      (intentPrevious == null || !accepted.hasExactState(intentPrevious))) {
    throw const FormatException(
      'accepted package is inconsistent with promotion intent',
    );
  }

  return _InstallState(
    accepted: accepted,
    previousAccepted: previousAccepted,
    promotion: promotion,
  );
}

_AcceptedPackageState? _parseAcceptedState(
  Object? value, {
  required String fieldName,
  bool requiredValue = false,
}) {
  if (value == null) {
    if (requiredValue) {
      throw FormatException('$fieldName is required');
    }
    return null;
  }
  if (value is! Map<String, dynamic>) {
    throw FormatException('invalid $fieldName protected package state');
  }
  return _AcceptedPackageState.fromJson(value);
}

Future<void> _writeInstallState(
  File file,
  _InstallState state,
) async {
  final temporary = File('${file.path}.tmp');
  await temporary.writeAsString(
    jsonEncode(state.toJson()),
    flush: true,
  );
  await temporary.rename(file.path);
}

Future<void> _cleanupIfExists(File file) async {
  if (file.existsSync()) {
    await file.delete();
  }
}

final class _InjectedContentInstallFault implements Exception {
  const _InjectedContentInstallFault(this.message);

  final String message;

  @override
  String toString() => '_InjectedContentInstallFault: $message';
}

void _validateProtectedCorpus(File file, Uint8List key) {
  final db = ContentCipherProfile.open(file, key);
  try {
    final userVersion = db.select('PRAGMA user_version').single.values.single;
    if (userVersion != _contentSchemaVersion) {
      throw FormatException(
        'protected content schema mismatch: expected '
        '$_contentSchemaVersion, got $userVersion',
      );
    }
    const requiredTables = <String>{
      'content_exams',
      'content_subjects',
      'content_topics',
      'content_questions',
      'content_choices',
      'content_question_exams',
      'content_lessons',
      'content_passages',
      'content_mock_blueprints',
      'content_mock_exams',
      'content_diagnostic_sets',
      'content_meta',
    };
    const requiredNonEmptyTables = <String>{
      'content_exams',
      'content_subjects',
      'content_topics',
      'content_questions',
      'content_lessons',
      'content_mock_blueprints',
      'content_passages',
    };
    final rows = db.select(
      "SELECT name FROM sqlite_schema WHERE type = 'table'",
    );
    final names = rows.map((row) => row['name']).whereType<String>().toSet();
    if (!names.containsAll(requiredTables)) {
      throw const FormatException(
        'protected content corpus schema is incomplete',
      );
    }
    for (final table in requiredNonEmptyTables) {
      final count = db.select('SELECT count(*) AS c FROM $table').single['c'];
      if (count is! int || count <= 0) {
        throw FormatException(
          'protected content corpus table is empty: $table',
        );
      }
    }
  } finally {
    db.close();
  }
}
