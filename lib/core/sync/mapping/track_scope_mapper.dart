import 'dart:convert';

import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/sync_mapper.dart';

enum TrackScopeDocumentKind { metadata, scope }

class TrackScopeDocumentIdentity {
  const TrackScopeDocumentIdentity({
    required this.kind,
    required this.examId,
    this.topicId,
  });

  final TrackScopeDocumentKind kind;
  final String examId;
  final String? topicId;
}

class TrackScopeMappedDocument {
  const TrackScopeMappedDocument({
    required this.kind,
    required this.examId,
    this.topicId,
    this.name,
  });

  final TrackScopeDocumentKind kind;
  final String examId;
  final String? topicId;
  final String? name;
}

class TrackScopeDocumentId {
  const TrackScopeDocumentId._();

  static String metadata(String examId) => 'meta.${_encode(examId)}';

  static String scope(String examId, String topicId) =>
      'scope.${_encode(examId)}.${_encode(topicId)}';

  static TrackScopeDocumentIdentity parse(String documentId) {
    final parts = documentId.split('.');
    if (parts.length == 2 && parts.first == 'meta') {
      return TrackScopeDocumentIdentity(
        kind: TrackScopeDocumentKind.metadata,
        examId: _decode(parts[1]),
      );
    }
    if (parts.length == 3 && parts.first == 'scope') {
      return TrackScopeDocumentIdentity(
        kind: TrackScopeDocumentKind.scope,
        examId: _decode(parts[1]),
        topicId: _decode(parts[2]),
      );
    }
    throw FormatException('Invalid track_scope document id: $documentId');
  }

  static String _encode(String value) {
    if (value.isEmpty) {
      throw const FormatException('track_scope identifiers must not be empty');
    }
    return base64UrlEncode(utf8.encode(value)).replaceAll('=', '');
  }

  static String _decode(String value) {
    if (value.isEmpty) {
      throw const FormatException('track_scope identifiers must not be empty');
    }
    final padding = (4 - value.length % 4) % 4;
    final suffix = List.filled(padding, '=').join();
    return utf8.decode(base64Url.decode('$value$suffix'));
  }
}

class TrackScopeMapper implements SyncMapper {
  const TrackScopeMapper();

  static const schemaVersion = 1;

  @override
  String get name => 'track_scope';

  String metadataDocumentId(CustomTrackMetaLocalRow row) =>
      TrackScopeDocumentId.metadata(row.examId);

  String scopeDocumentId(TrackScopeExclusionRow row) =>
      TrackScopeDocumentId.scope(row.examId, row.topicId);

  Map<String, Object?> metadataToFirestore(
    CustomTrackMetaLocalRow row, {
    required DateTime updatedAt,
    required String originDeviceId,
  }) {
    return {
      'kind': 'custom_track',
      'examId': row.examId,
      'name': row.name,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }

  Map<String, Object?> scopeToFirestore(
    TrackScopeExclusionRow row, {
    required DateTime updatedAt,
    required String originDeviceId,
  }) {
    return {
      'kind': 'scope',
      'examId': row.examId,
      'topicId': row.topicId,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }

  TrackScopeMappedDocument fromFirestore(
    String documentId,
    Map<String, Object?> doc,
  ) {
    final identity = TrackScopeDocumentId.parse(documentId);
    final examId = doc['examId'];
    if (examId is! String || examId != identity.examId) {
      throw const FormatException('track_scope exam identity mismatch');
    }

    switch (identity.kind) {
      case TrackScopeDocumentKind.metadata:
        if (doc['kind'] != 'custom_track') {
          throw const FormatException('track_scope metadata kind mismatch');
        }
        final name = doc['name'];
        if (name is! String || name.isEmpty) {
          throw const FormatException('track_scope metadata name missing');
        }
        return TrackScopeMappedDocument(
          kind: TrackScopeDocumentKind.metadata,
          examId: examId,
          name: name,
        );
      case TrackScopeDocumentKind.scope:
        if (doc['kind'] != 'scope') {
          throw const FormatException('track_scope scope kind mismatch');
        }
        final topicId = doc['topicId'];
        if (topicId is! String || topicId != identity.topicId) {
          throw const FormatException('track_scope topic identity mismatch');
        }
        return TrackScopeMappedDocument(
          kind: TrackScopeDocumentKind.scope,
          examId: examId,
          topicId: topicId,
        );
    }
  }
}
