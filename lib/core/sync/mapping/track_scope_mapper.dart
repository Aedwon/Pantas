import 'dart:convert';

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
