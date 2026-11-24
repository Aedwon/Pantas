import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/figure_classes.dart';

const _known = FigureClasses(
  wide: {'geometry-diagram/angle-gallery'},
  margin: {'geometry-diagram/circle', 'gear-train'},
);

void main() {
  test('a figure type on neither list fails', () {
    final found = findUnclassifiedFigures(
      'content/lessons/a.md',
      '<!-- FIGURE: {"kind": "geometry-diagram", "type": "new-shape", '
          '"labels": ["A"]} -->',
      _known,
    );
    expect(found.single.where, 'content/lessons/a.md');
    expect(found.single.message, contains('geometry-diagram/new-shape'));
    expect(found.single.acceptedBecause, isNull);
  });

  test('a kind with no type is named by its kind alone', () {
    expect(
      findUnclassifiedFigures(
        'a.md',
        '<!-- FIGURE: {"kind": "pulley-system"} -->',
        _known,
      ).single.message,
      contains('pulley-system'),
    );
    expect(
      findUnclassifiedFigures(
        'a.md',
        '<!-- FIGURE: {"kind": "gear-train"} -->',
        _known,
      ),
      isEmpty,
    );
  });

  test('wide and margin types pass', () {
    expect(
      findUnclassifiedFigures(
        'a.md',
        '<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle"} -->\n'
            '<!-- FIGURE: {"kind": "geometry-diagram", '
            '"type": "angle-gallery"} -->',
        _known,
      ),
      isEmpty,
    );
  });

  test('a type on both lists fails', () {
    final found = findUnclassifiedFigures(
      'a.md',
      '<!-- FIGURE: {"kind": "gear-train"} -->',
      const FigureClasses(wide: {'gear-train'}, margin: {'gear-train'}),
    );
    expect(found.single.message, contains('both'));
  });

  test('every shipped lesson figure is classified today', () {
    expect(const FigureClassesCheck().run('.'), isEmpty);
  });
}
