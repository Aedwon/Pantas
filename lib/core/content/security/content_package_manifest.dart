import 'dart:convert';

final class ContentPackageManifest {
  ContentPackageManifest({
    required this.formatVersion,
    required this.releaseSequence,
    required this.applicationId,
    required this.releaseChannel,
    required this.payloadPath,
    required this.sourceContentSha256,
    required this.payloadSha256,
    required this.contentSeedVersion,
    required this.contentSchemaVersion,
    required this.readerSchemaMin,
    required this.readerSchemaMax,
    required this.cipherProfile,
    required this.bootstrapKeyId,
    required this.signingKeyId,
  });

  factory ContentPackageManifest.production({
    required int releaseSequence,
    required String sourceContentSha256,
    required String payloadSha256,
  }) {
    if (sourceContentSha256.length < 16) {
      throw const FormatException('sourceContentSha256 is too short');
    }
    if (releaseSequence <= 0) {
      throw const FormatException('releaseSequence must be positive');
    }
    return ContentPackageManifest(
      formatVersion: formatVersionV2,
      releaseSequence: releaseSequence,
      applicationId: productionApplicationId,
      releaseChannel: productionReleaseChannel,
      payloadPath: productionPayloadPath,
      sourceContentSha256: sourceContentSha256,
      payloadSha256: payloadSha256,
      contentSeedVersion: sourceContentSha256.substring(0, 16),
      contentSchemaVersion: contentSchemaV1,
      readerSchemaMin: contentSchemaV1,
      readerSchemaMax: contentSchemaV1,
      cipherProfile: cipherProfileV1,
      bootstrapKeyId: bootstrapKeyIdV1,
      signingKeyId: signingKeyIdV1,
    );
  }

  factory ContentPackageManifest.parse(List<int> bytes) {
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } on Object catch (error) {
      throw FormatException('invalid content package manifest: $error');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('content package manifest must be an object');
    }
    final manifestJson = decoded;

    T field<T>(String name) {
      final value = manifestJson[name];
      if (value is! T) {
        throw FormatException('invalid manifest field: $name');
      }
      return value;
    }

    return ContentPackageManifest(
      formatVersion: field<int>('formatVersion'),
      releaseSequence: field<int>('releaseSequence'),
      applicationId: field<String>('applicationId'),
      releaseChannel: field<String>('releaseChannel'),
      payloadPath: field<String>('payloadPath'),
      sourceContentSha256: field<String>('sourceContentSha256'),
      payloadSha256: field<String>('payloadSha256'),
      contentSeedVersion: field<String>('contentSeedVersion'),
      contentSchemaVersion: field<int>('contentSchemaVersion'),
      readerSchemaMin: field<int>('readerSchemaMin'),
      readerSchemaMax: field<int>('readerSchemaMax'),
      cipherProfile: field<String>('cipherProfile'),
      bootstrapKeyId: field<String>('bootstrapKeyId'),
      signingKeyId: field<String>('signingKeyId'),
    );
  }

  static const formatVersionV1 = 1;
  static const formatVersionV2 = 2;
  static const productionApplicationId = 'com.aedwon.pantas';
  static const productionReleaseChannel = 'prod';
  static const productionPayloadPath = 'assets/seed/content.db';
  static const contentSchemaV1 = 8;
  static const cipherProfileV1 = 'pantas-sqlite3mc-content-v1';
  static const bootstrapKeyIdV1 = 'content-bootstrap-v1';
  static const signingKeyIdV1 = 'content-signing-v1';

  final int formatVersion;
  final int releaseSequence;
  final String applicationId;
  final String releaseChannel;
  final String payloadPath;
  final String sourceContentSha256;
  final String payloadSha256;
  final String contentSeedVersion;
  final int contentSchemaVersion;
  final int readerSchemaMin;
  final int readerSchemaMax;
  final String cipherProfile;
  final String bootstrapKeyId;
  final String signingKeyId;

  Map<String, Object> toJson() => <String, Object>{
        'formatVersion': formatVersion,
        'applicationId': applicationId,
        'releaseChannel': releaseChannel,
        'releaseSequence': releaseSequence,
        'payloadPath': payloadPath,
        'sourceContentSha256': sourceContentSha256,
        'payloadSha256': payloadSha256,
        'contentSeedVersion': contentSeedVersion,
        'contentSchemaVersion': contentSchemaVersion,
        'readerSchemaMin': readerSchemaMin,
        'readerSchemaMax': readerSchemaMax,
        'cipherProfile': cipherProfile,
        'bootstrapKeyId': bootstrapKeyId,
        'signingKeyId': signingKeyId,
      };

  List<int> encode() => utf8.encode('${jsonEncode(toJson())}\n');

  void validateProduction() {
    if (formatVersion != formatVersionV2 ||
        releaseSequence <= 0 ||
        applicationId != productionApplicationId ||
        releaseChannel != productionReleaseChannel ||
        payloadPath != productionPayloadPath ||
        contentSchemaVersion != contentSchemaV1 ||
        readerSchemaMin != contentSchemaV1 ||
        readerSchemaMax != contentSchemaV1 ||
        cipherProfile != cipherProfileV1 ||
        bootstrapKeyId.isEmpty ||
        signingKeyId.isEmpty) {
      throw const FormatException('incompatible content package manifest');
    }

    final digestPattern = RegExp(r'^[0-9a-f]{64}$');
    if (!digestPattern.hasMatch(sourceContentSha256) ||
        !digestPattern.hasMatch(payloadSha256) ||
        contentSeedVersion.length != 16 ||
        contentSeedVersion != sourceContentSha256.substring(0, 16)) {
      throw const FormatException('invalid content package identity');
    }
  }
}
