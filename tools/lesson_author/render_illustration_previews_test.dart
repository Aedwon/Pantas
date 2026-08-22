import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'illustration_preview_renderer.dart';

void main() {
  testWidgets('render live lesson illustration review previews',
      (tester) async {
    final repositoryRoot = Directory.current;
    final outputRoot = Directory(
      p.join(
        repositoryRoot.path,
        'build',
        'lesson_author',
        'illustration_previews',
      ),
    );

    final manifest = await renderReviewPreviews(
      repositoryRoot: repositoryRoot,
      outputRoot: outputRoot,
      tester: tester,
    );

    expect(manifest.entries, hasLength(52));
    var previewCount = 0;
    for (final entry in manifest.entries) {
      final light = File(p.join(outputRoot.path, entry.lightPath));
      final dark = File(p.join(outputRoot.path, entry.darkPath));
      expect(light.existsSync(), isTrue, reason: entry.key);
      expect(dark.existsSync(), isTrue, reason: entry.key);
      previewCount += 2;
    }
    expect(previewCount, 104);
    debugPrint('52 figures, 104 previews, 0 render errors');
  });
}
