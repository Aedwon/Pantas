import 'dart:convert';

import 'package:meta/meta.dart';

/// An assessment the learner started and has not finished: what is needed to
/// open it again where they left off. Kept on the device only, one per account
/// and exam, and removed when the result saves.
@immutable
class AssessmentProgress {
  const AssessmentProgress({
    required this.examId,
    required this.attemptId,
    required this.startedAt,
    required this.questionIds,
    this.picks = const {},
    this.responseMs = const {},
  });

  final String examId;
  final String attemptId;
  final DateTime startedAt;

  /// The questions in the order they are asked.
  final List<String> questionIds;

  /// Question id to the choice id picked.
  final Map<String, String> picks;

  /// Question id to the time taken, in milliseconds.
  final Map<String, int> responseMs;

  int get total => questionIds.length;

  /// Questions in the list with a saved pick.
  int get answered => questionIds.where(picks.containsKey).length;

  /// Where Continue opens: the first question with no pick, or null when every
  /// question has one.
  int? get firstUnansweredIndex {
    final index = questionIds.indexWhere((id) => !picks.containsKey(id));
    return index < 0 ? null : index;
  }

  AssessmentProgress withPick({
    required String questionId,
    required String choiceId,
    int? elapsedMs,
  }) =>
      AssessmentProgress(
        examId: examId,
        attemptId: attemptId,
        startedAt: startedAt,
        questionIds: questionIds,
        picks: {...picks, questionId: choiceId},
        responseMs: {
          ...responseMs,
          if (elapsedMs != null) questionId: elapsedMs,
        },
      );

  /// This progress limited to [ids], in the saved order. Null when none of
  /// the saved questions is in [ids].
  AssessmentProgress? keepOnly(Set<String> ids) {
    final kept = [
      for (final id in questionIds)
        if (ids.contains(id)) id,
    ];
    if (kept.isEmpty) return null;
    return AssessmentProgress(
      examId: examId,
      attemptId: attemptId,
      startedAt: startedAt,
      questionIds: kept,
      picks: {
        for (final entry in picks.entries)
          if (kept.contains(entry.key)) entry.key: entry.value,
      },
      responseMs: {
        for (final entry in responseMs.entries)
          if (kept.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  String encode() => jsonEncode({
        'examId': examId,
        'attemptId': attemptId,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'questionIds': questionIds,
        'picks': picks,
        'responseMs': responseMs,
      });

  /// Reads [raw], or null when it is damaged or lists no question.
  static AssessmentProgress? tryParse(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      final examId = json['examId'];
      final attemptId = json['attemptId'];
      final startedAt = json['startedAt'];
      final ids = json['questionIds'];
      if (examId is! String ||
          attemptId is! String ||
          startedAt is! String ||
          ids is! List) {
        return null;
      }
      final questionIds = ids.whereType<String>().toList();
      if (questionIds.isEmpty) return null;
      final picks = json['picks'];
      final times = json['responseMs'];
      return AssessmentProgress(
        examId: examId,
        attemptId: attemptId,
        startedAt: DateTime.parse(startedAt),
        questionIds: questionIds,
        picks: {
          if (picks is Map<String, dynamic>)
            for (final e in picks.entries)
              if (e.value is String) e.key: e.value as String,
        },
        responseMs: {
          if (times is Map<String, dynamic>)
            for (final e in times.entries)
              if (e.value is int) e.key: e.value as int,
        },
      );
    } on FormatException {
      return null;
    }
  }
}
