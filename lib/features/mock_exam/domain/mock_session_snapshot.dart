import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_sample.dart';

class MockSessionSnapshot {
  const MockSessionSnapshot({
    required this.sample,
    required this.answers,
    required this.flags,
    required this.currentPartIndex,
    required this.partStartedAtSeconds,
    required this.partsTimedSeparately,
    required this.parts,
    required this.strictBackgroundedAt,
  });

  final MockSample sample;
  final Map<String, MockAnswer> answers;
  final Set<String> flags;
  final int? currentPartIndex;
  final int partStartedAtSeconds;
  final bool? partsTimedSeparately;
  final List<MockPersistedPart>? parts;
  final DateTime? strictBackgroundedAt;
}

@immutable
class MockPersistedPart {
  const MockPersistedPart({
    required this.name,
    required this.startIndex,
    required this.count,
    required this.minutes,
  });

  final String name;
  final int startIndex;
  final int count;
  final int? minutes;

  @override
  bool operator ==(Object other) =>
      other is MockPersistedPart &&
      other.name == name &&
      other.startIndex == startIndex &&
      other.count == count &&
      other.minutes == minutes;

  @override
  int get hashCode => Object.hash(name, startIndex, count, minutes);
}

class MockSessionSnapshotCodec {
  const MockSessionSnapshotCodec();

  String encodeSample(
    MockSample sample, {
    required int currentPartIndex,
    required int partStartedAtSeconds,
    required bool partsTimedSeparately,
    required List<MockPersistedPart> parts,
    DateTime? strictBackgroundedAt,
  }) {
    return jsonEncode([
      for (var index = 0; index < sample.sections.length; index += 1)
        {
          'sectionId': sample.sections[index].sectionId,
          'name': sample.sections[index].name,
          'questionIds': sample.sections[index].questionIds,
          if (index == 0)
            '_session': {
              'currentPartIndex': currentPartIndex,
              'partStartedAtSeconds': partStartedAtSeconds,
              'partsTimedSeparately': partsTimedSeparately,
              'parts': [
                for (final part in parts)
                  {
                    'name': part.name,
                    'startIndex': part.startIndex,
                    'count': part.count,
                    'minutes': part.minutes,
                  },
              ],
              'strictBackgroundedAt':
                  strictBackgroundedAt?.millisecondsSinceEpoch,
            },
        },
    ]);
  }

  String encodeAnswers(Map<String, MockAnswer> answers) {
    return jsonEncode({
      for (final entry in answers.entries)
        entry.key: {
          'selectedIndex': entry.value.selectedIndex,
          'atSec': entry.value.atSec,
          if (entry.value.missReason != null)
            'missReason': entry.value.missReason!.name,
          if (entry.value.blankReason != null)
            'blankReason': entry.value.blankReason!.name,
          if (entry.value.reasonNote != null)
            'reasonNote': entry.value.reasonNote,
        },
    });
  }

  String encodeFlags(Set<String> flags) => jsonEncode(flags.toList()..sort());

  MockSessionSnapshot decode({
    required String sampledQuestionsJson,
    required String answersJson,
    required String flagsJson,
  }) {
    final rawSections = _list(sampledQuestionsJson, 'sampled questions');
    if (rawSections.isEmpty) {
      throw const FormatException('sampled questions must not be empty');
    }

    final sections = <SampledMockSection>[];
    int? currentPartIndex;
    var partStartedAtSeconds = 0;
    bool? partsTimedSeparately;
    List<MockPersistedPart>? parts;
    DateTime? strictBackgroundedAt;
    for (var index = 0; index < rawSections.length; index += 1) {
      final section = _map(rawSections[index], 'sampled section');
      final sectionId = section['sectionId'];
      final name = section['name'];
      final questionIds = section['questionIds'];
      if (sectionId is! String || name is! String || questionIds is! List) {
        throw const FormatException('invalid sampled section');
      }
      final ids = questionIds.whereType<String>().toList(growable: false);
      if (ids.length != questionIds.length || ids.isEmpty) {
        throw const FormatException('invalid sampled question ids');
      }
      sections.add(
        SampledMockSection(
          sectionId: sectionId,
          name: name,
          questionIds: List.unmodifiable(ids),
        ),
      );

      if (index == 0 && section['_session'] != null) {
        final session = _map(section['_session'], 'session metadata');
        final rawPartIndex = session['currentPartIndex'];
        final rawPartStart = session['partStartedAtSeconds'];
        if (rawPartIndex is! int || rawPartStart is! int || rawPartStart < 0) {
          throw const FormatException('invalid session metadata');
        }
        currentPartIndex = rawPartIndex;
        partStartedAtSeconds = rawPartStart;
        final rawTimedSeparately = session['partsTimedSeparately'];
        final rawParts = session['parts'];
        if (rawTimedSeparately != null || rawParts != null) {
          if (rawTimedSeparately is! bool || rawParts is! List) {
            throw const FormatException('invalid frozen parts');
          }
          partsTimedSeparately = rawTimedSeparately;
          parts = _decodeParts(rawParts);
        }
        final rawBackgroundedAt = session['strictBackgroundedAt'];
        if (rawBackgroundedAt != null) {
          if (rawBackgroundedAt is! int || rawBackgroundedAt < 0) {
            throw const FormatException('invalid strict background time');
          }
          strictBackgroundedAt = DateTime.fromMillisecondsSinceEpoch(
            rawBackgroundedAt,
            isUtc: true,
          );
        }
      }
    }

    final rawAnswers = _map(jsonDecode(answersJson), 'answers');
    final answers = <String, MockAnswer>{};
    for (final entry in rawAnswers.entries) {
      final answer = _map(entry.value, 'answer');
      final selectedIndex = answer['selectedIndex'];
      final atSec = answer['atSec'];
      if (selectedIndex is! int || atSec is! int) {
        throw const FormatException('invalid answer');
      }
      answers[entry.key] = MockAnswer(
        selectedIndex: selectedIndex,
        atSec: atSec,
        missReason: _reason(answer['missReason'], MissReason.values),
        blankReason: _reason(answer['blankReason'], BlankReason.values),
        reasonNote: answer['reasonNote'] as String?,
      );
    }

    final rawFlags = _list(flagsJson, 'flags');
    final flags = rawFlags.whereType<String>().toSet();
    if (flags.length != rawFlags.length) {
      throw const FormatException('invalid flags');
    }

    final questionCount = sections.fold<int>(
      0,
      (count, section) => count + section.questionIds.length,
    );
    if (parts != null &&
        (parts.fold<int>(0, (count, part) => count + part.count) !=
                questionCount ||
            (partsTimedSeparately!
                ? parts.any((part) => part.minutes == null)
                : parts.any((part) => part.minutes != null)))) {
      throw const FormatException('frozen parts do not match the sample');
    }

    return MockSessionSnapshot(
      sample: MockSample(
        sections: List.unmodifiable(sections),
        expectedQuestionCount: questionCount,
      ),
      answers: Map.unmodifiable(answers),
      flags: Set.unmodifiable(flags),
      currentPartIndex: currentPartIndex,
      partStartedAtSeconds: partStartedAtSeconds,
      partsTimedSeparately: partsTimedSeparately,
      parts: parts == null ? null : List.unmodifiable(parts),
      strictBackgroundedAt: strictBackgroundedAt,
    );
  }

  List<MockPersistedPart> _decodeParts(List<Object?> rawParts) {
    if (rawParts.isEmpty) {
      throw const FormatException('frozen parts must not be empty');
    }
    final parts = <MockPersistedPart>[];
    var expectedStart = 0;
    for (final rawPart in rawParts) {
      final part = _map(rawPart, 'frozen part');
      final name = part['name'];
      final startIndex = part['startIndex'];
      final count = part['count'];
      final minutes = part['minutes'];
      if (name is! String ||
          startIndex is! int ||
          startIndex != expectedStart ||
          count is! int ||
          count <= 0 ||
          (minutes != null && (minutes is! int || minutes <= 0))) {
        throw const FormatException('invalid frozen part');
      }
      parts.add(
        MockPersistedPart(
          name: name,
          startIndex: startIndex,
          count: count,
          minutes: minutes as int?,
        ),
      );
      expectedStart += count;
    }
    return parts;
  }

  List<Object?> _list(String raw, String label) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw FormatException('$label must be a list');
    return decoded.cast<Object?>();
  }

  T? _reason<T extends Enum>(Object? raw, List<T> values) {
    if (raw == null) return null;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    throw const FormatException('invalid review reason');
  }

  Map<String, Object?> _map(Object? raw, String label) {
    if (raw is! Map) throw FormatException('$label must be an object');
    return raw.cast<String, Object?>();
  }
}
