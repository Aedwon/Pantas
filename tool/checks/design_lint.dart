// The design lint ratchet. Run from the project root:
//
//   dart run tool/checks/design_lint.dart            compare with the baseline
//   dart run tool/checks/design_lint.dart --update   rewrite the baseline
//
// It runs `dart analyze --format=machine`, keeps the `ds_` diagnostics of the
// design lint plugin (`tool/lints`) and compares the count per file and rule
// with `tool/lints/baseline.txt`. A line of the baseline reads
// `count path rule`, sorted, with no line numbers so edits above a finding
// do not change it.
//
// It fails when a count rises or a new file and rule appears. It also fails
// when a count falls, so the baseline only ever shrinks: refresh it with
// `--update` in the same change that fixed the finding. A finding in
// `lib/core/` or `tool/` always fails, because those have no baseline.
//
// Known limit: counts are per file and rule, so a fix and a new finding in the
// same file and rule cancel out. The baseline cannot tell them apart.
//
// Canary: `test/tool/fixtures/design_lint_canary.dart` holds one known
// `ds_no_design_literal` finding. The run fails with "plugin did not load"
// when it is missing, and the canary is left out of the counts.
//
// `--update` refuses when the canary is missing, and when the total of any
// rule rises against the current baseline (a rename keeps the total). With no
// baseline file yet it writes one, which is also how to rebuild it after the
// rules widen: delete the file, run `--update`, review the diff.
//
// This must run through `dart analyze`. `flutter analyze` stops before the
// plugin reports, so it never shows these diagnostics.
import 'dart:io';

const baselinePath = 'tool/lints/baseline.txt';
const canaryPath = 'test/tool/fixtures/design_lint_canary.dart';
const refreshCommand = 'dart run tool/checks/design_lint.dart --update';

/// One design lint diagnostic: project-relative [path], rule name, and its
/// position (used only to drop duplicates).
class DesignFinding {
  const DesignFinding(this.path, this.rule, this.line, this.column);

  final String path;
  final String rule;
  final int line;
  final int column;
}

/// The `ds_` findings in the output of `dart analyze --format=machine`, with
/// duplicates removed. Paths are made relative to [root].
List<DesignFinding> parseMachineOutput(String output, String root) {
  final seen = <String>{};
  final found = <DesignFinding>[];
  final prefix = root.endsWith('/') ? root : '$root/';
  for (final line in output.split('\n')) {
    final parts = line.split('|');
    if (parts.length < 8) continue;
    final rule = parts[2].toLowerCase();
    if (!rule.startsWith('ds_')) continue;
    var path = parts[3].replaceAll(r'\', '/');
    if (path.startsWith(prefix)) path = path.substring(prefix.length);
    final row = int.tryParse(parts[4]) ?? 0;
    final column = int.tryParse(parts[5]) ?? 0;
    if (!seen.add('$path:$row:$column:$rule:${parts.sublist(7).join('|')}')) {
      continue;
    }
    found.add(DesignFinding(path, rule, row, column));
  }
  return found;
}

/// Whether the plugin reported the canary's finding.
bool hasCanary(List<DesignFinding> findings) => findings.any(
      (f) => f.path == canaryPath && f.rule == 'ds_no_design_literal',
    );

List<DesignFinding> withoutCanary(List<DesignFinding> findings) => [
      for (final f in findings)
        if (f.path != canaryPath) f,
    ];

/// Why `--update` must refuse: the total of a rule rose against [baseline].
List<String> updateProblems(
  Map<String, int> baseline,
  Map<String, int> current,
) {
  Map<String, int> totals(Map<String, int> counts) {
    final out = <String, int>{};
    counts.forEach((key, count) {
      final rule = key.substring(key.indexOf(' ') + 1);
      out[rule] = (out[rule] ?? 0) + count;
    });
    return out;
  }

  final before = totals(baseline);
  final now = totals(current);
  return [
    for (final rule in now.keys.toList()..sort())
      if (now[rule]! > (before[rule] ?? 0))
        '$rule rose from ${before[rule] ?? 0} to ${now[rule]}',
  ];
}

/// Counts per `path rule` key.
Map<String, int> countFindings(Iterable<DesignFinding> findings) {
  final counts = <String, int>{};
  for (final finding in findings) {
    final key = '${finding.path} ${finding.rule}';
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

/// `count path rule` lines, sorted by path then rule.
String formatBaseline(Map<String, int> counts) {
  final keys = counts.keys.toList()..sort();
  return [for (final key in keys) '${counts[key]} $key', ''].join('\n');
}

Map<String, int> parseBaseline(String text) {
  final counts = <String, int>{};
  for (final raw in text.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final space = line.indexOf(' ');
    final count = int.tryParse(line.substring(0, space));
    if (space < 0 || count == null) {
      throw FormatException('Bad baseline line: $line');
    }
    counts[line.substring(space + 1)] = count;
  }
  return counts;
}

bool _alwaysFails(String path) =>
    path.startsWith('lib/core/') || path.startsWith('tool/');

/// Problems that make the run fail; empty when the counts match the baseline.
List<String> compareWithBaseline(
  Map<String, int> baseline,
  Map<String, int> current,
) {
  final problems = <String>[];
  var fell = false;
  for (final key in {...baseline.keys, ...current.keys}.toList()..sort()) {
    final before = baseline[key] ?? 0;
    final now = current[key] ?? 0;
    final path = key.substring(0, key.indexOf(' '));
    if (_alwaysFails(path) && now > 0) {
      problems.add('$key: $now finding(s) in a folder that must be clean');
    } else if (now > before) {
      problems.add(
        before == 0
            ? '$key: new, $now finding(s)'
            : '$key: rose from $before to $now',
      );
    } else if (now < before) {
      fell = true;
      problems.add('$key: fell from $before to $now');
    }
  }
  if (fell) {
    problems.add(
      'The baseline only shrinks. Refresh it with `$refreshCommand` and '
      'commit it.',
    );
  }
  return problems;
}

Future<void> main(List<String> args) async {
  if (!Directory('lib').existsSync()) {
    stderr.writeln('lib/ not found; run from the project root.');
    exit(2);
  }
  final root = Directory.current.path;
  final watch = Stopwatch()..start();
  final result = await Process.run('dart', ['analyze', '--format=machine']);
  // 0 clean, 1 infos, 2 warnings, 3 errors. Anything else means it broke.
  if (result.exitCode > 3) {
    stderr
      ..writeln('dart analyze failed (exit ${result.exitCode}):')
      ..writeln(result.stderr);
    exit(2);
  }
  final all = parseMachineOutput('${result.stdout}\n${result.stderr}', root);
  if (!hasCanary(all)) {
    stdout
      ..writeln('FAIL  design-lint: plugin did not load')
      ..writeln(
        '      The canary finding in $canaryPath was not reported, so a '
        'clean result would mean nothing. Use `dart analyze`, not '
        '`flutter analyze`.',
      );
    exit(1);
  }
  final findings = withoutCanary(all);
  final current = countFindings(findings);
  watch.stop();

  if (args.contains('--update')) {
    final bad = current.keys.where((k) => _alwaysFails(k.split(' ').first));
    if (bad.isNotEmpty) {
      stderr.writeln(
        'Not written: lib/core and tool must be clean.\n${bad.join('\n')}',
      );
      exit(1);
    }
    final existing = File('$root/$baselinePath');
    final rises = existing.existsSync()
        ? updateProblems(parseBaseline(existing.readAsStringSync()), current)
        : const <String>[];
    if (rises.isNotEmpty) {
      stderr.writeln(
        'Not written: the baseline only shrinks.\n${rises.join('\n')}',
      );
      exit(1);
    }
    existing.writeAsStringSync(formatBaseline(current));
    stdout.writeln(
      'Wrote $baselinePath: ${current.length} line(s), '
      '${findings.length} finding(s).',
    );
    return;
  }

  final file = File('$root/$baselinePath');
  final baseline = file.existsSync()
      ? parseBaseline(file.readAsStringSync())
      : <String, int>{};
  final problems = compareWithBaseline(baseline, current);
  if (problems.isEmpty) {
    stdout.writeln(
      'OK    design-lint: ${findings.length} finding(s) match the baseline '
      '(${watch.elapsed.inSeconds}s)',
    );
    return;
  }
  stdout.writeln('FAIL  design-lint');
  for (final problem in problems) {
    stdout.writeln('      $problem');
  }
  exit(1);
}
