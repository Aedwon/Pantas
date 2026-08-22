import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/lesson_figure_widget.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:path/path.dart' as p;

const reviewPreviewWidth = 390;
const _reviewBatches = <String>{'original-code-a', 'original-code-b'};

class ReviewPreviewEntry {
  const ReviewPreviewEntry({
    required this.key,
    required this.lightPath,
    required this.darkPath,
    required this.digest,
    required this.width,
    required this.height,
  });

  final String key;
  final String lightPath;
  final String darkPath;
  final String digest;
  final int width;
  final int height;

  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        'lightPath': lightPath,
        'darkPath': darkPath,
        'digest': digest,
        'width': width,
        'height': height,
      };
}

class ReviewPreviewManifest {
  const ReviewPreviewManifest(this.entries);

  final List<ReviewPreviewEntry> entries;

  Map<String, Object?> toJson() => <String, Object?>{
        'version': 1,
        'items': entries.map((entry) => entry.toJson()).toList(),
      };
}

Map<String, Map<String, Object?>> findReviewFigureSpecs(
  Directory repositoryRoot,
) {
  final expectedKeys = _readExpectedReviewKeys(repositoryRoot);
  final lessonRoot = Directory(
    p.join(repositoryRoot.path, 'content', 'lessons'),
  );
  if (!lessonRoot.existsSync()) {
    throw StateError('Lesson directory not found: ${lessonRoot.path}');
  }

  final specs = <String, Map<String, Object?>>{};
  final markerPattern = RegExp(r'<!--\s*FIGURE:\s*(\{.*\})\s*-->');
  final files = lessonRoot
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => p.extension(file.path) == '.md')
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final lines = const LineSplitter().convert(file.readAsStringSync());
    for (var lineNumber = 0; lineNumber < lines.length; lineNumber++) {
      final match = markerPattern.firstMatch(lines[lineNumber]);
      if (match == null) continue;
      Object? decoded;
      try {
        decoded = jsonDecode(match.group(1)!);
      } on FormatException catch (error) {
        throw FormatException(
          'Malformed FIGURE marker at ${file.path}:${lineNumber + 1}: '
          '${error.message}',
        );
      }
      if (decoded is! Map) {
        throw FormatException(
          'FIGURE marker at ${file.path}:${lineNumber + 1} must be an object.',
        );
      }
      final spec = decoded.cast<String, Object?>();
      if (!spec.containsKey('illustrationKey')) continue;
      final rawKey = spec['illustrationKey'];
      if (rawKey is! String || rawKey.trim().isEmpty) {
        throw FormatException(
          'FIGURE marker at ${file.path}:${lineNumber + 1} has a malformed '
          'illustrationKey.',
        );
      }
      final key = rawKey.trim();
      if (!expectedKeys.contains(key)) continue;
      if (specs.containsKey(key)) {
        throw StateError('Duplicate review FIGURE marker for $key.');
      }
      specs[key] = Map<String, Object?>.unmodifiable(spec);
    }
  }

  final missing = expectedKeys.difference(specs.keys.toSet()).toList()..sort();
  if (missing.isNotEmpty) {
    throw StateError('Missing review FIGURE markers: ${missing.join(', ')}');
  }
  if (specs.length != expectedKeys.length) {
    throw StateError(
      'Expected ${expectedKeys.length} review FIGURE markers, found '
      '${specs.length}.',
    );
  }

  return Map<String, Map<String, Object?>>.unmodifiable(specs);
}

Future<ReviewPreviewManifest> renderReviewPreviews({
  required Directory repositoryRoot,
  required Directory outputRoot,
  required WidgetTester tester,
}) async {
  final specs = findReviewFigureSpecs(repositoryRoot);
  outputRoot.createSync(recursive: true);
  final lightDir = Directory(p.join(outputRoot.path, 'light'));
  final darkDir = Directory(p.join(outputRoot.path, 'dark'));
  lightDir.createSync(recursive: true);
  darkDir.createSync(recursive: true);

  await tester.binding.setSurfaceSize(const Size(390, 900));

  final entries = <ReviewPreviewEntry>[];
  try {
    final keys = specs.keys.toList()..sort();
    for (final key in keys) {
      final stem = _previewStem(key);
      final lightRelativePath = p.posix.join('light', '$stem.png');
      final darkRelativePath = p.posix.join('dark', '$stem.png');
      final light = await _renderOne(
        tester: tester,
        spec: specs[key]!,
        theme: buildLightTheme(),
      );
      final dark = await _renderOne(
        tester: tester,
        spec: specs[key]!,
        theme: buildDarkTheme(),
      );
      if (light.width != reviewPreviewWidth ||
          dark.width != reviewPreviewWidth) {
        throw StateError('Preview width for $key was not $reviewPreviewWidth.');
      }

      File(p.join(outputRoot.path, lightRelativePath)).writeAsBytesSync(
        light.bytes,
        flush: true,
      );
      File(p.join(outputRoot.path, darkRelativePath)).writeAsBytesSync(
        dark.bytes,
        flush: true,
      );

      entries.add(
        ReviewPreviewEntry(
          key: key,
          lightPath: lightRelativePath,
          darkPath: darkRelativePath,
          digest: reviewPreviewDigest(light.bytes, dark.bytes),
          width: reviewPreviewWidth,
          height: light.height > dark.height ? light.height : dark.height,
        ),
      );
    }
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  }

  final manifest = ReviewPreviewManifest(List.unmodifiable(entries));
  final manifestFile = File(p.join(outputRoot.path, 'manifest.json'));
  manifestFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(manifest.toJson())}\n',
    flush: true,
  );
  return manifest;
}

String reviewPreviewDigest(Uint8List lightBytes, Uint8List darkBytes) {
  final lightHash = sha256.convert(lightBytes).toString();
  final darkHash = sha256.convert(darkBytes).toString();
  return sha256.convert(utf8.encode('$lightHash:$darkHash')).toString();
}

Set<String> _readExpectedReviewKeys(Directory repositoryRoot) {
  final strategy = File(
    p.join(
      repositoryRoot.path,
      'docs',
      'content',
      'illustrations',
      'strategy.tsv',
    ),
  );
  if (!strategy.existsSync()) {
    throw StateError('Illustration strategy not found: ${strategy.path}');
  }
  final lines = const LineSplitter().convert(strategy.readAsStringSync());
  if (lines.isEmpty) throw StateError('Illustration strategy is empty.');
  final header = lines.first.split('\t');
  final subjectIndex = header.indexOf('subject');
  final topicIndex = header.indexOf('topic');
  final lessonIndex = header.indexOf('lesson');
  final sequenceIndex = header.indexOf('seq');
  final batchIndex = header.indexOf('batch');
  final required = <String, int>{
    'subject': subjectIndex,
    'topic': topicIndex,
    'lesson': lessonIndex,
    'seq': sequenceIndex,
    'batch': batchIndex,
  };
  final missingColumns = required.entries
      .where((entry) => entry.value < 0)
      .map((entry) => entry.key)
      .toList();
  if (missingColumns.isNotEmpty) {
    throw StateError(
      'Illustration strategy is missing columns: ${missingColumns.join(', ')}.',
    );
  }

  final keys = <String>{};
  for (final line in lines.skip(1)) {
    if (line.trim().isEmpty) continue;
    final columns = line.split('\t');
    if (columns.length < header.length) {
      throw StateError('Malformed illustration strategy row: $line');
    }
    if (!_reviewBatches.contains(columns[batchIndex])) continue;
    final key = '${columns[subjectIndex]}/${columns[topicIndex]}/'
        '${columns[lessonIndex]}#${columns[sequenceIndex]}';
    if (!keys.add(key)) {
      throw StateError('Duplicate original-code strategy key: $key.');
    }
  }
  return keys;
}

Future<_RenderedPreview> _renderOne({
  required WidgetTester tester,
  required Map<String, Object?> spec,
  required ThemeData theme,
}) async {
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Material(
        color: theme.scaffoldBackgroundColor,
        child: Align(
          alignment: Alignment.topCenter,
          child: RepaintBoundary(
            key: boundaryKey,
            child: SizedBox(
              width: reviewPreviewWidth.toDouble(),
              child: LessonFigureWidget(
                spec: spec,
                semanticsLabel: spec['illustrationKey']! as String,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  for (var frame = 0; frame < 10 && tester.binding.hasScheduledFrame; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  final exception = tester.takeException();
  if (exception != null) {
    throw StateError('Review preview render failed: $exception');
  }

  final renderObject = boundaryKey.currentContext?.findRenderObject();
  if (renderObject is! RenderRepaintBoundary) {
    throw StateError('Review preview did not produce a RepaintBoundary.');
  }
  final image = await renderObject.toImage();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  if (data == null) {
    image.dispose();
    throw StateError('Review preview PNG encoding failed.');
  }
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  final result = _RenderedPreview(
    bytes: Uint8List.fromList(bytes),
    width: image.width,
    height: image.height,
  );
  image.dispose();
  return result;
}

String _previewStem(String key) =>
    key.replaceAll(RegExp('[^A-Za-z0-9._-]'), '__');

class _RenderedPreview {
  const _RenderedPreview({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}
