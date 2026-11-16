import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// JSON-compatible, deeply immutable data shared by the offline tools.
Map<String, Object?> _map(Object? value) {
  if (value is! Map) throw const FormatException('Expected a map');
  return Map.unmodifiable(
    value.map((Object? key, Object? value) {
      if (key is! String) throw const FormatException('Expected string keys');
      return MapEntry(key, _freeze(value));
    }),
  );
}

Object? _freeze(Object? value) {
  if (value is Map) return _map(value);
  if (value is List) return List<Object?>.unmodifiable(value.map(_freeze));
  if (value == null || value is String || value is bool || value is num) {
    return value;
  }
  throw const FormatException('Expected YAML data');
}

String _string(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('Expected nonempty string: $key');
  }
  return value;
}

int _integer(Map<String, Object?> data, String key, {int minimum = 0}) {
  final value = data[key];
  if (value is! int || value < minimum) {
    throw FormatException('Expected integer >= $minimum: $key');
  }
  return value;
}

List<Object?> _list(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! List) throw FormatException('Expected list: $key');
  return value.cast<Object?>();
}

/// Value semantics preserve nested slot and figure data.
@immutable
abstract class _DataValue {
  _DataValue(Map<String, Object?> data) : _data = _map(data);
  final Map<String, Object?> _data;
  Map<String, Object?> toMap() => Map.of(_data);
  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is _DataValue &&
      const DeepCollectionEquality().equals(_data, other._data);
  @override
  int get hashCode => const DeepCollectionEquality().hash(_data);
}

class Mistake extends _DataValue {
  Mistake._(super.data);
  String get id => _string(_data, 'id');
  String get note => _string(_data, 'note');
}

class MergedQuestion extends _DataValue {
  MergedQuestion._(super.data);
  String get id => _string(_data, 'id');
  int get index => _integer(_data, 'index');
}

class ProblemType extends _DataValue {
  ProblemType._(super.data);
  String get id => _string(_data, 'id');
  String get lesson => _string(_data, 'lesson');
  int get keyPoint => _integer(_data, 'keyPoint', minimum: 1);
  String get difficulty => _string(_data, 'difficulty');
  List<String> get exams =>
      List.unmodifiable(_list(_data, 'exams').cast<String>());
  String get format => _string(_data, 'format');
  String get rule => _string(_data, 'rule');
  int get ruleVersion => _integer(_data, 'ruleVersion', minimum: 1);
  int get choiceCount => _integer(_data, 'choiceCount', minimum: 1);
  bool get enabled => _data['enabled']! as bool;
  Map<String, Object?> get params => _data['params']! as Map<String, Object?>;
  String get stem => _string(_data, 'stem');
  String get explanation => _string(_data, 'explanation');
  List<Mistake> get mistakes => List.unmodifiable(
        _list(_data, 'mistakes').map((v) => Mistake._(_map(v))),
      );
  List<MergedQuestion> get mergedQuestions => List.unmodifiable(
        _list(_data, 'mergedQuestions').map((v) => MergedQuestion._(_map(v))),
      );
}

// Map is the agreed public parser boundary, including YamlMap.
// ignore: strict_raw_type
ProblemType parseProblemType(Map input) {
  final data = _map(input);
  final type = ProblemType._(data);
  for (final key in [
    'id',
    'lesson',
    'difficulty',
    'format',
    'rule',
    'stem',
    'explanation',
  ]) {
    _string(data, key);
  }
  for (final key in ['keyPoint', 'ruleVersion', 'choiceCount']) {
    _integer(data, key, minimum: 1);
  }
  if (data['enabled'] is! bool) {
    throw const FormatException('Expected enabled bool');
  }
  _map(data['params']);
  if (_list(data, 'exams').any((v) => v is! String)) {
    throw const FormatException('Expected exam strings');
  }
  final mistakes = <String>{};
  for (final m in type.mistakes) {
    if (!mistakes.add(m.id)) throw const FormatException('Duplicate mistake');
    m.note;
  }
  final ids = <String>{};
  final indexes = <int>{};
  for (final m in type.mergedQuestions) {
    if (!ids.add(m.id) || !indexes.add(m.index)) {
      throw const FormatException('Duplicate merged id or index');
    }
  }
  return type;
}

class VariantChoice extends _DataValue {
  VariantChoice._(super.data);
  bool get correct => _data['correct'] == true;
  String? get mistake => _data['mistake'] as String?;
  String get text => _string(_data, 'text');
  String? get value => _data['value'] as String?;
  Map<String, Object?>? get figure => _data['figure'] as Map<String, Object?>?;
  Map<String, Object?> get slots =>
      _data['slots'] as Map<String, Object?>? ?? const {};
}

class Variant extends _DataValue {
  Variant._(super.data);
  int get index => _integer(_data, 'index');
  String? get source => _data['source'] as String?;
  Map<String, Object?> get slots => _data['slots']! as Map<String, Object?>;
  Map<String, Object?>? get figureSpec =>
      _data['figureSpec'] as Map<String, Object?>?;
  List<VariantChoice> get choices => List.unmodifiable(
        _list(_data, 'choices').map((v) => VariantChoice._(_map(v))),
      );
  String get signature => _string(_data, 'signature');
}

// ignore: strict_raw_type
List<Variant> parseVariants(Map input) {
  return List.unmodifiable(
    _list(_map(input), 'variants').map((value) {
      final v = Variant._(_map(value))
        ..index
        ..signature;
      _map(v._data['slots']);
      if (v._data.containsKey('source')) _string(v._data, 'source');
      if (v._data.containsKey('figureSpec')) _map(v._data['figureSpec']);
      for (final c in v.choices) {
        c.text;
        if (c._data.containsKey('correct') && c._data['correct'] is! bool) {
          throw const FormatException('Expected correct bool');
        }
        for (final key in ['mistake', 'value']) {
          if (c._data.containsKey(key)) _string(c._data, key);
        }
        for (final key in ['figure', 'slots']) {
          if (c._data.containsKey(key)) _map(c._data[key]);
        }
      }
      return v;
    }),
  );
}

class VariantList extends _DataValue {
  VariantList._(super.data);
  String get problemType => _string(_data, 'problemType');
  Map<String, Object?> get _generator =>
      _data['generator']! as Map<String, Object?>;
  int get tool => _integer(_generator, 'tool', minimum: 1);
  int get ruleVersion => _integer(_generator, 'ruleVersion', minimum: 1);
  int get seed => _integer(_generator, 'seed');
  List<Variant> get variants => parseVariants(_data);
}

// ignore: strict_raw_type
VariantList parseVariantList(Map input) {
  final doc = VariantList._(_map(input))
    ..problemType
    ..tool
    ..ruleVersion
    ..seed
    ..variants;
  return doc;
}

Object? _sorted(Object? value) {
  if (value is Map<String, Object?>) {
    final keys = value.keys.toList()..sort();
    return {for (final key in keys) key: _sorted(value[key])};
  }
  if (value is List) return value.map(_sorted).toList();
  return value;
}

/// JSON flow objects are valid YAML and escape quotes, newlines and LaTeX.
/// One variant per line keeps existing indexes byte-identical on refill.
String writeVariantList(VariantList doc) {
  final variants = doc.variants;
  final buffer = StringBuffer()
    ..writeln('problemType: ${jsonEncode(doc.problemType)}')
    ..writeln('generator: ${jsonEncode(_sorted(doc._generator))}')
    ..writeln(variants.isEmpty ? 'variants: []' : 'variants:');
  for (final variant in variants) {
    buffer.writeln('  - ${jsonEncode(_sorted(variant.toMap()))}');
  }
  return buffer.toString();
}

/// Normalized exact arithmetic, including values beyond machine integer limits.
@immutable
class Rational {
  factory Rational(BigInt numerator, [BigInt? denominator]) {
    final d = denominator ?? BigInt.one;
    if (d == BigInt.zero) throw ArgumentError('Zero denominator');
    final gcd = numerator.gcd(d);
    final sign = d.isNegative ? -BigInt.one : BigInt.one;
    return Rational._(numerator ~/ gcd * sign, d ~/ gcd * sign);
  }
  const Rational._(this.numerator, this.denominator);
  factory Rational.parse(String text) {
    if (!RegExp(r'^-?[0-9]+(?:/-?[0-9]+)?$').hasMatch(text)) {
      throw FormatException('Expected integer or fraction', text);
    }
    final parts = text.split('/');
    final n = BigInt.parse(parts.first);
    final d = parts.length == 1 ? BigInt.one : BigInt.parse(parts.last);
    if (d == BigInt.zero) throw const FormatException('Zero denominator');
    return Rational(n, d);
  }
  final BigInt numerator;
  final BigInt denominator;
  Rational operator +(Rational b) => Rational(
        numerator * b.denominator + b.numerator * denominator,
        denominator * b.denominator,
      );
  Rational operator -(Rational b) => Rational(
        numerator * b.denominator - b.numerator * denominator,
        denominator * b.denominator,
      );
  Rational operator *(Rational b) =>
      Rational(numerator * b.numerator, denominator * b.denominator);
  Rational operator /(Rational b) =>
      Rational(numerator * b.denominator, denominator * b.numerator);
  @override
  String toString() =>
      denominator == BigInt.one ? '$numerator' : '$numerator/$denominator';
  @override
  bool operator ==(Object other) =>
      other is Rational &&
      numerator == other.numerator &&
      denominator == other.denominator;
  @override
  int get hashCode => Object.hash(numerator, denominator);
}
