import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'manifest.dart';
import 'notes_store.dart';
import 'snapshot.dart';

const _usage = 'Usage: content_pass_server --web <dir> --bin <dir> '
    '[--port 0] [--data <dir>] [--parent-pid <pid>]';

String _home() => Platform.environment['HOME'] ?? '.';

bool _alive(int pid) => Process.runSync('kill', ['-0', '$pid']).exitCode == 0;

Future<void> main(List<String> argv) async {
  final args = <String, String>{};
  for (var i = 0; i + 1 < argv.length; i += 2) {
    args[argv[i].replaceFirst('--', '')] = argv[i + 1];
  }
  final web = args['web'];
  final bin = args['bin'];
  if (web == null || bin == null) {
    stderr.writeln(_usage);
    exit(64);
  }
  final data = Directory(
    args['data'] ?? '${_home()}/Library/Application Support/Content Pass',
  )..createSync(recursive: true);

  final pidFile = File('${data.path}/server.pid');
  if (pidFile.existsSync()) {
    final other = int.tryParse(pidFile.readAsStringSync().trim());
    if (other != null && other != pid && _alive(other)) {
      stderr.writeln(
        'Content Pass is already running (process $other). '
        'Close it before starting another.',
      );
      exit(3);
    }
  }
  pidFile.writeAsStringSync('$pid');

  final app = ContentPassServer(
    web: Directory(web),
    bin: bin,
    data: data,
  );
  final http = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    int.parse(args['port'] ?? '0'),
  );
  stdout.writeln('LISTENING ${http.port}');
  await stdout.flush();

  void shutdown() {
    if (pidFile.existsSync() && pidFile.readAsStringSync().trim() == '$pid') {
      pidFile.deleteSync();
    }
    exit(0);
  }

  ProcessSignal.sigint.watch().listen((_) => shutdown());
  ProcessSignal.sigterm.watch().listen((_) => shutdown());
  final parent = int.tryParse(args['parent-pid'] ?? '');
  if (parent != null) {
    Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_alive(parent)) shutdown();
    });
  }

  unawaited(app.refresh());
  await for (final request in http) {
    unawaited(app.handle(request));
  }
}

/// The local server: static files, the manifest, the notes and the content
/// build. Listening starts first and the build runs behind it.
class ContentPassServer {
  ContentPassServer({
    required this.web,
    required this.bin,
    required this.data,
  }) : notes = NotesStore(data)..load();

  final Directory web;
  final String bin;
  final Directory data;
  final NotesStore notes;

  String phase = 'building';
  String message = 'Starting';
  String label = '';
  String commit = '';
  bool dirty = false;
  int generation = 0;
  int wentBack = 0;
  String? key;
  Snapshot? snapshot;
  Manifest? manifest;
  Future<void>? _running;

  /// Checks the source and rebuilds when its content changed.
  Future<void> refresh() => _running ??= _refresh().whenComplete(() {
        _running = null;
      });

  Future<void> _refresh() async {
    final first = manifest == null;
    if (first) {
      phase = 'building';
      message = 'Checking the content source';
    }
    try {
      final source = ContentSource.load(data);
      final resolved = await resolveSource(source);
      if (resolved.key == key && manifest != null) {
        phase = 'ready';
        message = resolved.offline
            ? 'Could not reach Git. Showing the last version.'
            : '';
        return;
      }
      phase = 'building';
      message = 'Building the content';
      final snap = await ensureSnapshot(
        source: source,
        resolved: resolved,
        data: data,
        binDir: bin,
        progress: (m) => message = m,
      );
      message = 'Reading the content files';
      final export = jsonDecode(snap.exportJson.readAsStringSync())
          as Map<String, Object?>;
      final built = buildManifest(snap.root, export);
      wentBack = notes.applyManifest(built.hashes);
      snapshot = snap;
      manifest = built;
      key = resolved.key;
      label = resolved.label;
      commit = resolved.commit;
      dirty = resolved.dirty;
      generation++;
      phase = 'ready';
      message = resolved.offline
          ? 'Could not reach Git. Showing the last version.'
          : '';
    } on Object catch (e) {
      phase = manifest == null ? 'error' : 'ready';
      message = '$e';
    }
  }

  Map<String, Object?> state() => {
        'phase': phase,
        'message': message,
        'label': label,
        'commit': commit,
        'dirty': dirty,
        'generation': generation,
        'wentBack': wentBack,
        'notesNotice': notes.corruptNotice,
        'position': notes.position,
        'records': notes.records,
      };

  Future<void> handle(HttpRequest request) async {
    final response = request.response;
    try {
      final path = request.uri.path;
      final method = request.method;
      if (path == '/api/state' && method == 'GET') {
        return _json(response, state());
      }
      if (path == '/api/manifest' && method == 'GET') {
        final m = manifest;
        if (m == null) return _status(response, 503, 'Not ready');
        return _json(response, m.toJson());
      }
      if (path == '/api/figure' && method == 'GET') {
        final block = manifest?.figureBlocks[request.uri.queryParameters['id']];
        if (block == null) return _status(response, 404, 'No such figure');
        return _json(response, block);
      }
      if (path == '/snapshot/content.db' && method == 'GET') {
        final file = snapshot?.contentDb;
        if (file == null) return _status(response, 503, 'Not ready');
        response.headers
          ..contentType = ContentType.binary
          ..set('cache-control', 'no-store');
        await response.addStream(file.openRead());
        return response.close();
      }
      if (path == '/api/note' && method == 'POST') {
        final body = await _body(request);
        final saved = notes.upsert(
          body,
          now: DateTime.now(),
          commit: commit.isEmpty ? null : commit.substring(0, 7),
        );
        return _json(response, saved);
      }
      if (path == '/api/position' && method == 'POST') {
        notes.setPosition(await _body(request));
        return _json(response, {'ok': true});
      }
      if (path == '/api/refresh' && method == 'POST') {
        await refresh();
        return _json(response, state());
      }
      if (method == 'GET') return await _static(request);
      return _status(response, 405, 'Method not allowed');
    } on FormatException catch (e) {
      return _status(response, 400, e.message);
    } on Object catch (e) {
      return _status(response, 500, '$e');
    }
  }

  Future<Map<String, Object?>> _body(HttpRequest request) async {
    final text = await utf8.decodeStream(request);
    final decoded = jsonDecode(text);
    if (decoded is! Map) throw const FormatException('expected an object');
    return Map<String, Object?>.from(decoded);
  }

  Future<void> _json(HttpResponse response, Object? value) {
    response.headers
      ..contentType = ContentType.json
      ..set('cache-control', 'no-store');
    response.write(jsonEncode(value));
    return response.close();
  }

  Future<void> _status(HttpResponse response, int code, String text) {
    response.statusCode = code;
    response.headers.contentType = ContentType.text;
    response.write(text);
    return response.close();
  }

  static const _types = {
    'html': 'text/html; charset=utf-8',
    'js': 'text/javascript; charset=utf-8',
    'mjs': 'text/javascript; charset=utf-8',
    'wasm': 'application/wasm',
    'json': 'application/json',
    'css': 'text/css; charset=utf-8',
    'png': 'image/png',
    'svg': 'image/svg+xml',
    'ttf': 'font/ttf',
    'otf': 'font/otf',
    'woff2': 'font/woff2',
    'ico': 'image/x-icon',
    'txt': 'text/plain; charset=utf-8',
    'map': 'application/json',
  };

  Future<void> _static(HttpRequest request) async {
    var rel = Uri.decodeComponent(request.uri.path);
    if (rel == '/') rel = '/index.html';
    if (rel.contains('..')) return _status(request.response, 400, 'Bad path');
    final file = File('${web.path}$rel');
    if (!file.existsSync()) return _status(request.response, 404, 'Not found');
    final ext = rel.split('.').last.toLowerCase();
    final type = _types[ext] ?? 'application/octet-stream';
    request.response.headers
      ..set('content-type', type)
      ..set('cache-control', 'no-store');
    request.response.contentLength = file.lengthSync();
    await request.response.addStream(file.openRead());
    return request.response.close();
  }
}
