import 'package:collection/collection.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/quiz/domain/passage_set_filler.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';

/// Stable principal is durable. The lifetime token guards only in-flight work.
class ReviewBatchScope {
  const ReviewBatchScope({
    required this.userId,
    required this.examId,
    required this.principal,
    required this.accountLifetimeToken,
  });
  final String userId;
  final String examId;
  final String principal;
  final String accountLifetimeToken;

  bool matches(ReviewBatchScope other) =>
      userId == other.userId &&
      examId == other.examId &&
      principal == other.principal &&
      accountLifetimeToken == other.accountLifetimeToken;
}

/// Receives the review selector's actual ordered membership, never a due count
/// or the truncated mixed Today plan. Only Reviews callers use this contract.
class PreparedReviewBatch {
  PreparedReviewBatch._(
    this.scope,
    this.preferences,
    this.localDay,
    this.chunks,
    this.excludedQuestionIds,
  );

  factory PreparedReviewBatch.fromReviews({
    required ReviewBatchScope scope,
    required QuizPreferences preferences,
    required DateTime localDay,
    required List<Question> orderedDueReviews,
  }) {
    final ids = <String>{};
    for (final question in orderedDueReviews) {
      if (!ids.add(question.id) || !question.examIds.contains(scope.examId)) {
        throw StateError('Invalid Reviews membership');
      }
    }
    final grouped = groupPassageSets(orderedDueReviews);
    final groups = <List<Question>>[];
    for (final question in grouped) {
      final passage = question.passageId;
      if (passage != null &&
          passage.isNotEmpty &&
          groups.isNotEmpty &&
          groups.last.last.passageId == passage) {
        groups.last.add(question);
      } else {
        groups.add([question]);
      }
    }
    final cap = preferences.sessionLength == QuizPreferences.allDueSessionLength
        ? grouped.length
        : preferences.sessionLength;
    final chunks = <List<Question>>[];
    final excluded = <String>[];
    var current = <Question>[];
    for (final group in groups) {
      if (group.length > cap) {
        excluded.addAll(group.map((q) => q.id));
        continue;
      }
      if (current.length + group.length > cap) {
        chunks.add(List.unmodifiable(current));
        current = [];
      }
      current.addAll(group);
    }
    if (current.isNotEmpty) chunks.add(List.unmodifiable(current));
    return PreparedReviewBatch._(
      scope,
      preferences,
      DateTime(localDay.year, localDay.month, localDay.day),
      List.unmodifiable(chunks),
      List.unmodifiable(excluded),
    );
  }

  final ReviewBatchScope scope;
  final QuizPreferences preferences;
  final DateTime localDay;
  final List<List<Question>> chunks;
  final List<String> excludedQuestionIds;
}

class ReviewBatchSession {
  const ReviewBatchSession({
    required this.session,
    required this.ordinal,
    required this.total,
  });
  final QuizSession session;
  final int ordinal;
  final int total;
}

class StoredReviewBatch {
  StoredReviewBatch({
    required this.scope,
    required this.localDay,
    required this.sessionLength,
    required this.ordering,
    required List<String> sessionIds,
    required List<List<String>> chunks,
    required List<List<int>> versions,
    this.current = 0,
    this.nextReady = false,
  })  : sessionIds = List.unmodifiable(sessionIds),
        chunks = List.unmodifiable(chunks.map(List<String>.unmodifiable)),
        versions = List.unmodifiable(versions.map(List<int>.unmodifiable));

  factory StoredReviewBatch.parse(
    Object? value, {
    required ReviewBatchScope scope,
  }) {
    Never invalid() => throw StateError('Invalid Reviews metadata');
    if (value is! Map<String, dynamic> ||
        value['version'] is! int ||
        value['version'] != 1 ||
        value['userId'] != scope.userId ||
        value['examId'] != scope.examId ||
        value['principal'] is! String ||
        value['sessionLength'] is! int ||
        value['ordering'] is! String ||
        value['localDay'] is! String ||
        value['current'] is! int ||
        value['nextReady'] is! bool) {
      invalid();
    }
    final length = value['sessionLength'] as int;
    if (![5, 10, 20, -1].contains(length) ||
        !['blocked', 'interleaved_tail', 'fully_mixed']
            .contains(value['ordering'])) {
      invalid();
    }
    final day = DateTime.tryParse(value['localDay'] as String);
    if (day == null ||
        day.toIso8601String() != value['localDay'] ||
        day.hour != 0 ||
        day.minute != 0 ||
        day.second != 0 ||
        day.millisecond != 0 ||
        day.microsecond != 0) {
      invalid();
    }
    final rawIds = value['sessionIds'];
    final rawChunks = value['chunks'];
    final rawVersions = value['versions'];
    if (rawIds is! List ||
        rawChunks is! List ||
        rawVersions is! List ||
        rawIds.isEmpty ||
        rawIds.length != rawChunks.length ||
        rawIds.length != rawVersions.length ||
        rawIds.any((id) => id is! String || id.isEmpty) ||
        rawIds.toSet().length != rawIds.length ||
        value['batchId'] != rawIds.first) {
      invalid();
    }
    final chunks = <List<String>>[];
    final versions = <List<int>>[];
    final seen = <String>{};
    for (var i = 0; i < rawChunks.length; i++) {
      final chunk = rawChunks[i];
      final version = rawVersions[i];
      if (chunk is! List ||
          chunk.isEmpty ||
          version is! List ||
          version.length != chunk.length ||
          (length != -1 && chunk.length > length) ||
          chunk.any((id) => id is! String || id.isEmpty || !seen.add(id)) ||
          version.any((v) => v is! int || v < 1)) {
        invalid();
      }
      chunks.add(chunk.cast<String>());
      versions.add(version.cast<int>());
    }
    final current = value['current'] as int;
    final ready = value['nextReady'] as bool;
    if (current < 0 ||
        current >= chunks.length ||
        (length == -1 && chunks.length != 1) ||
        (ready && current == chunks.length - 1)) {
      invalid();
    }
    return StoredReviewBatch(
      scope: ReviewBatchScope(
        userId: scope.userId,
        examId: scope.examId,
        principal: value['principal'] as String,
        accountLifetimeToken: scope.accountLifetimeToken,
      ),
      localDay: day,
      sessionLength: length,
      ordering: value['ordering'] as String,
      sessionIds: rawIds.cast<String>(),
      chunks: chunks,
      versions: versions,
      current: current,
      nextReady: ready,
    );
  }

  final ReviewBatchScope scope;
  final DateTime localDay;
  final int sessionLength;
  final String ordering;
  final List<String> sessionIds;
  final List<List<String>> chunks;
  final List<List<int>> versions;
  final int current;
  final bool nextReady;
  String get batchId => sessionIds.first;

  bool matchesQuestions(int index, List<String> ids) =>
      const ListEquality<String>().equals(chunks[index], ids);
  StoredReviewBatch advance({required int current, required bool nextReady}) =>
      StoredReviewBatch(
        scope: scope,
        localDay: localDay,
        sessionLength: sessionLength,
        ordering: ordering,
        sessionIds: sessionIds,
        chunks: chunks,
        versions: versions,
        current: current,
        nextReady: nextReady,
      );
  Map<String, Object> toJson() => {
        'version': 1,
        'batchId': batchId,
        'userId': scope.userId,
        'examId': scope.examId,
        'principal': scope.principal,
        'localDay': localDay.toIso8601String(),
        'sessionLength': sessionLength,
        'ordering': ordering,
        'sessionIds': sessionIds,
        'chunks': chunks,
        'versions': versions,
        'current': current,
        'nextReady': nextReady,
      };
}
