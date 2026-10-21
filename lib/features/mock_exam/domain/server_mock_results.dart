import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/server_mock_paper.dart';

Map<String, Object?> serverMockObject(Object? value) {
  if (value is! Map || value.keys.any((Object? key) => key is! String)) {
    throw const ServerMockFormatException('Expected an object');
  }
  return value.cast<String, Object?>();
}

int serverMockWhole(Object? value) {
  if (value is num && value.isFinite && value >= 0 && value == value.round()) {
    return value.toInt();
  }
  throw const ServerMockFormatException('Expected a nonnegative whole number');
}

String serverMockText(Object? value) {
  if (value is String && value.isNotEmpty) return value;
  throw const ServerMockFormatException('Expected text');
}

bool _flag(Object? value) {
  if (value is bool) return value;
  throw const ServerMockFormatException('Expected a flag');
}

class ServerMockNote {
  const ServerMockNote({this.missReason, this.blankReason, this.reasonNote});
  factory ServerMockNote.decode(Object? raw) {
    final map = serverMockObject(raw);
    T? reason<T extends Enum>(Object? value, List<T> values) {
      if (value == null) return null;
      for (final entry in values) {
        if (entry.name == value) return entry;
      }
      throw const ServerMockFormatException('Unknown review reason');
    }

    final note = map['reasonNote'];
    if (note != null && (note is! String || note.length > 4000)) {
      throw const ServerMockFormatException('Invalid review note');
    }
    return ServerMockNote(
      missReason: reason(map['missReason'], MissReason.values),
      blankReason: reason(map['blankReason'], BlankReason.values),
      reasonNote: note as String?,
    );
  }
  final MissReason? missReason;
  final BlankReason? blankReason;
  final String? reasonNote;
}

/// Server results are view data. They are never persisted as local attempts.
class ServerMockResult {
  ServerMockResult._({
    required this.mockId,
    required this.examId,
    required this.startedAt,
    required this.submittedAt,
    required this.durationMs,
    required this.limitMs,
    required this.strict,
    required this.endedBy,
    required this.results,
    required this.canReview,
    required this.proCovered,
    required this.reviewUntil,
    required this.serverNow,
    required this.accessRecheckAt,
    required this.paper,
    required this.notes,
  });

  factory ServerMockResult.decode(Object? raw) {
    final map = serverMockObject(raw);
    final mockId = serverMockText(map['mockId']);
    if (!RegExp(r'^[A-Za-z0-9]{10,40}$').hasMatch(mockId)) {
      throw const ServerMockFormatException('Invalid mock identity');
    }
    final examId = serverMockText(map['examId']);
    final strict = _flag(map['strict']);
    final canReview = _flag(map['canReview']);
    final proCovered = _flag(map['proCovered']);
    final startedAt = serverMockWhole(map['startedAt']);
    final submittedAt = serverMockWhole(map['submittedAt']);
    final durationMs = serverMockWhole(map['durationMs']);
    final limitMs = serverMockWhole(map['limitMs']);
    final reviewUntil = serverMockWhole(map['reviewUntil']);
    final serverNow = serverMockWhole(map['serverNow']);
    final accessRecheckAt = map['accessRecheckAt'] == null
        ? null
        : serverMockWhole(map['accessRecheckAt']);
    final endedBy = serverMockText(map['endedBy']);
    if (limitMs == 0 ||
        submittedAt < startedAt ||
        reviewUntil < submittedAt ||
        serverNow < submittedAt ||
        (accessRecheckAt != null && accessRecheckAt <= serverNow) ||
        !['student', 'strict-exit', 'time-out'].contains(endedBy) ||
        (proCovered && !canReview)) {
      throw const ServerMockFormatException('Invalid completed mock');
    }
    ({int correct, int wrong, int blank, int total}) counts(Object? value) {
      final m = serverMockObject(value);
      final correct = serverMockWhole(m['correct']);
      final wrong = serverMockWhole(m['wrong']);
      final blank = serverMockWhole(m['blank']);
      final total = serverMockWhole(m['total']);
      if (correct + wrong + blank != total ||
          serverMockWhole(m['answered']) != correct + wrong) {
        throw const ServerMockFormatException('Invalid result counts');
      }
      return (correct: correct, wrong: wrong, blank: blank, total: total);
    }

    final score = counts(map['score']);
    final rawSections = map['sections'];
    if (rawSections is! List || rawSections.isEmpty) {
      throw const ServerMockFormatException('Missing result breakdown');
    }
    final sections = <SectionResult>[];
    final seen = <String>{};
    for (final value in rawSections) {
      final section = serverMockObject(value);
      final count = counts(section);
      final id = serverMockText(section['sectionId']);
      if (!seen.add(id)) {
        throw const ServerMockFormatException('Repeated result section');
      }
      sections.add(
        SectionResult(
          sectionId: id, name: serverMockText(section['name']),
          correct: count.correct, wrong: count.wrong, blank: count.blank,
          total: count.total, retiredCount: 0,
          // Web has one clock. Per-section time is not displayed.
          timeSeconds: 0,
        ),
      );
    }
    int sum(int Function(SectionResult) read) =>
        sections.fold(0, (total, section) => total + read(section));
    if (sum((s) => s.correct) != score.correct ||
        sum((s) => s.wrong!) != score.wrong ||
        sum((s) => s.blank!) != score.blank ||
        sum((s) => s.total) != score.total) {
      throw const ServerMockFormatException('Breakdown differs from score');
    }
    ServerMockPaper? paper;
    final hasPaper = map.containsKey('paper');
    final hasAnswers = map.containsKey('answers');
    if (!canReview && (hasPaper || hasAnswers || map.containsKey('notes'))) {
      throw const ServerMockFormatException(
        'Locked result contains review data',
      );
    }
    // History is a summary even while review remains open.
    if (hasPaper || hasAnswers) {
      if (!hasPaper || !hasAnswers) {
        throw const ServerMockFormatException('Incomplete review data');
      }
      paper =
          ServerMockPaper.decode({...map, 'remainingMs': 0, 'paused': false});
      if (paper.sections.length != sections.length ||
          paper.questionIds.length != score.total) {
        throw const ServerMockFormatException('Paper differs from results');
      }
      for (var i = 0; i < sections.length; i++) {
        if (paper.sections[i].sectionId != sections[i].sectionId ||
            paper.sections[i].questions.length != sections[i].total) {
          throw const ServerMockFormatException('Paper breakdown differs');
        }
      }
    }
    if (!proCovered && map.containsKey('notes')) {
      throw const ServerMockFormatException('Free result contains paid notes');
    }
    final rawNotes = serverMockObject(map['notes'] ?? <String, Object?>{});
    if (paper != null &&
        rawNotes.keys.any((id) => !paper!.questionIds.contains(id))) {
      throw const ServerMockFormatException('Note is outside the paper');
    }
    return ServerMockResult._(
      mockId: mockId,
      examId: examId,
      startedAt: startedAt,
      submittedAt: submittedAt,
      durationMs: durationMs,
      limitMs: limitMs,
      strict: strict,
      endedBy: endedBy,
      canReview: canReview,
      proCovered: proCovered,
      reviewUntil: reviewUntil,
      serverNow: serverNow,
      accessRecheckAt: accessRecheckAt,
      paper: paper,
      notes: Map.unmodifiable(
        rawNotes.map((id, note) => MapEntry(id, ServerMockNote.decode(note))),
      ),
      results: MockResults(
        scoreRaw: score.correct,
        scoreTotal: score.total,
        percent: mockScorePercent(examId: examId, sections: sections),
        sections: List.unmodifiable(sections),
        topWeak: const [],
        totalTimeSeconds: durationMs ~/ 1000,
        wasStrict: strict,
      ),
    );
  }

  final String mockId;
  final String examId;
  final int startedAt;
  final int submittedAt;
  final int durationMs;
  final int limitMs;
  final bool strict;
  final String endedBy;
  final MockResults results;
  final bool canReview;
  final bool proCovered;
  final int reviewUntil;
  final int serverNow;
  final int? accessRecheckAt;
  final ServerMockPaper? paper;
  final Map<String, ServerMockNote> notes;
}

class ServerMockHistoryPage {
  ServerMockHistoryPage(Object? raw) {
    final map = serverMockObject(raw);
    final rows = map['items'];
    if (rows is! List || rows.length > 100) {
      throw const ServerMockFormatException('Invalid history page');
    }
    items = List.unmodifiable(rows.map(ServerMockResult.decode));
    final cursor = map['next'];
    next = cursor == null ? null : Map.unmodifiable(serverMockObject(cursor));
    if (next != null) {
      serverMockWhole(next!['submittedAt']);
      serverMockText(next!['mockId']);
    }
  }
  late final List<ServerMockResult> items;
  late final Map<String, Object?>? next;
}
