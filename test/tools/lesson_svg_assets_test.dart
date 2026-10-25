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
    Directory('${root.path}/content/illustrations/sources').createSync();
    File('${root.path}/content/illustrations/sources/test.yaml')
        .writeAsStringSync(
      'assets:\n  - key: "math/topic/lesson#2"\n    credit: Test artist\n',
    );
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
  void credit(String key, String credit) {
    final sources = Directory('${root.path}/content/illustrations/sources')
      ..createSync(recursive: true);
    File('${sources.path}/test.yaml').writeAsStringSync(
      'assets:\n  - key: "$key"\n    credit: $credit\n',
    );
  }

  test('a new SVG with no credit entry is an original Pantas drawing', () {
    figure('math/topic/lesson/01-new.svg');
    final assets = load();
    expect(assets.creditFor(assets.get('math/topic/lesson#1')!), 'Pantas');
  });
  test('a local PNG with no credit fails with its path and the key', () {
    final png = figure('math/topic/lesson/01-old.png');
    expect(
      load,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains(png.path), contains('math/topic/lesson#1')),
        ),
      ),
    );
  });
  test('a local PNG with a credit in the sources keeps that credit', () {
    figure('math/topic/lesson/01-old.png');
    credit('math/topic/lesson#1', 'Test artist');
    final assets = load();
    expect(assets.creditFor(assets.get('math/topic/lesson#1')!), 'Test artist');
  });
  test('an SVG replacing an entry whose credit is missing fails', () {
    final svg = figure('math/topic/lesson/01-new.svg');
    File('${root.path}/content/illustrations/assets.json').writeAsStringSync(
      jsonEncode({
        'math/topic/lesson#1': {
          'url': 'https://example.com/old.png',
          'creditKey': 'not-in-sources',
        },
      }),
    );
    expect(
      load,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains(svg.path), contains('not-in-sources')),
        ),
      ),
    );
  });
  String svgOfSize(int bytes) => '<svg xmlns="http://www.w3.org/2000/svg">'
      '${'<!--${'x' * 1000}-->' * (bytes ~/ 1008)}</svg>';
  test('figures past 900,000 resolved bytes are dropped with a warning', () {
    figure('math/topic/lesson/01-a.svg', svgOfSize(400000));
    figure('math/topic/lesson/02-b.svg', svgOfSize(400000));
    final warnings = <String>[];
    final blocks = markdownToPortableText(
      'Before\n\n<!-- ILLUSTRATION: First -->\n\n<!-- ILLUSTRATION: Second -->'
      '\n\nAfter',
      lesson: identity,
      assets: load(),
      onWarning: warnings.add,
    );
    expect(blocks.where((b) => b['_type'] == 'image'), hasLength(1));
    expect(blocks.where((b) => b['_type'] == 'block'), hasLength(2));
    expect(warnings, hasLength(1));
    expect(warnings.single, allOf(contains('900000'), contains('lesson.md')));
  });
  test('one figure over the limit is dropped and the lesson text stays', () {
    figure('math/topic/lesson/01-a.svg', svgOfSize(700000));
    final warnings = <String>[];
    final blocks = markdownToPortableText(
      'Before\n\n<!-- ILLUSTRATION: First -->',
      lesson: identity,
      assets: load(),
      onWarning: warnings.add,
    );
    expect(blocks.where((b) => b['_type'] == 'image'), isEmpty);
    expect(warnings, hasLength(1));
  });
  // The upload tool's test uses the same body and the same two sizes.
  for (final (size, kept) in [(674916, true), (674917, false)]) {
    test('the 900,000 byte limit matches the upload tool: $size bytes', () {
      figure(
        'math/topic/lesson/01-a.svg',
        '<svg>${' ' * (size - 11)}</svg>',
      );
      final blocks = markdownToPortableText(
        'Before\n\n<!-- ILLUSTRATION: First -->\n\nAfter',
        lesson: identity,
        assets: load(),
        onWarning: (_) {},
      );
      expect(
        blocks.where((b) => b['_type'] == 'image'),
        kept ? hasLength(1) : isEmpty,
      );
    });
  }
}
