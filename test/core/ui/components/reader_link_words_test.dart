// Which words of a passage name a part of the figure beside it. Spec:
// "Linked words".
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/reader_link_words.dart';

Map<String, Object?> run(String text, {List<String> marks = const []}) =>
    {'text': text, 'marks': marks};

void main() {
  group('the core of a label', () {
    test('is the text before " = " or ":"', () {
      expect(labelCore('r = 7 cm'), 'r');
      expect(labelCore('Central: 80°'), 'Central');
      expect(labelCore('Arc = 80°'), 'Arc');
    });

    test('drops "Center " and "Point "', () {
      expect(labelCore('Center O'), 'O');
      expect(labelCore('Point T'), 'T');
    });

    test('keeps a plain label whole', () {
      expect(labelCore('Tangent'), 'Tangent');
      expect(labelCore('Diameter AB = 10'), 'Diameter AB');
    });
  });

  group('matching', () {
    test('a long label matches a bold word, whole word, any case', () {
      final links = findLinks(
        [
          run('tangent', marks: ['strong']),
          run(': a line that touches the circle.'),
        ],
        ['Tangent', 'Radius'],
      );
      expect(links, hasLength(1));
      expect(links.single.run, 0);
      expect(links.single.label, 'Tangent');
      expect(links.single.start, 0);
      expect(links.single.end, 7);
    });

    test('a long label does not match plain text', () {
      expect(
        findLinks([run('A tangent line.')], ['Tangent']),
        isEmpty,
      );
    });

    test('a long label matches a word inside a longer bold run', () {
      final links = findLinks(
        [
          run('central angle', marks: ['strong'])
        ],
        ['Central'],
      );
      expect(links.single.start, 0);
      expect(links.single.end, 7);
    });

    test('a short label matches only inside math', () {
      final math = findLinks(
        [
          run('AB', marks: ['latex'])
        ],
        ['AB', 'C'],
      );
      expect(math.single.label, 'AB');
      expect(findLinks([run('AB')], ['AB']), isEmpty);
      expect(
          findLinks([
            run('AB', marks: ['strong'])
          ], [
            'AB'
          ]),
          isEmpty);
    });

    test('math matches by what it says, not a part of it', () {
      expect(
          findLinks([
            run('ABC', marks: ['latex'])
          ], [
            'AB'
          ]),
          isEmpty);
      expect(
        findLinks([
          run(r'\overline{AB}', marks: ['latex'])
        ], [
          'AB'
        ]),
        isNotEmpty,
      );
    });

    test('only the first mention of a label is linked', () {
      final links = findLinks(
        [
          run('Radius', marks: ['strong']),
          run(' and '),
          run('radius', marks: ['strong']),
        ],
        ['Radius'],
      );
      expect(links, hasLength(1));
      expect(links.single.run, 0);
    });

    test('a label that is a number or empty matches nothing', () {
      expect(
          findLinks([
            run('x', marks: ['latex'])
          ], [
            '',
            '90°'
          ]),
          isEmpty);
    });
  });
}
