// ignore_for_file: cascade_invocations, use_raw_strings, require_trailing_commas, unnecessary_raw_strings, lines_longer_than_80_chars
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Matches the tool's folder name but not `content_passages`.
final _name = RegExp(r'content_pass(?![A-Za-z0-9])');
final _directive =
    RegExp('''^\\s*(?:import|export|part)\\s+['"]([^'"]+)['"]''');

const _skipDirs = {
  '.dart_tool',
  '.git',
  '.gradle',
  'build',
  'Pods',
  'node_modules',
};

Iterable<File> _files(Directory dir, {String? ext}) sync* {
  if (!dir.existsSync()) return;
  for (final entity in dir.listSync(followLinks: false)) {
    final name = p.basename(entity.path);
    if (entity is Directory) {
      if (!_skipDirs.contains(name)) yield* _files(entity, ext: ext);
    } else if (entity is File && (ext == null || name.endsWith(ext))) {
      yield entity;
    }
  }
}

String? _text(File file) {
  try {
    return file.readAsStringSync();
  } on FileSystemException {
    return null;
  }
}

/// Every way the Content Pass tool could reach a normal build.
List<String> findLeaks(Directory root) {
  final leaks = <String>[];
  String rel(File f) => p.relative(f.path, from: root.path);

  // 1. The app and its tests never import the tool.
  for (final dir in ['lib', 'integration_test']) {
    for (final file in _files(Directory('${root.path}/$dir'), ext: '.dart')) {
      final text = _text(file);
      if (text == null) continue;
      for (final line in text.split('\n')) {
        final uri = _directive.firstMatch(line)?.group(1);
        if (uri != null && _name.hasMatch(uri)) {
          leaks.add('${rel(file)} imports $uri');
        }
      }
    }
  }

  // 2. No build input names the tool.
  final inputs = [
    File('${root.path}/pubspec.yaml'),
    File('${root.path}/codemagic.yaml'),
    ..._files(Directory('${root.path}/web')),
    ..._files(Directory('${root.path}/android')),
    ..._files(Directory('${root.path}/ios')),
  ];
  for (final file in inputs) {
    final text = _text(file);
    if (text != null && _name.hasMatch(text)) {
      leaks.add('${rel(file)} mentions content_pass');
    }
  }

  // 3. Nothing outside the tool and its tests imports the tool's app code.
  final appDir = p.normalize('${root.path}/tools/content_pass/app');
  final allowed = [
    p.normalize('${root.path}/tools/content_pass'),
    p.normalize('${root.path}/test/content_pass'),
  ];
  for (final file in _files(root, ext: '.dart')) {
    final path = p.normalize(file.path);
    if (allowed.any((a) => p.isWithin(a, path))) continue;
    final text = _text(file);
    if (text == null) continue;
    for (final line in text.split('\n')) {
      final uri = _directive.firstMatch(line)?.group(1);
      if (uri == null) continue;
      final resolved = uri.startsWith('package:') || uri.startsWith('dart:')
          ? uri
          : p.normalize(p.join(p.dirname(path), uri));
      if (resolved.contains('content_pass/app') ||
          p.isWithin(appDir, resolved)) {
        leaks.add('${rel(file)} imports $uri');
      }
    }
  }
  return leaks;
}

void main() {
  test('nothing in a normal build reaches the Content Pass tool', () {
    expect(findLeaks(Directory.current), isEmpty);
  });

  group('the guard can fail', () {
    late Directory root;

    void write(String path, String text) {
      File('${root.path}/$path')
        ..createSync(recursive: true)
        ..writeAsStringSync(text);
    }

    setUp(() => root = Directory.systemTemp.createTempSync('leak_test'));
    tearDown(() => root.deleteSync(recursive: true));

    test('an app file importing the tool is caught', () {
      write(
        'lib/a.dart',
        "import '../tools/content_pass/app/main.dart';\n",
      );
      expect(findLeaks(root), hasLength(2));
    });

    test('a build file naming the tool is caught', () {
      write('pubspec.yaml', '  - tools/content_pass/app/index.html\n');
      write('web/x.html', '<script src="content_pass/a.js">');
      expect(findLeaks(root), hasLength(2));
    });

    test('content_passages is not mistaken for the tool', () {
      write('lib/a.dart', "import 'tables/content_passages.dart';\n");
      write('pubspec.yaml', 'content_passages\n');
      expect(findLeaks(root), isEmpty);
    });

    test('code outside the tool importing its app code is caught', () {
      write('tools/other/x.dart', "import '../content_pass/app/api.dart';\n");
      write('tools/content_pass/app/api.dart', '');
      write('tools/content_pass/server/s.dart', "import '../app/api.dart';\n");
      expect(findLeaks(root),
          ['tools/other/x.dart imports ../content_pass/app/api.dart']);
    });
  });
}
