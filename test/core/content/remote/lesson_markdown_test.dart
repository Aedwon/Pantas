import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/lesson_markdown.dart';

import '../../../../tools/content/lesson_asset_map.dart';
import '../../../../tools/content/markdown_portable_text.dart';

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
}
