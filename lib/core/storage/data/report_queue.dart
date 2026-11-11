import 'dart:convert';

import 'package:pantas/core/storage/data/app_database.dart';

class QuestionReport {
  const QuestionReport({
    required this.questionId,
    required this.message,
    required this.createdAt,
  });
  final String questionId;
  final String message;
  final DateTime createdAt;
}

enum ReportResult { queued, empty, questionLimit, dailyLimit }

/// Device-local, atomic limits. Reports stay pending until a backend sender is
/// approved. Keeping them also preserves the per-question lifetime count.
class ReportQueue {
  ReportQueue(this._db);
  final AppDatabase _db;
  static const _key = 'quiz_question_reports';

  Future<List<QuestionReport>> pending() async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(_key)))
        .getSingleOrNull();
    if (row == null) return [];
    final data = jsonDecode(row.value) as List<dynamic>;
    return [
      for (final item in data)
        QuestionReport(
          questionId: (item as Map<String, dynamic>)['questionId'] as String,
          message: item['message'] as String,
          createdAt: DateTime.parse(item['createdAt'] as String),
        ),
    ];
  }

  Future<ReportResult?> limit(String questionId, DateTime now) async {
    final reports = await pending();
    if (reports.where((r) => r.questionId == questionId).length >= 3) {
      return ReportResult.questionLimit;
    }
    if (reports.where((r) => _sameDay(r.createdAt, now)).length >= 20) {
      return ReportResult.dailyLimit;
    }
    return null;
  }

  Future<ReportResult> add(
    String questionId,
    String message,
    DateTime now,
  ) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return ReportResult.empty;
    return _db.transaction(() async {
      final blocked = await limit(questionId, now);
      if (blocked != null) return blocked;
      final reports = await pending();
      reports.add(
        QuestionReport(
          questionId: questionId,
          message: trimmed,
          createdAt: now,
        ),
      );
      await _db.into(_db.devicePrefs).insertOnConflictUpdate(
            DevicePrefsCompanion.insert(
              key: _key,
              value: jsonEncode([
                for (final report in reports)
                  {
                    'questionId': report.questionId,
                    'message': report.message,
                    'createdAt': report.createdAt.toIso8601String(),
                  },
              ]),
            ),
          );
      return ReportResult.queued;
    });
  }

  Future<void> sendPending() async {
    // No approved backend endpoint. Never discard an unsent report.
  }

  bool _sameDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }
}
