// Bundles the test files of one CI shard into a few entry files, so the shard
// compiles and loads a handful of entry points instead of one per file.
// CI speed plan S8: docs/superpowers/plans/2026-11-08-ci-speed.md.
//
// Usage:
//   dart tool/ci/bundle_tests.dart --shard K [--shards 8] [--bundles 4]
//       writes build/test_bundles/shardK_bundleN_test.dart and prints the
//       entry points to run, one per line: the bundles, then the single files
//   dart tool/ci/bundle_tests.dart --check [--shards 8] [--bundles 4]
//       checks that every test file runs exactly once across all shards,
//       bundled or single
//   dart tool/ci/bundle_tests.dart --report [--shards 8]
//       lists the files kept out of bundles, with the reason
//
// A bundle imports each member's `main` and runs it inside a group named by
// the member's path, so a test is named "<path> <old name>". The identity
// report in test_timing.dart maps that back to the path and the old name.
//
// Files stay single, outside every bundle, when they could change what a
// neighbor sees: they start processes, set global state, carry a library
// annotation such as @TestOn, or do not have a plain `void main()`. The
// per-reason patterns are below. tool/ci/bundle_excludes.txt adds files that
// were found to interfere on CI, one `path  reason` per line.
//
// Only dart:core, dart:convert and dart:io are used, so it runs without
// `pub get`.
import 'dart:io';

import 'shard_tests.dart';

const _defaultBundles = 4;
const _bundleDir = 'build/test_bundles';
const _excludesPath = 'tool/ci/bundle_excludes.txt';

/// Why a file must stay outside a bundle. Checked in order; the first hit is
/// the reason. Each is a regular expression over the file's source.
final Map<String, RegExp> _reasons = <String, RegExp>{
  'library annotation':
      RegExp(r'^@(TestOn|Tags|Timeout|Skip)\b', multiLine: true),
  'starts a process': RegExp(r'\bProcess\.(run|runSync|start)\b|\bProcess\b'),
  'sets the target platform': RegExp('debugDefaultTargetPlatformOverride'),
  'sets FlutterError handlers': RegExp(r'FlutterError\.(onError|presentError)'),
  'sets HttpOverrides': RegExp('HttpOverrides'),
  'mocks a method channel': RegExp(
    'setMockMethodCallHandler|setMockMessageHandler|setMockStreamHandler|'
    'TestDefaultBinaryMessengerBinding',
  ),
  'changes the working directory or exits': RegExp(
    r'Directory\.current\s*=|\bexit\(',
  ),
  'reads the environment': RegExp(r'Platform\.environment'),
  'loads fonts into the shared engine':
      RegExp('FontLoader|loadFont|GoogleFonts'),
  'compares golden files by path': RegExp(
    'matchesGoldenFile|goldenFileComparator|autoUpdateGoldenFiles',
  ),
  'sets other global state': RegExp(
    r'debugPrint\s*=|Intl\.defaultLocale\s*=|timeDilation\s*=|runZoned|'
    r'SharedPreferences\.setMock|PlatformDispatcher\.instance',
  ),
};

/// The reason [source] has to stay a single file, or null when it can join a
/// bundle.
String? singleReason(String source) {
  if (!RegExp(r'^void main\(\) ', multiLine: true).hasMatch(source)) {
    return 'not a plain void main()';
  }
  for (final entry in _reasons.entries) {
    if (entry.value.hasMatch(source)) return entry.key;
  }
  return null;
}

/// `path  reason` lines of [_excludesPath], as a map.
Map<String, String> readExcludes() {
  final file = File(_excludesPath);
  if (!file.existsSync()) return <String, String>{};
  final result = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    final text = line.trim();
    if (text.isEmpty || text.startsWith('#')) continue;
    final split = text.indexOf(RegExp(r'\s'));
    result[split < 0 ? text : text.substring(0, split)] =
        split < 0 ? 'listed' : text.substring(split).trim();
  }
  return result;
}

/// One shard's plan: files per bundle, and the files that run alone.
class ShardPlan {
  ShardPlan(this.bundles, this.singles);

  final List<List<String>> bundles;
  final List<String> singles;

  Iterable<String> get allFiles => [...bundles.expand((b) => b), ...singles];
}

/// Splits one shard's [files] into [bundleCount] balanced bundles and singles.
/// [reasonOf] says why a file must stay single, or null.
ShardPlan planShard(
  List<String> files,
  Map<String, double> timings,
  int bundleCount,
  String? Function(String file) reasonOf,
) {
  final singles = <String>[];
  final joinable = <String>[];
  for (final file in files) {
    (reasonOf(file) == null ? joinable : singles).add(file);
  }
  final median = medianOf(timings.values);
  double timeOf(String f) => timings[f] ?? median;
  joinable.sort((a, b) {
    final byTime = timeOf(b).compareTo(timeOf(a));
    return byTime != 0 ? byTime : a.compareTo(b);
  });
  final bundles = List<List<String>>.generate(bundleCount, (_) => <String>[]);
  final loads = List<double>.filled(bundleCount, 0);
  for (final file in joinable) {
    var lightest = 0;
    for (var i = 1; i < bundleCount; i++) {
      if (loads[i] < loads[lightest]) lightest = i;
    }
    bundles[lightest].add(file);
    loads[lightest] += timeOf(file);
  }
  for (final bundle in bundles) {
    bundle.sort();
  }
  singles.sort();
  return ShardPlan(bundles.where((b) => b.isNotEmpty).toList(), singles);
}

/// The source of one bundle entry file written to [_bundleDir].
String bundleSource(List<String> members) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED by tool/ci/bundle_tests.dart. Do not edit.')
    ..writeln('// ignore_for_file: type=lint')
    ..writeln("import 'package:flutter_test/flutter_test.dart';");
  for (var i = 0; i < members.length; i++) {
    buffer.writeln("import '../../${members[i]}' as t$i;");
  }
  buffer.writeln('\nvoid main() {');
  for (var i = 0; i < members.length; i++) {
    buffer.writeln("  group('${members[i]}', t$i.main);");
  }
  buffer.writeln('}');
  return buffer.toString();
}

void main(List<String> args) {
  int? shard;
  var shards = 8;
  var bundles = _defaultBundles;
  var check = false;
  var report = false;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--shard':
        shard = int.parse(args[++i]);
      case '--shards':
        shards = int.parse(args[++i]);
      case '--bundles':
        bundles = int.parse(args[++i]);
      case '--check':
        check = true;
      case '--report':
        report = true;
      default:
        stderr.writeln('unknown argument: ${args[i]}');
        exit(64);
    }
  }
  if (!check && !report && (shard == null || shard < 0 || shard >= shards)) {
    stderr.writeln('give --shard K, --check or --report');
    exit(64);
  }
  if (Directory('test')
      .listSync(recursive: true)
      .any((e) => e is File && e.path.endsWith('flutter_test_config.dart'))) {
    stderr.writeln('A flutter_test_config.dart exists under test/. A bundle '
        'lives outside test/ and would not run it. Keep the bundles in step.');
    exit(1);
  }

  final root = Directory.current;
  final files = listTestFiles(root);
  final timings = readTimings('tool/ci/test_timings.json');
  final split = assignShards(files, timings, shards);
  final excludes = readExcludes();
  final reasons = <String, String?>{
    for (final file in files)
      file: excludes[file] ?? singleReason(File(file).readAsStringSync()),
  };
  String? reasonOf(String file) => reasons[file];

  if (report) {
    final kept = reasons.entries.where((e) => e.value != null).toList();
    final byReason = <String, int>{};
    for (final e in kept) {
      byReason[e.value!] = (byReason[e.value!] ?? 0) + 1;
    }
    stdout.writeln('${files.length} files, ${kept.length} kept single, '
        '${files.length - kept.length} bundleable');
    byReason.forEach((r, n) => stdout.writeln('  $n  $r'));
    for (final e in kept) {
      stdout.writeln('${e.key}\t${e.value}');
    }
    return;
  }

  final plans = [
    for (final shardFiles in split)
      planShard(shardFiles, timings, bundles, reasonOf),
  ];

  if (check) {
    final seen = <String, int>{};
    final problems = <String>[];
    for (var s = 0; s < plans.length; s++) {
      for (final file in plans[s].allFiles) {
        final earlier = seen[file];
        if (earlier != null) {
          problems.add('$file runs in shard $earlier and shard $s');
        }
        seen[file] = s;
      }
    }
    for (final file in files.toSet().difference(seen.keys.toSet())) {
      problems.add('$file runs nowhere');
    }
    for (final file in seen.keys.toSet().difference(files.toSet())) {
      problems.add('$file runs but is not a test file');
    }
    final bundled = plans.fold<int>(
      0,
      (sum, p) => sum + p.bundles.fold<int>(0, (s, b) => s + b.length),
    );
    final singles = plans.fold<int>(0, (sum, p) => sum + p.singles.length);
    stdout.writeln('${files.length} files: $bundled bundled, $singles single');
    if (problems.isEmpty) {
      stdout.writeln('bundle partition ok');
      return;
    }
    problems
      ..sort()
      ..forEach(stderr.writeln);
    exit(1);
  }

  final plan = plans[shard!];
  Directory(_bundleDir).createSync(recursive: true);
  final entries = <String>[];
  for (var i = 0; i < plan.bundles.length; i++) {
    final path = '$_bundleDir/shard${shard}_bundle${i}_test.dart';
    File(path).writeAsStringSync(bundleSource(plan.bundles[i]));
    entries.add(path);
  }
  entries.addAll(plan.singles);
  stdout.write('${entries.join('\n')}\n');
}
