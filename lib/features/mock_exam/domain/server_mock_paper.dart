import 'package:meta/meta.dart';

/// The server's answer to a malformed response. The paper is pinned and the
/// clock is the server's, so a response that cannot be read is not repaired.
class ServerMockFormatException implements Exception {
  const ServerMockFormatException(this.message);
  final String message;

  @override
  String toString() => 'ServerMockFormatException: $message';
}

/// One question of the pinned paper. [setId] groups questions that share a
/// passage.
@immutable
class ServerMockQuestion {
  const ServerMockQuestion({required this.id, required this.setId});
  final String id;
  final String setId;
}

@immutable
class ServerMockSection {
  const ServerMockSection({
    required this.sectionId,
    required this.name,
    required this.questions,
  });
  final String sectionId;
  final String name;
  final List<ServerMockQuestion> questions;
}

/// An answer as the server keeps it. [chosen] is null for a blank.
@immutable
class ServerMockAnswer {
  const ServerMockAnswer({
    required this.questionId,
    required this.chosen,
    required this.correct,
    required this.answeredAt,
  });

  final String questionId;
  final String? chosen;
  final bool correct;

  /// Milliseconds since the epoch, on the server's clock.
  final int answeredAt;

  Map<String, Object?> toJson() => {
        'questionId': questionId,
        'chosen': chosen,
        'correct': correct,
        'answeredAt': answeredAt,
      };
}

/// The open mock exactly as startMock, getMockPaper and controlMock return
/// it. Identity, the pinned paper and the clock are all the server's.
@immutable
class ServerMockPaper {
  const ServerMockPaper._({
    required this.mockId,
    required this.examId,
    required this.startedAt,
    required this.strict,
    required this.limit,
    required this.remaining,
    required this.paused,
    required this.sections,
    required this.answers,
  });

  factory ServerMockPaper.decode(Object? raw) {
    final map = _map(raw, 'mock');
    final mockId = _string(map, 'mockId');
    if (!_mockIdPattern.hasMatch(mockId)) {
      throw const ServerMockFormatException('bad mock id');
    }
    final limitMs = _wholeNumber(map, 'limitMs');
    if (limitMs <= 0) {
      throw const ServerMockFormatException('limitMs must be positive');
    }
    final remainingMs = _wholeNumber(map, 'remainingMs');
    if (remainingMs < 0 || remainingMs > limitMs) {
      throw const ServerMockFormatException('remainingMs is out of range');
    }
    final paper = _map(map['paper'], 'paper');
    final sectionsRaw = paper['sections'];
    if (sectionsRaw is! List || sectionsRaw.isEmpty) {
      throw const ServerMockFormatException('the paper has no sections');
    }
    final seen = <String>{};
    final sections = <ServerMockSection>[];
    for (final value in sectionsRaw) {
      final section = _map(value, 'section');
      final questionsRaw = section['questions'];
      if (questionsRaw is! List || questionsRaw.isEmpty) {
        throw const ServerMockFormatException('a section has no questions');
      }
      final questions = <ServerMockQuestion>[];
      for (final question in questionsRaw) {
        final entry = _map(question, 'question');
        final id = _string(entry, 'id');
        if (id.length > 128 || !seen.add(id)) {
          throw const ServerMockFormatException('question ids must be unique');
        }
        questions.add(
          ServerMockQuestion(
            id: id,
            setId: _string(entry, 'setId', empty: true),
          ),
        );
      }
      sections.add(
        ServerMockSection(
          sectionId: _string(section, 'sectionId'),
          name: _string(section, 'name', empty: true),
          questions: List.unmodifiable(questions),
        ),
      );
    }
    if (seen.length > maxAnswers) {
      throw const ServerMockFormatException('the paper is too long to save');
    }
    final answersRaw = map['answers'];
    if (answersRaw is! List) {
      throw const ServerMockFormatException('answers must be a list');
    }
    final answers = <String, ServerMockAnswer>{};
    for (final value in answersRaw) {
      final entry = _map(value, 'answer');
      final questionId = _string(entry, 'questionId');
      final chosen = entry['chosen'];
      if (!seen.contains(questionId) ||
          answers.containsKey(questionId) ||
          (chosen != null && (chosen is! String || chosen.length > 64)) ||
          entry['correct'] is! bool) {
        throw const ServerMockFormatException('an answer does not fit');
      }
      answers[questionId] = ServerMockAnswer(
        questionId: questionId,
        chosen: chosen as String?,
        correct: entry['correct']! as bool,
        answeredAt: _wholeNumber(entry, 'answeredAt'),
      );
    }
    final strict = map['strict'];
    final paused = map['paused'];
    if (strict is! bool || paused is! bool) {
      throw const ServerMockFormatException('strict and paused are flags');
    }
    return ServerMockPaper._(
      mockId: mockId,
      examId: _string(map, 'examId'),
      startedAt: _wholeNumber(map, 'startedAt'),
      strict: strict,
      limit: Duration(milliseconds: limitMs),
      remaining: Duration(milliseconds: remainingMs),
      paused: paused,
      sections: List.unmodifiable(sections),
      answers: Map.unmodifiable(answers),
    );
  }

  /// The most answers one save or submission can carry.
  static const maxAnswers = 300;

  static final _mockIdPattern = RegExp(r'^[A-Za-z0-9]{10,40}$');

  final String mockId;
  final String examId;

  /// Milliseconds since the epoch, on the server's clock.
  final int startedAt;
  final bool strict;
  final Duration limit;
  final Duration remaining;
  final bool paused;
  final List<ServerMockSection> sections;
  final Map<String, ServerMockAnswer> answers;

  List<String> get questionIds => [
        for (final section in sections)
          for (final question in section.questions) question.id,
      ];

  String? sectionNameOf(String questionId) {
    for (final section in sections) {
      if (section.questions.any((q) => q.id == questionId)) {
        return section.name;
      }
    }
    return null;
  }

  static Map<String, Object?> _map(Object? value, String what) {
    if (value is! Map) {
      throw ServerMockFormatException('$what is not an object');
    }
    return value.cast<String, Object?>();
  }

  static String _string(
    Map<String, Object?> map,
    String key, {
    bool empty = false,
  }) {
    final value = map[key];
    if (value is! String || (!empty && value.isEmpty)) {
      throw ServerMockFormatException('$key must be text');
    }
    return value;
  }

  /// Dart reads a JSON whole number as an int on the VM and as a double on
  /// the web, so a whole double is a whole number.
  static int _wholeNumber(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is int) return value;
    if (value is double &&
        value.isFinite &&
        value == value.truncateToDouble()) {
      return value.toInt();
    }
    throw ServerMockFormatException('$key must be a whole number');
  }
}
