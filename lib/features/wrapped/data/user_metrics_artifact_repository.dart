import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/wrapped/domain/wrapped_payload.dart';

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

/// A published Wrapped card as surfaced in the "My shared cards" list.
class HostedWrappedCard {
  const HostedWrappedCard({
    required this.userId,
    required this.examId,
    required this.artifactId,
    required this.shareId,
    required this.archetypeId,
    required this.title,
    required this.sharedAt,
  });

  final String userId;
  final String examId;
  final String artifactId;
  final String shareId;
  final String archetypeId;
  final String title;
  final DateTime sharedAt;
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
    required String shareId,
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
        shareId: Value(shareId),
      ),
    );
  }

  /// Cards the user has published to a `pantas.app` link, newest first.
  Future<List<HostedWrappedCard>> listShared() async {
    final rows = await (_db.select(_db.userMetricsArtifactsLocal)
          ..where((table) => table.sharedAt.isNotNull())
          ..orderBy([
            (table) => OrderingTerm(
                  expression: table.sharedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
    return [
      for (final row in rows)
        HostedWrappedCard(
          userId: row.userId,
          examId: row.examId,
          artifactId: row.artifactId,
          shareId: row.shareId,
          archetypeId: _fromJson(row.payloadJson).archetypeId,
          title: _fromJson(row.payloadJson).title,
          sharedAt: row.sharedAt!,
        ),
    ];
  }

  /// Drops a card from the local shared list after it is revoked server-side.
  Future<void> setLocalRevoked({
    required String userId,
    required String examId,
    required String artifactId,
  }) async {
    await (_db.update(_db.userMetricsArtifactsLocal)
          ..where(
            (table) =>
                table.userId.equals(userId) &
                table.examId.equals(examId) &
                table.artifactId.equals(artifactId),
          ))
        .write(
      const UserMetricsArtifactsLocalCompanion(
        sharedAt: Value(null),
        sharePlatform: Value(null),
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
