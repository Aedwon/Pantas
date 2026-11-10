// Splits the test files into shards for CI by file, balanced on recorded
// times. CI speed plan S1: docs/superpowers/plans/2026-11-08-ci-speed.md.
//
// Usage:
//   dart run tool/ci/shard_tests.dart --shard K [--shards 8]
//       prints the files of shard K, one per line
//   dart run tool/ci/shard_tests.dart --check [--shards 8]
//       checks that the shards partition the test files exactly
//
// Times come from tool/ci/test_timings.json (written by test_timing.dart).
// A file with no recorded time gets the median of the recorded ones.
// Refresh the file when the slowest shard is more than 20% over the mean.
//
// Only dart:core, dart:convert and dart:io are used, so it runs without
// `pub get`.
import 'dart:convert';
import 'dart:io';

const _defaultShards = 8;
const _timingsPath = 'tool/ci/test_timings.json';

/// Goldens run in their own job, so the shards leave them out.
const _goldenPrefix = 'test/goldens/';

/// The longest file list a shell can pass safely. Linux allows about 2 MB.
/// The upgrade path past this limit is a generated bundle file per shard.
const _maxArgumentBytes = 1000000;

/// Every test file under [testDir], as sorted paths relative to [root] with
/// forward slashes, excluding goldens.
List<String> listTestFiles(Directory root, {String testDir = 'test'}) {
  final base = Directory('${root.path}/$testDir');
  if (!base.existsSync()) return <String>[];
  final prefix = root.path.endsWith('/') ? root.path : '${root.path}/';
  final files = <String>[];
  for (final entity in base.listSync(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('_test.dart')) continue;
    final relative = entity.path
        .replaceAll(r'\', '/')
        .replaceFirst(prefix.replaceAll(r'\', '/'), '');
    if (relative.startsWith(_goldenPrefix)) continue;
    files.add(relative);
  }
  files.sort();
  return files;
}

/// The median of [values], or [fallback] when there are none.
double medianOf(Iterable<double> values, {double fallback = 1}) {
  final sorted = values.toList()..sort();
  if (sorted.isEmpty) return fallback;
  final middle = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[middle]
      : (sorted[middle - 1] + sorted[middle]) / 2;
}

/// Longest processing time first. Deterministic: ties break on path for the
/// order of files and on the lower index for the choice of shard.
///
/// [timings] maps a path to seconds. Returns [shardCount] sorted lists.
List<List<String>> assignShards(
  List<String> files,
  Map<String, double> timings,
  int shardCount,
) {
  final median = medianOf(timings.values);
  double timeOf(String file) => timings[file] ?? median;

  final ordered = files.toSet().toList()
    ..sort((a, b) {
      final byTime = timeOf(b).compareTo(timeOf(a));
      return byTime != 0 ? byTime : a.compareTo(b);
    });

  final shards = List<List<String>>.generate(shardCount, (_) => <String>[]);
  final loads = List<double>.filled(shardCount, 0);
  for (final file in ordered) {
    var lightest = 0;
    for (var i = 1; i < shardCount; i++) {
      if (loads[i] < loads[lightest]) lightest = i;
    }
    shards[lightest].add(file);
    loads[lightest] += timeOf(file);
  }
  for (final shard in shards) {
    shard.sort();
  }
  return shards;
}

/// Reads `{"files": {path: {"total_ms": n}}}` into seconds per path.
Map<String, double> readTimings(String path) {
  final file = File(path);
  if (!file.existsSync()) return <String, double>{};
  final decoded = jsonDecode(file.readAsStringSync());
  final files = (decoded as Map<String, Object?>)['files'];
  final result = <String, double>{};
  if (files is Map<String, Object?>) {
    for (final entry in files.entries) {
      final value = entry.value;
      if (value is Map<String, Object?> && value['total_ms'] is num) {
        result[entry.key] = (value['total_ms']! as num) / 1000;
      }
    }
  }
  return result;
}

/// Problems with a split, empty when it is a valid partition of [files].
List<String> checkPartition(List<String> files, List<List<String>> shards) {
  final problems = <String>[];
  final seen = <String, int>{};
  for (var i = 0; i < shards.length; i++) {
    if (shards[i].isEmpty) problems.add('shard $i is empty');
    for (final file in shards[i]) {
      final earlier = seen[file];
      if (earlier != null) {
        problems.add('$file is in shard $earlier and shard $i');
      }
      seen[file] = i;
    }
  }
  final expected = files.toSet();
  for (final file in expected.difference(seen.keys.toSet())) {
    problems.add('$file is in no shard');
  }
  for (final file in seen.keys.toSet().difference(expected)) {
    problems.add('$file is in a shard but not in the file list');
  }
  return problems..sort();
}

void main(List<String> args) {
  int? shard;
  var shards = _defaultShards;
  var check = false;
  var timingsPath = _timingsPath;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--shard':
        shard = int.parse(args[++i]);
      case '--shards':
        shards = int.parse(args[++i]);
      case '--timings':
        timingsPath = args[++i];
      case '--check':
        check = true;
      default:
        stderr.writeln('unknown argument: ${args[i]}');
        exit(64);
    }
  }
  if (!check && (shard == null || shard < 0 || shard >= shards)) {
    stderr.writeln('give --shard K with 0 <= K < $shards, or --check');
    exit(64);
  }

  final files = listTestFiles(Directory.current);
  final split = assignShards(files, readTimings(timingsPath), shards);

  if (check) {
    exit(_runCheck(files, split));
  }

  final mine = split[shard!];
  if (mine.isEmpty) {
    stderr.writeln('shard $shard has no test files');
    exit(1);
  }
  final bytes = mine.fold<int>(0, (sum, file) => sum + file.length + 1);
  if (bytes > _maxArgumentBytes) {
    stderr.writeln('shard $shard file list is $bytes bytes, over the safe '
        'command-line limit of $_maxArgumentBytes');
    exit(1);
  }
  stdout.write('${mine.join('\n')}\n');
}

int _runCheck(List<String> files, List<List<String>> split) {
  final problems = checkPartition(files, split);

  // Goldens run in their own job. If golden test files exist, that job has
  // to exist and name them, or they would run nowhere.
  final goldenDir = Directory('test/goldens');
  final hasGoldens = goldenDir.existsSync() &&
      goldenDir
          .listSync(recursive: true)
          .any((e) => e is File && e.path.endsWith('_test.dart'));
  if (hasGoldens) {
    final workflow = File('.github/workflows/ci.yml').readAsStringSync();
    if (!RegExp('^  goldens:', multiLine: true).hasMatch(workflow) ||
        !workflow.contains('test/goldens')) {
      problems.add('test/goldens has test files but ci.yml has no goldens '
          'job that runs them');
    }
  }

  final sizes = split.map((s) => s.length).join(', ');
  stdout.writeln('${files.length} files in ${split.length} shards: $sizes');
  if (problems.isEmpty) {
    stdout.writeln('partition ok');
    return 0;
  }
  problems.forEach(stderr.writeln);
  return 1;
}
