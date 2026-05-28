import 'dart:typed_data';

import 'package:cse_cet_reviewer/features/wrapped/domain/wrapped_share_host.dart';

class PublishedCardRecord {
  PublishedCardRecord({
    required this.uid,
    required this.shareId,
    required this.archetypeId,
    required this.byteLength,
  });

  final String uid;
  final String shareId;
  final String archetypeId;
  final int byteLength;
}

/// In-memory [WrappedShareHost] for tests; records publish/revoke calls.
class FakeWrappedShareHost implements WrappedShareHost {
  final List<PublishedCardRecord> published = [];
  final List<String> revoked = [];

  @override
  Future<void> publish({
    required String uid,
    required String shareId,
    required String archetypeId,
    required Uint8List pngBytes,
  }) async {
    published.add(
      PublishedCardRecord(
        uid: uid,
        shareId: shareId,
        archetypeId: archetypeId,
        byteLength: pngBytes.length,
      ),
    );
  }

  @override
  Future<void> revoke({required String uid, required String shareId}) async {
    revoked.add(shareId);
  }
}
