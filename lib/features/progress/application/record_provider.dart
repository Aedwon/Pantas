import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

@immutable
class StudentRecord {
  const StudentRecord({
    required this.weeksIn,
    required this.dayStreak,
    required this.streakStartedOn,
    required this.questionsAnswered,
    required this.sessionMinutes,
    required this.lessonsRead,
    required this.daysActive,
    required this.longestStreak,
    required this.bestMockPercent,
    required this.accuracySeries,
    required this.mocks,
  });

  final int weeksIn;
  final int dayStreak;
  final DateTime? streakStartedOn;
  final int questionsAnswered;

  /// Time in sessions, never "time studied". Reading time is not tracked.
  final int sessionMinutes;

  final int lessonsRead;
  final int daysActive;
  final int longestStreak;

  /// Null until a mock has been submitted. Absent, not zero.
  final int? bestMockPercent;

  /// One point per week of prep. Empty below two points, because a line
  /// through one point is not a trend and drawing it would be a shape the
  /// data does not have.
  final List<({DateTime weekStart, double accuracy})> accuracySeries;

  /// Newest first. Empty until a mock has been submitted.
  final List<({DateTime takenOn, int percent, String blueprintName})> mocks;
}

final recordNowProvider = Provider<DateTime?>((ref) => null);

final recordProvider = FutureProvider<StudentRecord>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final now = ref.watch(recordNowProvider) ?? DateTime.now();

  final allAttemptsRows = await db.select(db.attemptsLocal).get();
  final lessonProgressRows = await db.select(db.lessonProgressLocal).get();
  final streakRow = await (db.select(db.streakLocal)
        ..where((s) => s.id.equals(1)))
      .getSingleOrNull();
  final mockAttemptsRows = await (db.select(db.mockAttempts)
        ..where((m) => m.status.equals('completed')))
      .get();
  // Skip a mirrored answer only when its completed mock is counted below.
  final countedMockIds = mockAttemptsRows.map((m) => m.id).toSet();
  final attemptsRows = allAttemptsRows
      .where(
        (a) =>
            !AttemptOrigins.mirrored.contains(a.origin) ||
            !countedMockIds.contains(a.id),
      )
      .toList();

  // 1. First activity date for weeksIn
  DateTime? earliestDate;

  for (final row in attemptsRows) {
    final dt = row.startedAt;
    if (earliestDate == null || dt.isBefore(earliestDate)) {
      earliestDate = dt;
    }
  }
  for (final row in lessonProgressRows) {
    final dt = row.readAt;
    if (earliestDate == null || dt.isBefore(earliestDate)) {
      earliestDate = dt;
    }
  }
  for (final row in mockAttemptsRows) {
    final dt = row.startedAt;
    if (earliestDate == null || dt.isBefore(earliestDate)) {
      earliestDate = dt;
    }
  }

  var weeksIn = 0;
  if (earliestDate != null) {
    final days = now.difference(earliestDate).inDays;
    weeksIn = max(1, (days / 7.0).ceil());
  }

  // 2. Streaks
  final dayStreak = streakRow?.current ?? 0;
  final longestStreak = streakRow?.longest ?? 0;
  DateTime? streakStartedOn;

  // Rest days can be skipped or credited, so the start cannot be derived
  // from the count unless every day is a study day. A wrong date is worse
  // than no date. The existing freeze caveat still applies: if freezes are
  // granted, spending one must be recorded before showing a derived date.
  final studyDays = (await ref.watch(userSettingsProvider.future)).studyDays;
  if (studyDays.isEveryDay &&
      dayStreak > 0 &&
      streakRow?.lastActiveDate != null) {
    final lastActive = streakRow!.lastActiveDate!;
    final localLastActive =
        DateTime(lastActive.year, lastActive.month, lastActive.day);
    streakStartedOn = DateTime(
      localLastActive.year,
      localLastActive.month,
      localLastActive.day - dayStreak + 1,
    );
  }

  // Helper for reading items in attempts_local
  List<({bool isCorrect})> parseAttemptItems(String itemsJson) {
    try {
      final decoded = jsonDecode(itemsJson);
      if (decoded is! List) return const [];
      final result = <({bool isCorrect})>[];
      for (final item in decoded) {
        if (item is Map<String, Object?>) {
          final chosen = item['chosenChoiceId'];
          final correct = item['correctChoiceId'];
          result.add((isCorrect: chosen != null && chosen == correct));
        }
      }
      return result;
    } catch (_) {
      return const [];
    }
  }

  // 3. Questions answered & Session minutes
  var questionsAnswered = 0;
  var totalSessionSeconds = 0;

  for (final row in attemptsRows) {
    final items = parseAttemptItems(row.itemsJson);
    questionsAnswered += items.length;
    final comp = row.completedAt;
    if (comp != null) {
      totalSessionSeconds += comp.difference(row.startedAt).inSeconds;
    }
  }

  for (final row in mockAttemptsRows) {
    if (row.scoreTotal != null && row.scoreTotal! > 0) {
      questionsAnswered += row.scoreTotal!;
    } else if (row.answersJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(row.answersJson);
        if (decoded is Map) {
          questionsAnswered += decoded.length;
        }
      } catch (_) {}
    }
    if (row.submittedAt != null) {
      totalSessionSeconds += row.elapsedSeconds;
    }
  }

  final sessionMinutes = (totalSessionSeconds / 60.0).round();

  // 4. Lessons read
  final lessonsRead = lessonProgressRows.length;

  // 5. Days active (distinct local dates across attempts and lesson progress)
  final activeDates = <DateTime>{};
  for (final row in attemptsRows) {
    final dt = row.startedAt.toLocal();
    activeDates.add(DateTime(dt.year, dt.month, dt.day));
  }
  for (final row in lessonProgressRows) {
    final dt = row.readAt.toLocal();
    activeDates.add(DateTime(dt.year, dt.month, dt.day));
  }
  for (final row in mockAttemptsRows) {
    final dt = row.startedAt.toLocal();
    activeDates.add(DateTime(dt.year, dt.month, dt.day));
  }
  final daysActive = activeDates.length;

  // 6. Mocks
  int? bestMockPercent;
  final mocksList = <({DateTime takenOn, int percent, String blueprintName})>[];

  if (mockAttemptsRows.isNotEmpty) {
    for (final row in mockAttemptsRows) {
      final scoreRaw = row.scoreRaw;
      final scoreTotal = row.scoreTotal;
      if (scoreRaw != null &&
          scoreTotal != null &&
          scoreTotal > 0 &&
          row.submittedAt != null) {
        final pct = (scoreRaw * 100 / scoreTotal).round();
        if (bestMockPercent == null || pct > bestMockPercent) {
          bestMockPercent = pct;
        }
        mocksList.add(
          (
            takenOn: row.submittedAt!,
            percent: pct,
            blueprintName: row.blueprintName,
          ),
        );
      }
    }
    mocksList.sort((a, b) => b.takenOn.compareTo(a.takenOn));
  }

  // 7. Accuracy series (one point per week of prep, empty if < 2 points)
  final weeklyAttempts = <DateTime, ({int correct, int total})>{};
  for (final row in attemptsRows) {
    final items = parseAttemptItems(row.itemsJson);
    if (items.isEmpty) continue;
    final dt = row.startedAt.toLocal();
    final localDate = DateTime(dt.year, dt.month, dt.day);
    final weekStart = localDate.subtract(Duration(days: localDate.weekday - 1));

    var correctCount = 0;
    for (final item in items) {
      if (item.isCorrect) correctCount++;
    }

    final prev = weeklyAttempts[weekStart] ?? (correct: 0, total: 0);
    weeklyAttempts[weekStart] = (
      correct: prev.correct + correctCount,
      total: prev.total + items.length,
    );
  }

  final sortedWeeks = weeklyAttempts.keys.toList()..sort();
  final accuracySeries = <({DateTime weekStart, double accuracy})>[];

  if (sortedWeeks.length >= 2) {
    for (final w in sortedWeeks) {
      final data = weeklyAttempts[w]!;
      final acc = data.total > 0 ? (data.correct / data.total) * 100.0 : 0.0;
      accuracySeries.add((weekStart: w, accuracy: acc));
    }
  }

  return StudentRecord(
    weeksIn: weeksIn,
    dayStreak: dayStreak,
    streakStartedOn: streakStartedOn,
    questionsAnswered: questionsAnswered,
    sessionMinutes: sessionMinutes,
    lessonsRead: lessonsRead,
    daysActive: daysActive,
    longestStreak: longestStreak,
    bestMockPercent: bestMockPercent,
    accuracySeries: accuracySeries,
    mocks: mocksList,
  );
});
