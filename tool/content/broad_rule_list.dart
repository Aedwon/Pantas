// Lists the teaching sentences that may state a rule more broadly than the
// lesson shows, for a verifier to judge. It is not a gate: it exits 0 unless
// its arguments are wrong.
//
//   dart run tool/content/broad_rule_list.dart --root <content dir>
//       [--lesson <path relative to lessons/>]...
//
// With --lesson, only those lessons. Without, every active walk-through lesson.
// One line per hit: `<lesson path>:<line> | <word> | <sentence>`.
//
// Origin: Nov 27 process entry "Grammar walk-through lessons fail every
// outside audit round": Language Application passed the pre-check and then
// failed the outside audit with 18 over-broad rules. The listed words
// over-include on purpose.
// A rule stated without any of them (for example "Add a comma when the
// dependent clause comes first") is not found; only a reader finds that.
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final _frontmatterPattern = RegExp(r'^---\r?\n[\s\S]*?\r?\n---(?:\r?\n|$)');
final _commentPattern = RegExp(r'<!--[\s\S]*?-->');
final _mathPattern = RegExp(r'\$\$([\s\S]+?)\$\$|\$([^$\n]+?)\$');
final _blockPattern = RegExp('^:::[a-z]', multiLine: true);
final _choiceLinePattern = RegExp(
  r'^\s*(?:[-*]\s+)?(?:\(([A-Ea-e])\)|([A-Ea-e])[.)])\s',
);
final _anchorPattern = RegExp(r'\s*\{#[^\s}]+\}\s*$');
final _listMarkerPattern = RegExp(r'^(?:[-*+]\s+|\d+\.\s+)');

/// Listed words, English then Filipino. `hindi kailanman` is tried before
/// `kailanman` so the phrase is reported once.
final _wordPattern = RegExp(
  r'(?<![\p{L}])(hindi kailanman|every|always|never|only|all|any|none|'
  'whenever|no|means|lahat|palagi|laging|kailanman|tanging|lamang|wala)'
  r'(?![\p{L}])',
  caseSensitive: false,
  unicode: true,
);

/// One teaching sentence that holds a listed word.
class BroadRuleHit {
  BroadRuleHit(this.path, this.line, this.word, this.sentence);
  final String path;
  final int line;
  final String word;
  final String sentence;

  @override
  String toString() => '$path:$line | $word | $sentence';
}

/// Hits in one lesson's [markdown]. Line numbers are file lines. [path] is
/// printed as given.
List<BroadRuleHit> broadRuleHits(String path, String markdown) {
  final fm = _frontmatterPattern.firstMatch(markdown);
  final blanked = markdown.replaceAllMapped(
    _commentPattern,
    (m) => m.group(0)!.replaceAll(RegExp(r'[^\n]'), ' '),
  );
  final bodyStart = fm?.end ?? 0;
  final lineOffset = '\n'.allMatches(blanked.substring(0, bodyStart)).length;
  final lines = blanked.substring(bodyStart).split('\n');

  final hits = <BroadRuleHit>[];
  var block = ''; // '', stem, answer, why, pair, checklist, other
  var inExamples = false;
  var exampleStem = false;
  var inDisplayMath = false;

  for (var i = 0; i < lines.length; i++) {
    final raw = lines[i].replaceAll('\r', '');
    final trimmed = raw.trim();
    final number = i + 1 + lineOffset;

    if (inDisplayMath) {
      if (trimmed.endsWith(r'$$')) inDisplayMath = false;
      continue;
    }
    if (trimmed.startsWith(':::')) {
      if (trimmed == ':::') {
        block = '';
      } else {
        final name = trimmed.substring(3).split(RegExp(r'\s')).first;
        block = switch (name) {
          'check' || 'try' => 'stem',
          'answer' => 'answer',
          'why' => 'why',
          'pair' => 'pair',
          'checklist' => 'checklist',
          _ => 'other',
        };
      }
      continue;
    }
    if (trimmed.isEmpty) continue;
    if (trimmed.startsWith('#')) {
      if (trimmed.startsWith('## ')) {
        inExamples = RegExp(r'^##\s+Examples\s*$').hasMatch(trimmed);
        exampleStem = false;
      } else if (trimmed.startsWith('### ') && inExamples) {
        exampleStem = true;
      }
      continue;
    }
    if (trimmed.startsWith(r'$$')) {
      if (trimmed == r'$$' || !trimmed.endsWith(r'$$') || trimmed.length < 4) {
        inDisplayMath = true;
      }
      continue;
    }
    if (trimmed.startsWith('**Solution')) {
      exampleStem = false;
      continue;
    }
    if (block == 'stem' || exampleStem) continue;
    if (_choiceLinePattern.hasMatch(raw)) continue;
    if (RegExp(r'^(?:Right|Wrong)\s*:').hasMatch(trimmed)) continue;

    var text = trimmed;
    if (block == 'checklist') text = text.replaceFirst(_anchorPattern, '');
    text = text.replaceFirst(_listMarkerPattern, '');
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    for (final sentence in sentences) {
      final words = <String>{};
      final plain = sentence.replaceAll(_mathPattern, ' ');
      for (final match in _wordPattern.allMatches(plain)) {
        words.add(match.group(1)!.toLowerCase());
      }
      for (final word in words) {
        hits.add(BroadRuleHit(path, number, word, sentence.trim()));
      }
    }
  }
  return hits;
}

const _usage = 'Usage: dart run tool/content/broad_rule_list.dart '
    '--root <content dir> [--lesson <relative path>]...';

bool _isActiveWalkthrough(String source) {
  final fm = _frontmatterPattern.firstMatch(source);
  if (fm == null) return false;
  try {
    final front = loadYaml(
      fm.group(0)!.replaceFirst(RegExp(r'^---\r?\n'), '').replaceFirst(
            RegExp(r'\r?\n---(?:\r?\n|$)'),
            '',
          ),
    );
    if (front is YamlMap && front['status'] == 'retired') return false;
  } on Object {
    // A front matter this tool cannot read is the lesson checks' business.
  }
  return _blockPattern.hasMatch(source.substring(fm.end));
}

/// Runs the list. Writes hits to [out] and problems to [err]. Returns the exit
/// code: 0 unless the arguments are wrong.
int runBroadRuleList(List<String> args, StringSink out, StringSink err) {
  String? root;
  final named = <String>[];
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--root' && i + 1 < args.length) {
      root = args[++i];
    } else if (args[i] == '--lesson' && i + 1 < args.length) {
      named.add(args[++i]);
    } else {
      err.writeln(_usage);
      return 2;
    }
  }
  if (root == null || !Directory(root).existsSync()) {
    err.writeln(_usage);
    return 2;
  }
  final lessons = Directory(p.join(root, 'lessons'));
  if (!lessons.existsSync()) {
    err.writeln('No lessons directory under $root.\n$_usage');
    return 2;
  }

  final files = <File>[];
  if (named.isEmpty) {
    files
      ..addAll(
        lessons
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.md')),
      )
      ..sort((a, b) => a.path.compareTo(b.path));
  } else {
    for (final name in named) {
      final candidates = [
        File(p.join(lessons.path, name)),
        File(p.join(root, name)),
      ];
      final found = candidates.where((file) => file.existsSync()).toList();
      if (found.isEmpty) {
        err.writeln('Lesson not found: $name\n$_usage');
        return 2;
      }
      files.add(found.first);
    }
  }

  for (final file in files) {
    final source = file.readAsStringSync();
    if (named.isEmpty && !_isActiveWalkthrough(source)) continue;
    final path = p.relative(file.path, from: lessons.path);
    for (final hit in broadRuleHits(path, source)) {
      out.writeln(hit);
    }
  }
  return 0;
}

void main(List<String> args) {
  exitCode = runBroadRuleList(args, stdout, stderr);
}
