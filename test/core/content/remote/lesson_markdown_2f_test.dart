import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/lesson_markdown.dart';

import '../../../../tools/content/lesson_asset_map.dart';
import '../../../../tools/content/markdown_portable_text.dart';

// QA 2F-11, 2F-14 and 2F-15: a list item keeps its source number, and display
// math written over several lines is one formula. Both parsers must agree, so
// each case runs on the runtime parser and on the bundled build.

void main() {
  final parsers = <String, List<Map<String, Object?>> Function(String)>{
    'runtime': lessonBlocksFromMarkdown,
    'bundled build': (body) => markdownToPortableText(
          body,
          lesson: LessonIdentity.fromPath(
            'content/lessons/mathematics/algebra/linear-equations.md',
          ),
          assets: const LessonAssetMap.unconfigured(),
        ),
  };

  for (final entry in parsers.entries) {
    final parse = entry.value;
    group(entry.key, () {
      test('a list item keeps the number it is written with', () {
        final blocks = parse(
          [
            '1. For the first:',
            '',
            'So the first is 3.',
            '',
            '2. For the second:',
            '10. Tenth.',
            '3) not a list item',
          ].join('\n'),
        );
        expect(
          [
            for (final block in blocks)
              if (block['listItem'] == 'number') block['listNumber'],
          ],
          [1, 2, 10],
        );
        // The text is what follows "2. ", not the number.
        final second = blocks.firstWhere((b) => b['listNumber'] == 2);
        expect(
          ((second['children']! as List).first as Map)['text'],
          'For the second:',
        );
      });

      test('a number too long to be a list number is not kept', () {
        final blocks = parse('1234567890. A year-like start.');
        expect(blocks.single['listItem'], 'number');
        expect(blocks.single.containsKey('listNumber'), isFalse);
      });

      test(r'$$ over three lines is one formula', () {
        final blocks = parse(
          [
            'Compare:',
            r'$$',
            '0389 < 0395 < 0401',
            r'$$',
            'Done.',
          ].join('\n'),
        );
        expect(
          blocks.map((block) => block['_type']),
          ['block', 'latex', 'block'],
        );
        expect(blocks[1]['body'], '0389 < 0395 < 0401');
      });

      test('a formula may open or close on a line with its text', () {
        final blocks = parse(
          [
            r'$$x = \dfrac{1}{2}',
            r'+ y$$',
            '',
            r'$$ a=b',
            'c=d',
            r'$$',
          ].join('\n'),
        );
        expect(blocks.map((block) => block['_type']), ['latex', 'latex']);
        expect(blocks[0]['body'], r'x = \dfrac{1}{2} + y');
        expect(blocks[1]['body'], 'a=b c=d');
      });

      test(r'a $$ with no close before a blank line stays a paragraph', () {
        final open = parse([r'$$', 'x = 1', '', 'After.'].join('\n'));
        expect(open.map((block) => block['_type']), ['block', 'block']);
        final empty = parse([r'$$', r'$$'].join('\n'));
        expect(empty.every((block) => block['_type'] == 'block'), isTrue);
      });

      test('a list with a formula on three lines keeps its numbers', () {
        final blocks = parse(
          [
            '1. Take two thirds of the House.',
            '',
            r'$$',
            r'\dfrac{2}{3}\times300=200',
            r'$$',
            '',
            '2. Take two thirds of the Senate.',
          ].join('\n'),
        );
        expect(
          blocks.map((block) => block['_type']),
          ['block', 'latex', 'block'],
        );
        expect(blocks[2]['listNumber'], 2);
      });
    });
  }
}
