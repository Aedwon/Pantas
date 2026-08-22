import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../tools/lesson_author/illustration_preview_renderer.dart';

const _key = 'reading-comprehension/text-types/short-stories-and-novels#1';
const _figureMarker =
    '<!-- FIGURE: {"kind":"reading-diagram","type":"plot-arc",' ' '
    '"illustrationKey":"$_key","shape":"rise-peak-fall",'
    '"stages":["introduction","rising action","climax","resolution"]} -->';

void main() {
  test('findReviewFigureSpecs extracts one frozen original-code marker', () {
    final root = _fixtureRoot();
    addTearDown(() => root.deleteSync(recursive: true));
    _writeStrategy(root);
    _writeLesson(root, 'one.md', _figureMarker);

    final specs = findReviewFigureSpecs(root);

    expect(specs, hasLength(1));
    expect(specs[_key]?['kind'], 'reading-diagram');
  });

  test('findReviewFigureSpecs rejects duplicate review keys', () {
    final root = _fixtureRoot();
    addTearDown(() => root.deleteSync(recursive: true));
    _writeStrategy(root);
    _writeLesson(root, 'one.md', _figureMarker);
    _writeLesson(root, 'two.md', _figureMarker);

    expect(
      () => findReviewFigureSpecs(root),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Duplicate review FIGURE marker'),
        ),
      ),
    );
  });

  test('findReviewFigureSpecs rejects missing review keys', () {
    final root = _fixtureRoot();
    addTearDown(() => root.deleteSync(recursive: true));
    _writeStrategy(root);
    Directory(p.join(root.path, 'content', 'lessons'))
        .createSync(recursive: true);

    expect(
      () => findReviewFigureSpecs(root),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Missing review FIGURE markers'),
        ),
      ),
    );
  });

  test('findReviewFigureSpecs rejects malformed illustrationKey values', () {
    final root = _fixtureRoot();
    addTearDown(() => root.deleteSync(recursive: true));
    _writeStrategy(root);
    _writeLesson(
      root,
      'one.md',
      '<!-- FIGURE: {"kind":"reading-diagram","illustrationKey":7} -->',
    );

    expect(
      () => findReviewFigureSpecs(root),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('malformed illustrationKey'),
        ),
      ),
    );
  });

  testWidgets('renderReviewPreviews writes light and dark PNGs and digest', (
    tester,
  ) async {
    final root = _fixtureRoot();
    addTearDown(() => root.deleteSync(recursive: true));
    _writeStrategy(root);
    _writeLesson(root, 'one.md', _figureMarker);
    final output = Directory(p.join(root.path, 'build', 'previews'));

    final manifest = await renderReviewPreviews(
      repositoryRoot: root,
      outputRoot: output,
      tester: tester,
    );

    expect(manifest.entries, hasLength(1));
    final entry = manifest.entries.single;
    expect(entry.key, _key);
    expect(entry.width, reviewPreviewWidth);
    expect(entry.digest, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(entry.lightPath, startsWith('light/'));
    expect(entry.darkPath, startsWith('dark/'));
    final light = File(p.join(output.path, entry.lightPath)).readAsBytesSync();
    final dark = File(p.join(output.path, entry.darkPath)).readAsBytesSync();
    const signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
    expect(light.take(8), signature);
    expect(dark.take(8), signature);
    expect(File(p.join(output.path, 'manifest.json')).existsSync(), isTrue);

    final changedLight = Uint8List.fromList(light)..[light.length - 1] ^= 1;
    final changedDark = Uint8List.fromList(dark)..[dark.length - 1] ^= 1;
    expect(reviewPreviewDigest(changedLight, dark), isNot(entry.digest));
    expect(reviewPreviewDigest(light, changedDark), isNot(entry.digest));

    final outputCanonical = p.canonicalize(output.path);
    for (final file in output.listSync(recursive: true).whereType<File>()) {
      expect(p.canonicalize(file.path), startsWith(outputCanonical));
    }
  });
}

Directory _fixtureRoot() => Directory.systemTemp.createTempSync(
      'pantas-lesson-preview-renderer-',
    );

void _writeStrategy(Directory root) {
  final file = File(
    p.join(root.path, 'docs', 'content', 'illustrations', 'strategy.tsv'),
  )..parent.createSync(recursive: true);
  file.writeAsStringSync(
    'subject\ttopic\tlesson\tseq\ttarget_file\tdescription\tstrategy\tbatch\n'
    'reading-comprehension\ttext-types\tshort-stories-and-novels\t1\t'
    'unused.png\tPlot arc\tcode\toriginal-code-a\n',
  );
}

void _writeLesson(Directory root, String name, String body) {
  final file = File(p.join(root.path, 'content', 'lessons', name))
    ..parent.createSync(recursive: true);
  file.writeAsStringSync('$body\n');
}
