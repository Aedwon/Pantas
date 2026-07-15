import 'dart:convert';

class BlueprintParseException implements Exception {
  const BlueprintParseException(this.message);

  final String message;

  @override
  String toString() => 'BlueprintParseException: $message';
}

class BlueprintSection {
  const BlueprintSection({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.suggestedMinutes,
    required this.topicIds,
    required this.topicWeights,
    this.sectionalMinutes,
  });

  final String id;
  final String name;
  final int questionCount;
  final int suggestedMinutes;
  final List<String> topicIds;
  final Map<String, double> topicWeights;

  /// The per-part limit, meaningful only when the exam times its parts
  /// separately. Null otherwise, and null when the body publishes none.
  final int? sectionalMinutes;

  // ignore: prefer_constructors_over_static_methods
  static List<BlueprintSection> parseList(String sectionsJson) {
    final Object? decoded;
    try {
      decoded = jsonDecode(sectionsJson);
    } on FormatException catch (error) {
      throw BlueprintParseException('Invalid sectionsJson: ${error.message}');
    }

    if (decoded is! List) {
      throw const BlueprintParseException('sectionsJson must be a list');
    }

    return [
      for (var i = 0; i < decoded.length; i++)
        _parseSection(decoded[i], index: i),
    ];
  }

  // ignore: prefer_constructors_over_static_methods
  static BlueprintSection _parseSection(Object? value, {required int index}) {
    if (value is! Map<String, Object?>) {
      throw BlueprintParseException('section[$index] must be an object');
    }

    final id = _readString(value, 'id', index);
    final name = _readString(value, 'name', index);
    final questionCount = _readPositiveInt(value, 'questionCount', index);
    final suggestedMinutes = _readPositiveInt(
      value,
      'suggestedMinutes',
      index,
    );
    final topicIds = _readStringList(value, 'topicIds', index);
    final topicWeights = _readWeights(value, topicIds, index);

    return BlueprintSection(
      id: id,
      name: name,
      questionCount: questionCount,
      suggestedMinutes: suggestedMinutes,
      topicIds: List.unmodifiable(topicIds),
      topicWeights: Map.unmodifiable(topicWeights),
      sectionalMinutes: _readOptionalPositiveInt(value, 'sectionalMinutes'),
    );
  }

  /// Absent, zero and rubbish all read as "not published".
  static int? _readOptionalPositiveInt(Map<String, Object?> value, String key) {
    final raw = value[key];
    if (raw is int && raw > 0) return raw;
    return null;
  }

  static String _readString(
    Map<String, Object?> value,
    String key,
    int index,
  ) {
    final raw = value[key];
    if (raw is String && raw.trim().isNotEmpty) return raw;
    throw BlueprintParseException('section[$index].$key must be a string');
  }

  static int _readPositiveInt(
    Map<String, Object?> value,
    String key,
    int index,
  ) {
    final raw = value[key];
    if (raw is int && raw > 0) return raw;
    throw BlueprintParseException('section[$index].$key must be positive');
  }

  static List<String> _readStringList(
    Map<String, Object?> value,
    String key,
    int index,
  ) {
    final raw = value[key];
    if (raw is! List || raw.isEmpty) {
      throw BlueprintParseException('section[$index].$key must be a list');
    }
    final strings = <String>[];
    for (final item in raw) {
      if (item is! String || item.trim().isEmpty) {
        throw BlueprintParseException(
          'section[$index].$key must contain strings',
        );
      }
      strings.add(item);
    }
    return strings;
  }

  static Map<String, double> _readWeights(
    Map<String, Object?> value,
    List<String> topicIds,
    int index,
  ) {
    final raw = value['topicWeights'];
    if (raw == null) {
      return {for (final topicId in topicIds) topicId: 1};
    }
    if (raw is! Map<String, Object?>) {
      throw BlueprintParseException(
        'section[$index].topicWeights must be an object',
      );
    }

    final weights = <String, double>{};
    for (final topicId in topicIds) {
      final weight = raw[topicId];
      if (weight is num && weight > 0) {
        weights[topicId] = weight.toDouble();
      } else {
        throw BlueprintParseException(
          'section[$index].topicWeights.$topicId must be positive',
        );
      }
    }
    return weights;
  }
}
