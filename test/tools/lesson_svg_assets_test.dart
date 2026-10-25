import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/content/lesson_asset_map.dart';
import '../../tools/content/markdown_portable_text.dart';

void main() {
  late Directory root;
  setUp(() => root = Directory.systemTemp.createTempSync('lesson-svg-'));
  tearDown(() => root.deleteSync(recursive: true));
  test('seed joins local SVG and PNG to markers in numeric order', () {
    final dir =
        Directory('${root.path}/content/illustrations/math/topic/lesson')
          ..createSync(recursive: true);
    File('${dir.path}/02-old.png').writeAsBytesSync([137, 80, 78, 71]);
    File('${dir.path}/01-new.svg')
        .writeAsStringSync('<svg xmlns="http://www.w3.org/2000/svg"/>');
    final assets = LessonAssetMap.fromJsonFile(
      File('${root.path}/content/illustrations/assets.json'),
    );
    final blocks = markdownToPortableText(
      '<!-- ILLUSTRATION: First -->\n\n<!-- ILLUSTRATION: Second -->',
      lesson: const LessonIdentity(
        path: 'content/lessons/math/topic/lesson.md',
        subject: 'math',
        topic: 'topic',
        lesson: 'lesson',
      ),
      assets: assets,
    );
    expect(blocks, hasLength(2));
    final first = blocks[0]['asset']! as Map<String, Object?>;
    final second = blocks[1]['asset']! as Map<String, Object?>;
    expect(UriData.parse(first['url']! as String).mimeType, 'image/svg+xml');
    expect(
      utf8.decode(UriData.parse(first['url']! as String).contentAsBytes()),
      contains('<svg'),
    );
    expect(UriData.parse(second['url']! as String).mimeType, 'image/png');
    expect(blocks[0]['alt'], 'First');
  });
  test('replacement retains an existing separate credit key', () {
    final dir =
        Directory('${root.path}/content/illustrations/math/topic/lesson')
          ..createSync(recursive: true);
    File('${dir.path}/01-new.svg').writeAsStringSync('<svg/>');
    final sourceDir = Directory('${root.path}/content/illustrations/sources')
      ..createSync();
    File('${sourceDir.path}/test.yaml').writeAsStringSync(
      'assets:\n  - key: old\n    credit: Original artist\n',
    );
    final map = File('${root.path}/content/illustrations/assets.json')
      ..writeAsStringSync(
        jsonEncode({
          'math/topic/lesson#1': {
            'url': 'https://example.com/old.png',
            'creditKey': 'old',
          },
        }),
      );
    final assets = LessonAssetMap.fromJsonFile(map);
    expect(
      assets.creditFor(assets.get('math/topic/lesson#1')!),
      'Original artist',
    );
  });
  test('duplicate PNGs fail even when an SVG sorts between them', () {
    final dir =
        Directory('${root.path}/content/illustrations/math/topic/lesson')
          ..createSync(recursive: true);
    for (final name in ['01-a.png', '01-b.svg', '01-c.png']) {
      File('${dir.path}/$name').writeAsStringSync('<svg/>');
    }
    expect(
      () => LessonAssetMap.fromJsonFile(
        File('${root.path}/content/illustrations/assets.json'),
      ),
      throwsFormatException,
    );
  });
  test('duplicate SVG sequence fails instead of selecting an arbitrary file',
      () {
    final dir =
        Directory('${root.path}/content/illustrations/math/topic/lesson')
          ..createSync(recursive: true);
    for (final name in ['01-a.svg', '01-b.svg']) {
      File('${dir.path}/$name').writeAsStringSync('<svg/>');
    }
    expect(
      () => LessonAssetMap.fromJsonFile(
        File('${root.path}/content/illustrations/assets.json'),
      ),
      throwsFormatException,
    );
  });
}
