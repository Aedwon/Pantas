// Every figure type in a shipped lesson is on the wide list or the margin list.
//
// Nov 24 2026, T15: the held reader decided which figures go inline by name
// endings ("gallery", "triptych"), so a new figure type could miss the match
// and be squeezed into a 260 px column with no failure anywhere. The lists are
// now explicit (lib/core/ui/figures/figure_classes.dart) and this fails on a
// type that is on neither, or on both.
import 'dart:convert';
import 'dart:io';

import 'package:pantas/core/ui/figures/figure_classes.dart';

import 'check.dart';

/// The two lists, so a test can pass its own.
class FigureClasses {
  const FigureClasses({required this.wide, required this.margin});
  final Set<String> wide;
  final Set<String> margin;
}

const _shipped = FigureClasses(
  wide: wideFigureTypes,
  margin: marginFigureTypes,
);

class FigureClassesCheck extends Check {
  const FigureClassesCheck();

  @override
  String get name => 'figure-classes';

  @override
  String get origin =>
      'Nov 24 2026 T15: wide art was found by name endings, so a new figure '
      'type could be squeezed into the figure column unnoticed';

  @override
  List<Violation> run(String root) {
    final found = <Violation>[];
    for (final entity
        in Directory('$root/content/lessons').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.md')) continue;
      found.addAll(
        findUnclassifiedFigures(
          entity.path.replaceFirst('$root/', ''),
          entity.readAsStringSync(),
          _shipped,
        ),
      );
    }
    return found;
  }
}

final _marker = RegExp(r'<!--\s*FIGURE:\s*(\{.*?\})\s*-->', dotAll: true);

/// The figure types of [source] that [classes] does not place exactly once.
List<Violation> findUnclassifiedFigures(
  String path,
  String source,
  FigureClasses classes,
) {
  final seen = <String>{};
  final found = <Violation>[];
  for (final match in _marker.allMatches(source)) {
    final Object? spec;
    try {
      spec = jsonDecode(match.group(1)!);
    } on FormatException {
      continue;
    }
    if (spec is! Map<String, Object?>) continue;
    final key = figureClassKey(spec['kind'], spec['type']);
    if (!seen.add(key)) continue;
    final wide = classes.wide.contains(key);
    final margin = classes.margin.contains(key);
    if (wide && margin) {
      found.add(Violation(path, 'figure type $key is on both lists'));
    } else if (!wide && !margin) {
      found.add(
        Violation(
          path,
          'figure type $key is on neither the wide list nor the margin list '
          '(lib/core/ui/figures/figure_classes.dart)',
        ),
      );
    }
  }
  return found;
}
