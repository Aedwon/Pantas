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
  const identity = LessonIdentity(
    path: 'content/lessons/math/topic/lesson.md',
    subject: 'math',
    topic: 'topic',
    lesson: 'lesson',
  );
  File figure(String relative, [String content = '<svg/>']) =>
      File('${root.path}/content/illustrations/$relative')
        ..createSync(recursive: true)
        ..writeAsStringSync(content);
  LessonAssetMap load() => LessonAssetMap.fromJsonFile(
        File('${root.path}/content/illustrations/assets.json'),
      );
  for (final name in [
    'math/topic/lesson/1-short-number.svg',
    'math/topic/lesson/01-Upper-Case.svg',
    'math/topic/lesson/01-upper-extension.SVG',
    'math/topic/lesson/01-photo.jpg',
    'math/topic/lesson/01_underscore.svg',
    'math/topic/lesson/00-zero.svg',
    'math/topic/01-too-shallow.svg',
    'math/topic/lesson/extra/01-too-deep.svg',
  ]) {
    test('misnamed figure file fails with its path and the rule: $name', () {
      figure('math/topic/lesson/01-good.svg');
      final bad = figure(name);
      expect(
        load,
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(contains(bad.path), contains('NN-slug')),
          ),
        ),
      );
    });
  }
  test('a figure file no marker uses fails with its path', () {
    figure('math/topic/lesson/01-a.svg');
    final unused = figure('math/topic/lesson/02-b.svg');
    expect(
      () => markdownToPortableText(
        '<!-- ILLUSTRATION: Only one -->',
        lesson: identity,
        assets: load(),
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains(unused.path), contains('no ILLUSTRATION marker')),
        ),
      ),
    );
  });
  test('figure files fail when the lesson has no markers at all', () {
    final unused = figure('math/topic/lesson/01-a.svg');
    expect(
      () => markdownToPortableText(
        'No figures here.',
        lesson: identity,
        assets: load(),
      ),
      throwsA(
        isA<FormatException>()
            .having((e) => e.message, 'message', contains(unused.path)),
      ),
    );
  });
  test('figures of a lesson that no longer exists fail with their path', () {
    final orphan = figure('math/topic/renamed-lesson/01-a.svg');
    figure('math/topic/lesson/01-b.svg');
    expect(
      () => load().assertNoOrphanFigures([identity]),
      throwsA(
        isA<FormatException>()
            .having((e) => e.message, 'message', contains(orphan.path)),
      ),
    );
    File(orphan.path).parent.deleteSync(recursive: true);
    load().assertNoOrphanFigures([identity]);
  });
  test('a symbolic link in place of a figure file fails with its path', () {
    final target = figure('math/topic/lesson/01-real.svg');
    final link =
        Link('${root.path}/content/illustrations/math/topic/lesson/02-link.svg')
          ..createSync(target.path);
    expect(
      load,
      throwsA(
        isA<FormatException>()
            .having((e) => e.message, 'message', contains(link.path)),
      ),
    );
  });
}
