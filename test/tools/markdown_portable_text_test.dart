import 'package:flutter_test/flutter_test.dart';
import '../../tools/content/lesson_asset_map.dart';
import '../../tools/content/markdown_portable_text.dart';

void main() {
  const lesson = LessonIdentity(
    path:
        'content/lessons/mathematics/algebra/linear-equations-inequalities.md',
    subject: 'mathematics',
    topic: 'algebra',
    lesson: 'linear-equations-inequalities',
  );

  group('markdownToPortableText', () {
    test(
      'parses valid FIGURE marker with inline spec and semanticsLabel',
      () {
        const markdown = '<!-- FIGURE: {"kind": "coordinate-graph", '
            '"formula": "y=x^2", '
            '"semanticsLabel": "Graph of y equals x squared"} -->';
        final blocks = markdownToPortableText(
          markdown,
          lesson: lesson,
          assets: const LessonAssetMap.empty(),
        );

        expect(blocks.length, 1);
        expect(blocks.single, {
          '_type': 'figureSpec',
          'spec': {'kind': 'coordinate-graph', 'formula': 'y=x^2'},
          'semanticsLabel': 'Graph of y equals x squared',
        });
      },
    );

    test('parses valid FIGURE marker with nested spec object', () {
      const markdown = '<!-- FIGURE: {"spec": {"kind": "coordinate-graph", '
          '"formula": "y=x^2"}, '
          '"semanticsLabel": "Graph of y equals x squared"} -->';
      final blocks = markdownToPortableText(
        markdown,
        lesson: lesson,
        assets: const LessonAssetMap.empty(),
      );

      expect(blocks.length, 1);
      expect(blocks.single, {
        '_type': 'figureSpec',
        'spec': {'kind': 'coordinate-graph', 'formula': 'y=x^2'},
        'semanticsLabel': 'Graph of y equals x squared',
      });
    });

    test(
      'throws FormatException with lesson path and line for invalid '
      'FIGURE JSON',
      () {
        const markdown = '<!-- FIGURE: {not-valid-json} -->';
        expect(
          () => markdownToPortableText(
            markdown,
            lesson: lesson,
            assets: const LessonAssetMap.empty(),
          ),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              allOf(contains(lesson.path), contains('1')),
            ),
          ),
        );
      },
    );

    test('parses a four-row truth table into table portable text block', () {
      const markdown = '''
| P | Q | P and Q |
|---|---|---|
| T | T | T |
| T | F | F |
| F | T | F |
| F | F | F |
''';
      final blocks = markdownToPortableText(
        markdown,
        lesson: lesson,
        assets: const LessonAssetMap.empty(),
      );

      expect(blocks.length, 1);
      expect(blocks.single, {
        '_type': 'table',
        'rows': [
          ['P', 'Q', 'P and Q'],
          ['T', 'T', 'T'],
          ['T', 'F', 'F'],
          ['F', 'T', 'F'],
          ['F', 'F', 'F'],
        ],
      });
    });

    test(
      'throws FormatException with lesson path and line for '
      'malformed table row',
      () {
        const markdown = '''
| P | Q | P and Q |
|---|---|---|
| T | T |
''';
        expect(
          () => markdownToPortableText(
            markdown,
            lesson: lesson,
            assets: const LessonAssetMap.empty(),
          ),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              allOf(contains(lesson.path), contains('3')),
            ),
          ),
        );
      },
    );

    test('parses display formula into latex block', () {
      const markdown = r'$$Ax + By = C$$';
      final blocks = markdownToPortableText(
        markdown,
        lesson: lesson,
        assets: const LessonAssetMap.empty(),
      );

      expect(blocks.length, 1);
      expect(blocks.single, {
        '_type': 'latex',
        'body': 'Ax + By = C',
      });
    });

    test('resolves image marker by lesson and sequence', () {
      const bioLesson = LessonIdentity(
        path: 'content/lessons/science/biology/cell-biology.md',
        subject: 'science',
        topic: 'biology',
        lesson: 'cell-biology',
      );

      final assets = LessonAssetMap.fromMap({
        'science/biology/cell-biology#1': {
          'url': 'https://cdn.sanity.io/images/cell.png',
          'alt': 'Animal cell diagram',
        },
      });

      const markdown = '''
Intro text.

<!-- ILLUSTRATION: cell organelles diagram -->

Conclusion text.
''';

      final blocks = markdownToPortableText(
        markdown,
        lesson: bioLesson,
        assets: assets,
      );

      expect(blocks.length, 3);
      expect(blocks[0]['_type'], 'block');
      expect(blocks[1], {
        '_type': 'image',
        'asset': {'url': 'https://cdn.sanity.io/images/cell.png'},
        'alt': 'Animal cell diagram',
      });
      expect(blocks[2]['_type'], 'block');
    });

    test(
      'throws FormatException with lesson path and line for '
      'unresolved image marker',
      () {
        const markdown = '<!-- ILLUSTRATION: missing diagram -->';
        expect(
          () => markdownToPortableText(
            markdown,
            lesson: lesson,
            assets: const LessonAssetMap.empty(),
          ),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              allOf(
                contains(lesson.path),
                contains('1'),
                contains(lesson.assetKey(1)),
              ),
            ),
          ),
        );
      },
    );

    test(
      'preserves existing markdown structures: headings, lists, quotes, '
      'inline math',
      () {
        const markdown = r'''
# Heading 1
## Heading 2

> A blockquote line
> second quote line

Paragraph with $x^2$, **bold**, and *italic* text.

- Item 1
- Item 2
  - Subitem 2a

1. First
2. Second
''';
        final blocks = markdownToPortableText(
          markdown,
          lesson: lesson,
          assets: const LessonAssetMap.empty(),
        );

        expect(blocks.length, 9);
        expect(blocks[0], {
          '_type': 'block',
          'style': 'h1',
          'children': [
            {'_type': 'span', 'text': 'Heading 1', 'marks': <String>[]},
          ],
        });
        expect(blocks[1], {
          '_type': 'block',
          'style': 'h2',
          'children': [
            {'_type': 'span', 'text': 'Heading 2', 'marks': <String>[]},
          ],
        });
        expect(blocks[2], {
          '_type': 'block',
          'style': 'blockquote',
          'children': [
            {
              '_type': 'span',
              'text': 'A blockquote line second quote line',
              'marks': <String>[],
            },
          ],
        });
        expect(blocks[3]['_type'], 'block');
        expect(blocks[3]['style'], 'normal');
        final rawChildren = blocks[3]['children']! as List;
        final spans = rawChildren.cast<Map<String, dynamic>>();
        expect(
          spans.any(
            (s) => s['text'] == 'x^2' && (s['marks'] as List).contains('latex'),
          ),
          isTrue,
        );
        expect(
          spans.any(
            (s) =>
                s['text'] == 'bold' && (s['marks'] as List).contains('strong'),
          ),
          isTrue,
        );
        expect(
          spans.any(
            (s) => s['text'] == 'italic' && (s['marks'] as List).contains('em'),
          ),
          isTrue,
        );

        // Bullet items
        expect(blocks[4]['listItem'], 'bullet');
        expect(blocks[4]['level'], 1);
        expect(blocks[5]['listItem'], 'bullet');
        expect(blocks[5]['level'], 1);
        expect(blocks[6]['listItem'], 'bullet');
        expect(blocks[6]['level'], 2);

        // Numbered items
        expect(blocks[7]['listItem'], 'number');
        expect(blocks[7]['level'], 1);
        expect(blocks[8]['listItem'], 'number');
        expect(blocks[8]['level'], 1);
      },
    );

    test('ignores non-figure and non-illustration HTML comments', () {
      const markdown = '''
Paragraph before.
<!-- regular html comment -->
Paragraph after.
''';
      final blocks = markdownToPortableText(
        markdown,
        lesson: lesson,
        assets: const LessonAssetMap.empty(),
      );

      expect(blocks.length, 2);
      final raw0 = blocks[0]['children']! as List;
      final raw1 = blocks[1]['children']! as List;
      final children0 = raw0.cast<Map<String, dynamic>>();
      final children1 = raw1.cast<Map<String, dynamic>>();
      expect(children0[0]['text'], 'Paragraph before.');
      expect(children1[0]['text'], 'Paragraph after.');
    });

    test(
      'resolves sparse image markers in numeric order of keys '
      '(e.g. keys #2 and #4)',
      () {
        const gravityLesson = LessonIdentity(
          path: 'content/lessons/science/physics/gravity-and-keplers-laws.md',
          subject: 'science',
          topic: 'physics',
          lesson: 'gravity-and-keplers-laws',
        );

        final assets = LessonAssetMap.fromMap({
          'science/physics/gravity-and-keplers-laws#2': {
            'url': 'https://cdn.sanity.io/images/gravity_2.png',
            'alt': 'Kepler first law orbit',
          },
          'science/physics/gravity-and-keplers-laws#4': {
            'url': 'https://cdn.sanity.io/images/gravity_4.png',
            'alt': 'Kepler third law period-distance graph',
          },
        });

        const markdown = '''
Intro text for Kepler.

<!-- ILLUSTRATION: Elliptical orbit diagram -->

Middle text describing the laws.

<!-- ILLUSTRATION: Harmonic law chart -->

Conclusion text.
''';

        final blocks = markdownToPortableText(
          markdown,
          lesson: gravityLesson,
          assets: assets,
        );

        expect(blocks.length, 5);
        expect(blocks[0]['_type'], 'block');
        expect(blocks[1], {
          '_type': 'image',
          'asset': {'url': 'https://cdn.sanity.io/images/gravity_2.png'},
          'alt': 'Kepler first law orbit',
        });
        expect(blocks[2]['_type'], 'block');
        expect(blocks[3], {
          '_type': 'image',
          'asset': {'url': 'https://cdn.sanity.io/images/gravity_4.png'},
          'alt': 'Kepler third law period-distance graph',
        });
        expect(blocks[4]['_type'], 'block');
      },
    );

    test(
      'throws FormatException with lesson path and line when markers exceed '
      'available sparse keys',
      () {
        const gravityLesson = LessonIdentity(
          path: 'content/lessons/science/physics/gravity-and-keplers-laws.md',
          subject: 'science',
          topic: 'physics',
          lesson: 'gravity-and-keplers-laws',
        );

        final assets = LessonAssetMap.fromMap({
          'science/physics/gravity-and-keplers-laws#2': {
            'url': 'https://cdn.sanity.io/images/gravity_2.png',
            'alt': 'Kepler first law orbit',
          },
          'science/physics/gravity-and-keplers-laws#4': {
            'url': 'https://cdn.sanity.io/images/gravity_4.png',
            'alt': 'Kepler third law period-distance graph',
          },
        });

        const markdown = '''
<!-- ILLUSTRATION: Marker 1 -->
<!-- ILLUSTRATION: Marker 2 -->
<!-- ILLUSTRATION: Marker 3 -->
''';

        expect(
          () => markdownToPortableText(
            markdown,
            lesson: gravityLesson,
            assets: assets,
          ),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              allOf(
                contains(gravityLesson.path),
                contains('3'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'unconfigured or disabled LessonAssetMap ignores ILLUSTRATION '
      'markers and preserves text',
      () {
        const markdown = '''
First paragraph.

<!-- ILLUSTRATION: pending diagram -->

Second paragraph.
''';
        final blocks = markdownToPortableText(
          markdown,
          lesson: lesson,
          assets: const LessonAssetMap.unconfigured(),
        );

        expect(blocks.length, 2);
        expect(blocks[0]['_type'], 'block');
        expect(blocks[1]['_type'], 'block');
        final raw0 = blocks[0]['children']! as List;
        final raw1 = blocks[1]['children']! as List;
        final children0 = raw0.cast<Map<String, dynamic>>();
        final children1 = raw1.cast<Map<String, dynamic>>();
        expect(children0[0]['text'], 'First paragraph.');
        expect(children1[0]['text'], 'Second paragraph.');
      },
    );
  });
}
