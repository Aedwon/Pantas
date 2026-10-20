import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_route.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

class MockHistoryEntry {
  const MockHistoryEntry({required this.attempt, required this.results});

  final MockAttempt attempt;
  final MockResults results;
}

/// W4b's Your mocks: all finished mocks across exams, newest first.
/// Keeps per-exam scores in percent units with their exact stored counts.
final mockHistoryProvider =
    StreamProvider<List<MockHistoryEntry>>((ref) async* {
  if (kIsWeb) throw UnsupportedError('Server mock history reader is pending');
  final feed = ref
      .watch(mockAttemptRepoProvider)
      .watchHistory(mockAttemptLocalUserId, limit: null);
  await for (final attempts in feed) {
    final entries = <MockHistoryEntry>[];
    for (final attempt in attempts) {
      final results = await _loadResults(ref, attempt);
      if (results == null) {
        throw const FormatException('Saved mock results are missing');
      }
      entries.add(MockHistoryEntry(attempt: attempt, results: results));
    }
    yield List.unmodifiable(entries);
  }
});

final mockResultsProvider =
    FutureProvider.family<MockHistoryEntry?, String>((ref, id) async {
  if (kIsWeb) throw UnsupportedError('Server mock results reader is pending');
  final attempt = await ref.watch(mockAttemptRepoProvider).findById(id);
  if (attempt == null) return null;
  final results = await _loadResults(ref, attempt);
  return results == null
      ? null
      : MockHistoryEntry(attempt: attempt, results: results);
});

final mockScoringQuestionsProvider =
    FutureProvider.family<Map<String, Question>, String>((ref, id) async {
  final attempt = await ref.watch(mockAttemptRepoProvider).findById(id);
  if (attempt == null) throw StateError('Mock attempt is missing');
  final sample = jsonDecode(attempt.sampledQuestionsJson) as List<dynamic>;
  final activeIds = await _activeIds(ref, _sampleIds(sample));
  return ref.watch(contentRepositoryProvider).questionsByIds(activeIds);
});

List<String> _sampleIds(List<dynamic> sample) => [
      for (final value in sample)
        ...((value as Map<String, dynamic>)['questionIds'] as List<dynamic>)
            .cast<String>(),
    ];

Future<Set<String>> _activeIds(Ref ref, List<String> ids) async {
  final db = ref.watch(contentDatabaseProvider);
  final rows = await (db.select(db.contentQuestions)
        ..where(
          (row) => row.id.isIn(ids) & row.isActive.equals(true),
        ))
      .get();
  return rows.map((row) => row.id).toSet();
}

Future<MockResults?> _loadResults(Ref ref, MockAttempt attempt) async {
  final raw = attempt.sectionResultsJson;
  if (raw == null) return null;
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  final sections = decoded['sections'] as List<dynamic>? ?? [];
  final legacy = sections.any((Object? value) {
    final section = value! as Map<String, dynamic>;
    return section['wrong'] == null || section['blank'] == null;
  });
  Set<String>? activeIds;
  if (legacy) {
    final sample = jsonDecode(attempt.sampledQuestionsJson) as List<dynamic>;
    activeIds = await _activeIds(ref, _sampleIds(sample));
  }
  return decodeMockResults(attempt, activeQuestionIds: activeIds);
}

class MockReviewAccess {
  const MockReviewAccess({required this.canReview, this.reviewUntil});
  final bool canReview;
  final DateTime? reviewUntil;
}

/// Only native uses W3's device-local allowance. Web needs the server reader.
MockReviewAccess nativeMockReviewAccess({
  required String examId,
  required DateTime? submittedAt,
  required bool pro,
  required DateTime now,
}) {
  final until = const Entitlement.free()
      .mockLimit(examId, at: now, lastMockAt: submittedAt)
      .nextMockOpensAt;
  return MockReviewAccess(
    canReview: pro || (until != null && now.isBefore(until)),
    reviewUntil: until,
  );
}

final mockReviewAccessProvider =
    FutureProvider.family<MockReviewAccess, String>((ref, id) async {
  if (kIsWeb) {
    throw UnsupportedError('Server mock review visibility reader is pending');
  }
  final repo = ref.watch(mockAttemptRepoProvider);
  final clock = ref.watch(mockAvailabilityClockProvider);
  final proFuture = ref.watch(proForActiveExamProvider.future);
  final attempt = await repo.findById(id);
  final pro = await proFuture;
  final now = clock();
  final access = nativeMockReviewAccess(
    examId: attempt?.examId ?? '',
    submittedAt: attempt?.submittedAt,
    pro: pro,
    now: now,
  );
  final until = access.reviewUntil;
  if (!pro && until != null && until.isAfter(now)) {
    final timer = Timer(until.difference(now), ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  return access;
});

/// Strictly earlier submissions from the same exam and profile, oldest first.
final mockEarlierResultsProvider =
    FutureProvider.family<List<MockHistoryEntry>, String>((ref, id) async {
  if (kIsWeb) throw UnsupportedError('Server mock history reader is pending');
  final repo = ref.watch(mockAttemptRepoProvider);
  final attempt = await repo.findById(id);
  if (attempt?.submittedAt == null) return const [];
  final history =
      await repo.history(attempt!.userId, examId: attempt.examId, limit: null);
  final entries = <MockHistoryEntry>[];
  for (final previous in history.reversed) {
    if (previous.id == id ||
        !previous.submittedAt!.isBefore(attempt.submittedAt!)) {
      continue;
    }
    final result = await _loadResults(ref, previous);
    if (result != null) {
      entries.add(MockHistoryEntry(attempt: previous, results: result));
    }
  }
  return List.unmodifiable(entries);
});
