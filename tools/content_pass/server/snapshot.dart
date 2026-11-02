import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Where the content comes from.
class ContentSource {
  const ContentSource.repo({required this.path, required this.ref})
      : isCheckout = false;
  const ContentSource.checkout({required this.path})
      : ref = null,
        isCheckout = true;

  final String path;
  final String? ref;
  final bool isCheckout;

  static const defaultRepo = '/Users/aedwon/Documents/Projects/Pantas';
  static const defaultRef = 'origin/content/cse-rewrite-r1';

  /// Reads `<data>/source.json`, writing the default when it is missing.
  // ignore: prefer_constructors_over_static_methods
  static ContentSource load(Directory data) {
    final file = File('${data.path}/source.json');
    if (!file.existsSync()) {
      data.createSync(recursive: true);
      file.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert({
              'repo': defaultRepo,
              'ref': defaultRef,
            })}\n',
      );
    }
    final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    final checkout = json['checkout'];
    if (checkout is String) return ContentSource.checkout(path: checkout);
    return ContentSource.repo(
      path: (json['repo'] as String?) ?? defaultRepo,
      ref: (json['ref'] as String?) ?? defaultRef,
    );
  }
}

/// A resolved version of the content, before it is built.
class ResolvedSource {
  const ResolvedSource({
    required this.key,
    required this.commit,
    required this.label,
    required this.dirty,
    required this.offline,
  });

  /// Names the snapshot folder. The same content gives the same key.
  final String key;
  final String commit;

  /// For example `cse-rewrite-r1 912a57a`, plus `with local edits`.
  final String label;
  final bool dirty;
  final bool offline;
}

class GitFailure implements Exception {
  GitFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

Future<String> _git(
  String repo,
  List<String> args, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final process = await Process.start('git', ['-C', repo, ...args]);
  final out = process.stdout.transform(utf8.decoder).join();
  final err = process.stderr.transform(utf8.decoder).join();
  final code = await process.exitCode.timeout(
    timeout,
    onTimeout: () {
      process.kill();
      return -1;
    },
  );
  if (code != 0) {
    throw GitFailure(
      'git ${args.first} failed: ${(await err).trim()}'.trim(),
    );
  }
  return (await out).trim();
}

/// Works out which version of the content the source holds right now.
Future<ResolvedSource> resolveSource(ContentSource source) async {
  if (source.isCheckout) {
    final head = await _git(source.path, ['rev-parse', 'HEAD']);
    final branch =
        await _git(source.path, ['rev-parse', '--abbrev-ref', 'HEAD']);
    final status = await _git(
      source.path,
      ['status', '--porcelain', '--', 'content', 'tools/lesson_author'],
    );
    final dirty = status.isNotEmpty;
    var key = 'co-${head.substring(0, 10)}';
    if (dirty) {
      final diff = await _git(source.path, ['diff', 'HEAD', '--', 'content']);
      final untracked = await _git(
        source.path,
        ['ls-files', '--others', '--exclude-standard', '--', 'content'],
      );
      // Untracked files count by name and size so a new file changes the key.
      final sizes = StringBuffer();
      for (final path in untracked.split('\n').where((p) => p.isNotEmpty)) {
        sizes.write('$path ${File('${source.path}/$path').lengthSync()}\n');
      }
      final digest =
          sha256.convert(utf8.encode('$diff\n$sizes\n$status')).toString();
      key = 'co-${head.substring(0, 10)}-${digest.substring(0, 10)}';
    }
    final short = head.substring(0, 7);
    return ResolvedSource(
      key: key,
      commit: head,
      label: '$branch $short${dirty ? ' with local edits' : ''}',
      dirty: dirty,
      offline: false,
    );
  }

  final ref = source.ref!;
  var offline = false;
  if (ref.startsWith('origin/')) {
    try {
      await _git(
        source.path,
        ['fetch', 'origin', ref.substring('origin/'.length)],
        timeout: const Duration(seconds: 15),
      );
    } on Object {
      offline = true;
    }
  }
  final sha = await _git(source.path, ['rev-parse', '$ref^{commit}']);
  final name = ref.replaceFirst('origin/', '').replaceFirst('content/', '');
  return ResolvedSource(
    key: sha.substring(0, 12),
    commit: sha,
    label: '$name ${sha.substring(0, 7)}',
    dirty: false,
    offline: offline,
  );
}

/// A built snapshot folder.
class Snapshot {
  Snapshot({required this.dir, required this.root});

  final Directory dir;

  /// The content tree the manifest reads: the folder itself for a repo
  /// snapshot, the checkout for a checkout source.
  final String root;

  File get exportJson => File('${dir.path}/export.json');
  File get contentDb => File('${dir.path}/content.db');
  File get done => File('${dir.path}/DONE');
  bool get isFinished => done.existsSync() && contentDb.existsSync();
}

Future<void> _run(String exe, List<String> args, String what) async {
  final result = await Process.run(exe, args);
  if (result.exitCode != 0) {
    final text = '${result.stderr}${result.stdout}'.trim();
    final tail = text.split('\n').reversed.take(4).toList().reversed.join(' ');
    throw StateError('$what failed: $tail');
  }
}

/// Builds the snapshot for [resolved] unless a finished one exists.
///
/// Repo mode extracts the content with `git archive` into the snapshot folder.
/// Nothing is ever written into the repo or the checkout.
Future<Snapshot> ensureSnapshot({
  required ContentSource source,
  required ResolvedSource resolved,
  required Directory data,
  required String binDir,
  void Function(String message)? progress,
}) async {
  final dir = Directory('${data.path}/snapshots/${resolved.key}');
  final root = source.isCheckout ? source.path : '${dir.path}/tree';
  final snapshot = Snapshot(dir: dir, root: root);
  if (snapshot.isFinished &&
      (source.isCheckout || Directory(root).existsSync())) {
    return snapshot;
  }
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  dir.createSync(recursive: true);

  var exportRoot = root;
  if (!source.isCheckout) {
    progress?.call('Reading content from Git');
    Directory(root).createSync(recursive: true);
    final result = await Process.run('/bin/sh', [
      '-c',
      // ignore: lines_longer_than_80_chars
      r'git -C "$1" archive "$2" content tools/lesson_author/outline.json | tar -x -C "$3"',
      'sh',
      source.path,
      resolved.commit,
      root,
    ]);
    if (result.exitCode != 0) {
      throw StateError('git archive failed: ${result.stderr}'.trim());
    }
    Directory('$root/tools/build_content_export').createSync(recursive: true);
    File('$binDir/historical_v1.json')
        .copySync('$root/tools/build_content_export/historical_v1.json');
  } else {
    exportRoot = root;
    final history = File('$root/tools/build_content_export/historical_v1.json');
    if (!history.existsSync()) {
      throw StateError('The checkout has no historical_v1.json.');
    }
  }

  progress?.call('Building the content');
  await _run(
    '$binDir/build_content_export',
    [snapshot.exportJson.path, exportRoot],
    'The content export',
  );
  progress?.call('Writing the content database');
  await _run(
    '$binDir/seed_writer',
    [snapshot.exportJson.path, snapshot.contentDb.path],
    'The seed writer',
  );
  snapshot.done.writeAsStringSync(resolved.commit);
  _prune(data, keep: dir.path);
  return snapshot;
}

/// Keeps the newest two snapshots, never the one in use.
void _prune(Directory data, {required String keep}) {
  final root = Directory('${data.path}/snapshots');
  if (!root.existsSync()) return;
  final dirs = root.listSync().whereType<Directory>().toList()
    ..sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );
  for (final dir in dirs.skip(2)) {
    if (dir.path != keep) dir.deleteSync(recursive: true);
  }
}
