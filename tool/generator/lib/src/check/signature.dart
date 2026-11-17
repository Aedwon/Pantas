import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../model.dart';
import 'cube_net_signature.dart';
import 'matrix_signature.dart';
import 'series_signature.dart';
import 'shape_row_signature.dart';

Object? _sorted(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: _sorted(value[key])};
  }
  if (value is List) return value.map(_sorted).toList();
  return value;
}

String dataKey(Object? value) => jsonEncode(_sorted(value));

typedef FigureCanonicalizer = Object Function(Variant variant);

/// Task 1.3 registers each production kind here. Unknown kinds fail closed.
final figureCanonicalizers = <String, FigureCanonicalizer>{
  'generic-test': _generic,
  'figure-series': canonicalSeries,
  'figure-matrix': canonicalMatrix,
  'shape-row': canonicalShapeRow,
  'cube-net': canonicalCubeNet,
};

// Wording slots are not numbers. Normalize exact rational strings so 2/2
// and 1 cannot disguise a repeated number set.
Object? _numbers(Object? value) {
  if (value is Map<String, Object?>) {
    return <String, Object?>{
      for (final entry in value.entries)
        if (_numbers(entry.value) != null) entry.key: _numbers(entry.value),
    };
  }
  if (value is List) {
    return value.map(_numbers).where((v) => v != null).toList();
  }
  if (value is int) return Rational.parse('$value').toString();
  if (value is num) return value.toString();
  if (value is String && RegExp(r'^-?[0-9]+(?:/-?[0-9]+)?$').hasMatch(value)) {
    return Rational.parse(value).toString();
  }
  return null;
}

/// Per-kind fields excluded before whole-question canonicalization.
final signatureIgnore = <String, List<String>>{};

String canonicalSignature(
  Variant variant, {
  Map<String, List<String>>? ignore,
}) {
  final figure = variant.figureSpec;
  Object? canonical;
  if (figure == null) {
    canonical = _numbers(variant.slots);
  } else {
    final kind = figure['kind'];
    final canonicalizer = figureCanonicalizers[kind];
    if (canonicalizer == null) {
      throw FormatException('no canonicalizer for kind $kind');
    }
    final ignored = (ignore ?? signatureIgnore)[kind] ?? const <String>[];
    Object? strip(Object? value) {
      if (value is Map<String, Object?>) {
        return <String, Object?>{
          for (final entry in value.entries)
            if (!ignored.contains(entry.key)) entry.key: strip(entry.value),
        };
      }
      if (value is List) return value.map(strip).toList();
      return value;
    }

    final filtered = parseVariants({
      'variants': [
        strip(variant.toMap()),
      ],
    }).single;
    canonical = canonicalizer(filtered);
  }
  return sha256.convert(utf8.encode(dataKey(canonical))).toString();
}

/// Generic test kind: nested Cartesian points. Transform the shown data and
/// every candidate together; words and slot labels do not define a figure.
Object _generic(Variant variant) {
  Object? transform(Object? data, int turns, {required bool mirror}) {
    if (data is List) {
      return data.map((v) => transform(v, turns, mirror: mirror)).toList();
    }
    if (data is! Map) return data;
    final result = <String, Object?>{
      for (final key in data.keys.cast<String>())
        key: transform(data[key], turns, mirror: mirror),
    };
    if (data['x'] is num && data['y'] is num) {
      var x = data['x']! as num;
      var y = data['y']! as num;
      if (mirror) x = -x;
      for (var i = 0; i < turns; i++) {
        final oldX = x;
        x = -y;
        y = oldX;
      }
      result['x'] = x == 0 ? 0 : x;
      result['y'] = y == 0 ? 0 : y;
    }
    return result;
  }

  final keys = <String>[];
  for (final mirror in [false, true]) {
    for (var turns = 0; turns < 4; turns++) {
      final choices = variant.choices
          .map((c) => dataKey(transform(c.figure, turns, mirror: mirror)))
          .toList()
        ..sort();
      keys.add(
        dataKey({
          'shown': transform(variant.figureSpec, turns, mirror: mirror),
          'choices': choices,
        }),
      );
    }
  }
  return (keys..sort()).first;
}
