// Pre-tap word count for walk-through lessons: words outside the front
// matter, HTML comments, :::answer and :::why blocks. Same rule as the
// session 2 awk count, as a Dart tool so the lead runs it with plain
// arguments (no shell scripts, Nov 26 shell rule). Usage:
//   dart run wc.dart <file-or-dir>...
// Prints "<words> <path>" per lesson and a total.
import 'dart:io';

int count(List<String> lines) {
  var n = 0;
  var i = 0;
  if (lines.isNotEmpty && lines.first == '---') {
    i = lines.indexOf('---', 1) + 1;
    if (i == 0) return 0;
  }
  var hidden = false;
  var comment = false;
  for (; i < lines.length; i++) {
    final line = lines[i];
    if (comment) {
      if (line.contains('-->')) comment = false;
      continue;
    }
    if (line.contains('<!--')) {
      if (!line.contains('-->')) comment = true;
      continue;
    }
    if (line.startsWith(':::answer') || line.startsWith(':::why')) {
      hidden = true;
      continue;
    }
    if (line.startsWith(':::')) {
      hidden = false;
      continue;
    }
    if (hidden) continue;
    n += line.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }
  return n;
}

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
  var total = 0;
  for (final f in files) {
    final n = count(f.readAsStringSync().split('\n'));
    total += n;
    stdout.writeln('$n ${f.path}');
  }
  stdout.writeln('total $total');
}
