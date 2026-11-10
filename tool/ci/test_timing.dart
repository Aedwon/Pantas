// Reads a `flutter test --file-reporter json:<path>` file and reports, per
// test file, the load time and the run time, plus every test identity
// (suite path, test name, outcome, skip). CI speed plan S0/S1:
// docs/superpowers/plans/2026-11-08-ci-speed.md.
//
// Usage:
//   dart run tool/ci/test_timing.dart <reporter.json>... \
//     [--timing out.json] [--identities out.tsv] [--root <dir>] [--top 10]
//
// Only dart:core, dart:convert and dart:io are used, so it runs without
// `pub get`.
import 'dart:convert';
import 'dart:io';

/// Time spent on one test file, in milliseconds.
class FileTiming {
  FileTiming(this.path);

  final String path;
  int loadMs = 0;
  int runMs = 0;

  int get totalMs => loadMs + runMs;
}

/// One reported test: where it lives, what it is called and how it ended.
class TestIdentity {
  const TestIdentity({
    required this.path,
    required this.name,
    required this.outcome,
    required this.skipped,
  });

  final String path;
  final String name;
  final String outcome;
  final bool skipped;

  /// One tab-separated line. Tabs and newlines inside a name are escaped, so
  /// the line splits back into exactly four columns.
  String toLine() =>
      '$path\t${_escape(name)}\t$outcome\t${skipped ? 'skipped' : 'ran'}';
}

class TimingReport {
  final Map<String, FileTiming> files = <String, FileTiming>{};
  final List<TestIdentity> identities = <TestIdentity>[];

  int get testCount => identities.length;

  List<FileTiming> slowest(int count) {
    final sorted = files.values.toList()
      ..sort((a, b) {
        final byTime = b.totalMs.compareTo(a.totalMs);
        return byTime != 0 ? byTime : a.path.compareTo(b.path);
      });
    return sorted.take(count).toList();
  }

  Map<String, Object?> toTimingJson() {
    final paths = files.keys.toList()..sort();
    return <String, Object?>{
      'files': <String, Object?>{
        for (final path in paths)
          path: <String, int>{
            'load_ms': files[path]!.loadMs,
            'run_ms': files[path]!.runMs,
            'total_ms': files[path]!.totalMs,
          },
      },
    };
  }

  /// Sorted, so two runs of the same suite give identical text.
  String toIdentityText() {
    final lines = identities.map((i) => i.toLine()).toList()..sort();
    return lines.isEmpty ? '' : '${lines.join('\n')}\n';
  }
}

String _escape(String text) => text
    .replaceAll(r'\', r'\\')
    .replaceAll('\t', r'\t')
    .replaceAll('\n', r'\n')
    .replaceAll('\r', r'\r');

/// Turns the JSON reporter's lines into a [TimingReport].
///
/// [root] is stripped from absolute suite paths so a local run and a CI run
/// name the same file the same way. Lines that are not JSON are ignored.
TimingReport analyzeReporterLines(Iterable<String> lines, {String? root}) {
  final report = TimingReport();
  final suitePaths = <int, String>{};
  final tests = <int, _OpenTest>{};

  for (final line in lines) {
    final text = line.trim();
    if (!text.startsWith('{')) continue;
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      continue;
    }
    if (decoded is! Map<String, Object?>) continue;

    switch (decoded['type']) {
      case 'suite':
        final suite = decoded['suite'];
        if (suite is Map<String, Object?>) {
          final id = suite['id'];
          final path = suite['path'];
          if (id is int && path is String) {
            suitePaths[id] = _relative(path, root);
          }
        }
      case 'testStart':
        final test = decoded['test'];
        final time = decoded['time'];
        if (test is Map<String, Object?> && time is int) {
          final id = test['id'];
          final suiteId = test['suiteID'];
          final name = test['name'];
          if (id is int && suiteId is int && name is String) {
            tests[id] = _OpenTest(suiteId: suiteId, name: name, startMs: time);
          }
        }
      case 'testDone':
        final id = decoded['testID'];
        final time = decoded['time'];
        final open = id is int ? tests.remove(id) : null;
        if (open == null || time is! int) break;
        final suitePath = suitePaths[open.suiteId];
        if (suitePath == null) break;
        final elapsed = time - open.startMs;
        if (_loadingEntry.hasMatch(open.name)) {
          report.files
              .putIfAbsent(suitePath, () => FileTiming(suitePath))
              .loadMs += elapsed;
          break;
        }
        // A test in a bundle (tool/ci/bundle_tests.dart) is named
        // "<member path> <name>". Report it under the member's path and its
        // own name, so identities match a run of the single files.
        var path = suitePath;
        var name = open.name;
        if (suitePath.startsWith(_bundlePrefix)) {
          final member = _bundleMember.firstMatch(open.name);
          if (member != null) {
            path = member.group(1)!;
            name = member.group(2) ?? '';
          }
        }
        final timing = report.files.putIfAbsent(path, () => FileTiming(path));
        timing.runMs += elapsed;
        // Hidden entries are setUpAll and tearDownAll. Their time counts,
        // but they are not tests.
        if (decoded['hidden'] == true) break;
        report.identities.add(
          TestIdentity(
            path: path,
            name: name,
            outcome: decoded['result'] as String? ?? 'unknown',
            skipped: decoded['skipped'] == true,
          ),
        );
    }
  }
  return report;
}

/// The reporter's own entry for loading a suite: "loading <path>.dart". A
/// real test whose name starts with "loading " is not one of these.
final _loadingEntry = RegExp(r'^loading \S+\.dart$');

const _bundlePrefix = 'build/test_bundles/';

/// A bundled test's name: the member path, then the rest. A hidden setUpAll
/// or tearDownAll of a member has the path and "(setUpAll)" after it.
final _bundleMember = RegExp(r'^(test/\S+\.dart)(?: (.*))?$', dotAll: true);

class _OpenTest {
  _OpenTest({required this.suiteId, required this.name, required this.startMs});

  final int suiteId;
  final String name;
  final int startMs;
}

String _relative(String path, String? root) {
  var normalized = path.replaceAll(r'\', '/');
  if (normalized.startsWith('file://')) {
    normalized = Uri.parse(normalized).toFilePath();
  }
  if (root != null) {
    final base = root.replaceAll(r'\', '/').replaceAll(RegExp(r'/+$'), '');
    if (normalized.startsWith('$base/')) {
      return normalized.substring(base.length + 1);
    }
  }
  return normalized;
}

void main(List<String> args) {
  final inputs = <String>[];
  String? timingPath;
  String? identitiesPath;
  var root = Directory.current.path;
  var top = 10;

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--timing':
        timingPath = args[++i];
      case '--identities':
        identitiesPath = args[++i];
      case '--root':
        root = args[++i];
      case '--top':
        top = int.parse(args[++i]);
      default:
        inputs.add(args[i]);
    }
  }
  if (inputs.isEmpty) {
    stderr.writeln(
      'usage: test_timing.dart <reporter.json>... '
      '[--timing out.json] [--identities out.tsv] [--root dir] [--top n]',
    );
    exit(64);
  }

  final report = TimingReport();
  for (final input in inputs) {
    final part = analyzeReporterLines(
      File(input).readAsLinesSync(),
      root: root,
    );
    for (final entry in part.files.entries) {
      report.files.putIfAbsent(entry.key, () => FileTiming(entry.key))
        ..loadMs += entry.value.loadMs
        ..runMs += entry.value.runMs;
    }
    report.identities.addAll(part.identities);
  }

  if (timingPath != null) {
    File(timingPath).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(report.toTimingJson())}\n',
    );
  }
  if (identitiesPath != null) {
    File(identitiesPath).writeAsStringSync(report.toIdentityText());
  }

  final skipped = report.identities.where((i) => i.skipped).length;
  stdout
    ..writeln(
      'files: ${report.files.length}  tests: ${report.testCount}  '
      'skipped: $skipped',
    )
    ..writeln('slowest $top files (load + run, seconds):');
  for (final file in report.slowest(top)) {
    stdout.writeln(
      '  ${(file.totalMs / 1000).toStringAsFixed(1).padLeft(7)}  '
      '(load ${(file.loadMs / 1000).toStringAsFixed(1)}, '
      'run ${(file.runMs / 1000).toStringAsFixed(1)})  ${file.path}',
    );
  }
}
