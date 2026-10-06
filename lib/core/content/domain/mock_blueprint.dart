// meta, not flutter/foundation: the seed writer and the importer are
// plain Dart command line tools and cannot load dart:ui.
import 'package:meta/meta.dart';

/// How the testing body times this exam's parts.
///
/// `null` means unpublished, and it is a real state: ACET, DCAT and
/// MSU-SASE publish nothing. It is never defaulted to either value,
/// because guessing wrong about whether a student can go back is the most
/// expensive wrong guess this app can make.
enum SectionalTiming { sectional, roamable }

/// Where the blueprint's figures came from.
enum BlueprintSource { published, reported, unknown }

/// A section figure and its field-level source status. Section JSON keeps
/// the wrapper intact so callers can show the development placeholder label.
@immutable
class BlueprintValue {
  const BlueprintValue({
    required this.value,
    this.isPlaceholder = false,
    this.placeholderNote,
  });

  factory BlueprintValue.fromJson(Object? raw) {
    if (raw is int) return BlueprintValue(value: raw);
    if (raw is! Map || raw['value'] is! int) {
      throw const FormatException('blueprint value must be an integer');
    }
    final placeholder = raw['placeholder'] ?? false;
    final note = raw['placeholderNote'];
    if (placeholder is! bool || (note != null && note is! String)) {
      throw const FormatException('invalid blueprint placeholder metadata');
    }
    if (placeholder && (note == null || (note as String).trim().isEmpty)) {
      throw const FormatException('blueprint placeholder needs a note');
    }
    return BlueprintValue(
      value: raw['value'] as int,
      isPlaceholder: placeholder,
      placeholderNote: note as String?,
    );
  }

  final int value;
  final bool isPlaceholder;
  final String? placeholderNote;

  static void validateSections(Iterable<Object?> sections) {
    for (final section in sections) {
      if (section is! Map) {
        throw const FormatException('blueprint section must be an object');
      }
      for (final field in ['questionCount', 'sectionalMinutes']) {
        if (section[field] != null) {
          BlueprintValue.fromJson(section[field]);
        }
      }
    }
  }
}

/// The percentage at which this exam calls a score a pass, and the one
/// above which it is close. Content, per exam. `null` means the exam has
/// not published them.
@immutable
class ScoreBands {
  const ScoreBands({required this.passAtPercent, required this.closeAtPercent});

  final int passAtPercent;
  final int closeAtPercent;

  @override
  bool operator ==(Object other) =>
      other is ScoreBands &&
      other.passAtPercent == passAtPercent &&
      other.closeAtPercent == closeAtPercent;

  @override
  int get hashCode => Object.hash(passAtPercent, closeAtPercent);
}

class MockBlueprint {
  const MockBlueprint({
    required this.id,
    required this.examId,
    required this.name,
    required this.durationMinutes,
    required this.sectionsJson,
    this.sectionalTiming,
    this.scoreBands,
    this.totalPublishedItems,
    this.source,
    this.sourceNote,
  });

  final String id;
  final String examId;
  final String name;
  final int durationMinutes;
  final String sectionsJson;

  /// Null means the testing body has not published how it times the parts.
  final SectionalTiming? sectionalTiming;

  /// Null means the exam has not published its thresholds.
  final ScoreBands? scoreBands;

  /// Every item the real exam contains, including the ones this app has no
  /// concept of: ACET's essay, DCAT's essay and personality test. When it
  /// exceeds what the sections cover, the setup screen says what is not
  /// included. Null means the exam publishes no total.
  final int? totalPublishedItems;

  /// Where the blueprint's numbers came from.
  final BlueprintSource? source;

  /// Citation or attribution note for the blueprint source.
  final String? sourceNote;
}
