import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/lesson_markdown.dart';

import '../../../../tools/content/lesson_asset_map.dart';
import '../../../../tools/content/markdown_portable_text.dart';
import '../../../helpers/walkthrough_fixtures.dart';

void main() {
  test('server resolved SVG marker becomes an accessible image block', () {
    final blocks = lessonBlocksFromMarkdown(
      '<!-- IMAGE: {"asset":{"url":"data:image/svg+xml;base64,PHN2Zy8+","credit":"Pantas"},"alt":"A triangle"} -->',
    );
    expect(blocks, hasLength(1));
    expect(blocks.single['_type'], 'image');
    expect(blocks.single['alt'], 'A triangle');
    expect(
      (blocks.single['asset']! as Map<String, Object?>)['url'],
      startsWith('data:image/svg+xml'),
    );
  });
  test('malformed resolved image marker fails explicitly', () {
    expect(
      () => lessonBlocksFromMarkdown('<!-- IMAGE: {} -->'),
      throwsFormatException,
    );
  });

  test('every lesson converts exactly as the bundled content build does', () {
    final files = Directory('content/lessons')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.md'))
        .toList();
    expect(files, isNotEmpty);
    final frontmatter = RegExp(r'^---\n(.*?)\n---\n', dotAll: true);
    for (final file in files) {
      final source = file.readAsStringSync();
      final match = frontmatter.firstMatch(source);
      if (match == null) continue;
      final body = source.substring(match.end);
      expect(
        lessonBlocksFromMarkdown(body),
        markdownToPortableText(
          body,
          lesson: LessonIdentity.fromPath(file.path),
          assets: const LessonAssetMap.unconfigured(),
        ),
        reason: file.path,
      );
    }
  });

  test('drops illustration markers and keeps figures, tables and math', () {
    final blocks = lessonBlocksFromMarkdown(
      [
        '## Title',
        '',
        r'Text with $x$ and **bold**.',
        '',
        '<!-- ILLUSTRATION: a picture -->',
        '',
        '| a | b |',
        '| - | - |',
        '| 1 | 2 |',
        '',
        '<!-- FIGURE: {"kind":"bar","semanticsLabel":"Bars"} -->',
      ].join('\n'),
    );
    expect(
      blocks.map((block) => block['_type']),
      ['block', 'block', 'table', 'figureSpec'],
    );
  });

  test('a malformed table is refused with its line number', () {
    expect(
      () => lessonBlocksFromMarkdown('| a | b |\nnot a delimiter'),
      throwsA(
        isA<FormatException>()
            .having((e) => e.message, 'message', contains('line 2')),
      ),
    );
  });

  group('walk-through blocks', () {
    List<Map<String, Object?>> bundled(String body) => markdownToPortableText(
          body,
          lesson: const LessonIdentity(
            path: 'content/lessons/test/test/test.md',
            subject: 'test',
            topic: 'test',
            lesson: 'test',
          ),
          assets: const LessonAssetMap.unconfigured(),
        );

    test('every fence type converts to the schema, exactly', () {
      expect(
        lessonBlocksFromMarkdown(walkthroughExactMarkdown),
        walkthroughExactBlocks,
      );
    });

    test('a lesson with no fence gets no anchor field', () {
      final blocks = lessonBlocksFromMarkdown(
        '## A\n\n### B Rule\n\n#### C\n\nText.',
      );
      expect(blocks.where((block) => block.containsKey('anchor')), isEmpty);
    });

    test('anchors go on h3 only, in a walk-through lesson', () {
      final blocks = lessonBlocksFromMarkdown(
        '## A\n\n### B Rule\n\n#### C\n\n:::why\nWhy.\n:::',
      );
      expect(
        blocks.map((block) => block['anchor']),
        [null, 'b-rule', null, null],
      );
    });

    test('the two converters agree on every walk-through fixture', () {
      for (final name in walkthroughSamples) {
        final body = walkthroughFixture(name);
        expect(lessonBlocksFromMarkdown(body), bundled(body), reason: name);
      }
      expect(
        lessonBlocksFromMarkdown(walkthroughExactMarkdown),
        bundled(walkthroughExactMarkdown),
      );
    });

    for (final entry in walkthroughBadCases.entries) {
      test('${entry.key} fails with its line, as the bundled build does', () {
        final (line, words) = entry.value;
        final body = walkthroughFixture(entry.key);
        expect(
          () => lessonBlocksFromMarkdown(body),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              allOf(contains(words), endsWith(' at line $line')),
            ),
          ),
        );
        expect(
          () => bundled(body),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              allOf(contains(words), contains(':$line')),
            ),
          ),
        );
      });
    }

    test('a table error inside a block names the line in the lesson', () {
      expect(
        () => lessonBlocksFromMarkdown(
          ':::why\n| a | b |\nnot a delimiter\n:::',
        ),
        throwsA(
          isA<FormatException>()
              .having((e) => e.message, 'message', contains('line 3')),
        ),
      );
    });
  });
}
