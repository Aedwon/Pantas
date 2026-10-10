import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('list every application placeholder call site for the release gate', () {
    final uses = _findPlaceholderUses(Directory('lib'));
    // W4 may introduce approved development placeholders. W5 reads this list
    // and blocks release until each source has replaced its value.
    // ignore: avoid_print
    print(
      'PlaceholderFigure application uses (${uses.length}):\n'
      '${uses.isEmpty ? 'none' : uses.join('\n')}',
    );
    expect(Directory('lib').existsSync(), isTrue);
  });
  test('the release inventory reports multiple and split-line call sites', () {
    final directory =
        Directory.systemTemp.createTempSync('pantas-placeholder-inventory-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File('${directory.path}/screen.dart')
      ..writeAsStringSync(
        'PlaceholderFigure(27, reason: "source");\n\n'
        'PlaceholderFigure\n(28, reason: "source");',
      );
    expect(
      _findPlaceholderUses(directory),
      ['${file.path}:1', '${file.path}:3'],
    );
  });
  test('the release inventory finds a constructor reference used by a builder',
      () {
    final directory =
        Directory.systemTemp.createTempSync('pantas-placeholder-reference-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File('${directory.path}/screen.dart')
      ..writeAsStringSync('final buildFigure = PlaceholderFigure.new;');
    expect(_findPlaceholderUses(directory), ['${file.path}:1']);
  });
}

List<String> _findPlaceholderUses(Directory directory) {
  final uses = <String>[];
  final pattern = RegExp(r'\bPlaceholderFigure\b');
  final files = directory.listSync(recursive: true).whereType<File>().where(
        (file) =>
            file.path.endsWith('.dart') &&
            !file.path.endsWith('/placeholder_figure.dart'),
      );
  for (final file in files) {
    final source = file.readAsStringSync();
    for (final match in pattern.allMatches(source)) {
      final line = source.substring(0, match.start).split('\n').length;
      uses.add('${file.path}:$line');
    }
  }
  return uses..sort();
}
