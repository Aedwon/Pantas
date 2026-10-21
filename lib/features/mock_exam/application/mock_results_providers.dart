import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/server_mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_route.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

class MockHistoryEntry {
  const MockHistoryEntry({required this.attempt, required this.results});

  final MockAttempt attempt;
  final MockResults results;
}

/// W4b's Your mocks: all finished mocks across exams, newest first.
/// Keeps per-exam scores in percent units with their exact stored counts.
final mockHistoryProvider =
    StreamProvider<List<MockHistoryEntry>>((ref) async* {
  if (ref.watch(mockUsesServerProvider)) {
    final rows = await ref.watch(serverMockHistoryProvider.future);
    yield List.unmodifiable(
      rows.map(
        (row) =>
            serverMockHistoryEntry(row, ref.read(serverMockIdentityProvider)!),
      ),
    );
    return;
  }
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
  if (ref.watch(mockUsesServerProvider)) {
    final row = await ref.watch(serverMockResultProvider(id).future);
    return serverMockHistoryEntry(row, ref.read(serverMockIdentityProvider)!);
  }
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
  const MockReviewAccess({
    required this.canReview,
    this.proCovered = false,
    this.reviewUntil,
  });

  final bool canReview;
  final bool proCovered;
  final DateTime? reviewUntil;
}

/// Only native uses W3's device-local allowance. Web needs the server reader.
/// Pro coverage is evaluated against the stored attempt exam, never the
/// active exam.
MockReviewAccess nativeMockReviewAccess({
  required String examId,
  required DateTime? submittedAt,
  required Entitlement entitlement,
  required DateTime now,
  PriceTier? examTier,
}) {
  final proCovered =
      entitlement.coversExam(examId, examTier: examTier, at: now);
  final until = const Entitlement.free()
      .mockLimit(examId, at: now, lastMockAt: submittedAt)
      .nextMockOpensAt;
  return MockReviewAccess(
    canReview: proCovered || (until != null && now.isBefore(until)),
    proCovered: proCovered,
    reviewUntil: until,
  );
}

final mockReviewAccessProvider =
    FutureProvider.family<MockReviewAccess, String>((ref, id) async {
  if (ref.watch(mockUsesServerProvider)) {
    final row = await ref.watch(serverMockResultProvider(id).future);
    return MockReviewAccess(
      canReview: row.canReview,
      proCovered: row.proCovered,
      reviewUntil:
          DateTime.fromMillisecondsSinceEpoch(row.reviewUntil, isUtc: true),
    );
  }
  final repo = ref.watch(mockAttemptRepoProvider);
  final clock = ref.watch(mockAvailabilityClockProvider);
  final attempt = await repo.findById(id);
  final entitlement = await ref.watch(entitlementProvider.future);
  final now = clock();
  PriceTier? examTier;
  if (attempt != null) {
    final catalog =
        await ref.watch(examCatalogRepositoryProvider).watchAll().first;
    for (final entry in catalog) {
      if (entry.id == attempt.examId) {
        examTier = PriceTier.fromCatalog(entry.priceTier);
        break;
      }
    }
  }
  final access = nativeMockReviewAccess(
    examId: attempt?.examId ?? '',
    submittedAt: attempt?.submittedAt,
    entitlement: entitlement,
    examTier: examTier,
    now: now,
  );
  final until = access.reviewUntil;
  if (!access.proCovered && until != null && until.isAfter(now)) {
    final timer = Timer(until.difference(now), ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  return access;
});

/// Strictly earlier submissions from the same exam and profile, oldest first.
final mockEarlierResultsProvider =
    FutureProvider.family<List<MockHistoryEntry>, String>((ref, id) async {
  if (ref.watch(mockUsesServerProvider)) {
    final current = await ref.watch(serverMockResultProvider(id).future);
    final rows = await ref.watch(serverMockHistoryProvider.future);
    return List.unmodifiable(
      rows.reversed
          .where(
            (row) =>
                row.examId == current.examId &&
                row.submittedAt < current.submittedAt,
          )
          .map(
            (row) => serverMockHistoryEntry(
              row,
              ref.read(serverMockIdentityProvider)!,
            ),
          ),
    );
  }
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

/// Adapts server-owned summary data to the existing presentation without a
/// local database write. Review uses the pinned server paper separately.
MockHistoryEntry serverMockHistoryEntry(ServerMockResult row, String uid) {
  DateTime date(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  return MockHistoryEntry(
    results: row.results,
    attempt: MockAttempt(
      id: row.mockId,
      userId: uid,
      examId: row.examId,
      blueprintId: row.examId,
      blueprintName: row.examId == 'exam_cse_pro'
          ? 'CSE Professional'
          : row.examId == 'exam_cse_sub'
              ? 'CSE Subprofessional'
              : row.examId,
      durationMinutes: row.limitMs ~/ 60000,
      status: row.endedBy == 'strict-exit'
          ? MockAttemptStatus.forfeited
          : MockAttemptStatus.completed,
      strictMode: row.strict,
      sampledQuestionsJson: '[]',
      answersJson: '{}',
      flagsJson: '[]',
      elapsedSeconds: row.durationMs ~/ 1000,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      currentIndex: 0,
      startedAt: date(row.startedAt),
      lastFlushedAt: date(row.submittedAt),
      updatedAt: date(row.submittedAt),
      submittedAt: date(row.submittedAt),
      scoreRaw: row.results.scoreRaw,
      scoreTotal: row.results.scoreTotal,
      totalTimeSeconds: row.results.totalTimeSeconds,
    ),
  );
}
