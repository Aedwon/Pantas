// Runs the renderer branch's walk-through parser (copied from
// ux/walkthrough-renderer-r1) over lesson files. Usage:
//   dart run run.dart <file-or-dir>...
// Prints one line per failing lesson; exit 1 if any fail.
import 'dart:io';

import 'walkthrough_markdown.dart';

void main(List<String> args) {
  final files = <File>[];
  for (final a in args) {
    final t = FileSystemEntity.typeSync(a);
    if (t == FileSystemEntityType.directory) {
      files.addAll(Directory(a)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.md')));
    } else if (t == FileSystemEntityType.file) {
      files.add(File(a));
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  var walk = 0, bad = 0;
  for (final f in files) {
    final all = f.readAsStringSync().split('\n');
    // Skip front matter, keeping file line numbers.
    var start = 0;
    if (all.isNotEmpty && all.first.trim() == '---') {
      final end = all.indexWhere((l) => l.trim() == '---', 1);
      if (end > 0) start = end + 1;
    }
    final body = all.sublist(start);
    try {
      final plan = planWalkthrough(body,
          firstLine: start + 1,
          error: (line, m) => FormatException('$m at line $line'));
      if (plan.isWalk) walk++;
    } on FormatException catch (e) {
      bad++;
      walk++;
      stdout.writeln('FAIL ${f.path}: ${e.message}');
    }
  }
  stdout.writeln('walk-through lessons: $walk, failing: $bad');
  exitCode = bad == 0 ? 0 : 1;
}
