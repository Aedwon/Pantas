import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/wrapped/domain/wrapped_payload.dart';
import 'package:drift/drift.dart';

class UserMetricsArtifactEntry {
  const UserMetricsArtifactEntry({
    required this.userId,
    required this.examId,
    required this.artifactId,
    required this.payload,
    required this.firedAt,
    this.sharedAt,
    this.sharePlatform,
  });

  final String userId;
  final String examId;
  final String artifactId;
  final WrappedPayload payload;
  final DateTime firedAt;
  final DateTime? sharedAt;
  final String? sharePlatform;
}

class UserMetricsArtifactRepository {
  const UserMetricsArtifactRepository(this._db);

  final AppDatabase _db;

  Future<void> upsert(UserMetricsArtifactEntry entry) {
    return _db.into(_db.userMetricsArtifactsLocal).insertOnConflictUpdate(
          UserMetricsArtifactsLocalCompanion.insert(
            userId: entry.userId,
            examId: entry.examId,
            artifactId: entry.artifactId,
            shareId: entry.payload.shareId,
            payloadJson: _toJson(entry.payload),
            firedAt: entry.firedAt,
            sharedAt: Value(entry.sharedAt),
            sharePlatform: Value(entry.sharePlatform),
          ),
        );
  }

  Future<UserMetricsArtifactEntry?> byArtifactId({
    required String userId,
    required String examId,
    required String artifactId,
  }) async {
    final row = await (_db.select(_db.userMetricsArtifactsLocal)
          ..where(
            (table) =>
                table.userId.equals(userId) &
                table.examId.equals(examId) &
                table.artifactId.equals(artifactId),
          ))
        .getSingleOrNull();
    if (row == null) return null;
    return UserMetricsArtifactEntry(
      userId: row.userId,
      examId: row.examId,
      artifactId: row.artifactId,
      payload: _fromJson(row.payloadJson),
      firedAt: row.firedAt,
      sharedAt: row.sharedAt,
      sharePlatform: row.sharePlatform,
    );
  }

  Future<UserMetricsArtifactEntry?> latestByArtifactId(
    String artifactId,
  ) async {
    final row = await (_db.select(_db.userMetricsArtifactsLocal)
          ..where((table) => table.artifactId.equals(artifactId))
          ..orderBy([
            (table) => OrderingTerm(
                  expression: table.firedAt,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return _entryFromRow(row);
  }

  Future<void> markShared({
    required String userId,
    required String examId,
    required String artifactId,
    required DateTime sharedAt,
    required String sharePlatform,
  }) async {
    await (_db.update(_db.userMetricsArtifactsLocal)
          ..where(
            (table) =>
                table.userId.equals(userId) &
                table.examId.equals(examId) &
                table.artifactId.equals(artifactId),
          ))
        .write(
      UserMetricsArtifactsLocalCompanion(
        sharedAt: Value(sharedAt),
        sharePlatform: Value(sharePlatform),
      ),
    );
  }

  UserMetricsArtifactEntry _entryFromRow(UserMetricsArtifactLocalRow row) {
    return UserMetricsArtifactEntry(
      userId: row.userId,
      examId: row.examId,
      artifactId: row.artifactId,
      payload: _fromJson(row.payloadJson),
      firedAt: row.firedAt,
      sharedAt: row.sharedAt,
      sharePlatform: row.sharePlatform,
    );
  }

  String _toJson(WrappedPayload payload) {
    return jsonEncode({
      'title': payload.title,
      'archetypeId': payload.archetypeId,
      'shareId': payload.shareId,
      'slides': [
        for (final slide in payload.slides)
          {'title': slide.title, 'body': slide.body},
      ],
    });
  }

  WrappedPayload _fromJson(String raw) {
    final json = jsonDecode(raw) as Map<String, Object?>;
    final slides = (json['slides']! as List)
        .cast<Map<String, Object?>>()
        .map(
          (slide) => WrappedSlide(
            title: slide['title']! as String,
            body: slide['body']! as String,
          ),
        )
        .toList();
    return WrappedPayload(
      title: json['title']! as String,
      slides: slides,
      archetypeId: json['archetypeId']! as String,
      shareId: json['shareId']! as String,
    );
  }
}
