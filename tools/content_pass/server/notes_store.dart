import 'dart:convert';
import 'dart:io';

/// The review notes file: position plus one record per reviewed item.
///
/// Writes go through a temporary file, are flushed, and keep one `.bak` of the
/// file they replace. A file that cannot be read is moved aside and reported,
/// never overwritten.
class NotesStore {
  NotesStore(this.dir) : _data = _empty();

  final Directory dir;
  Map<String, Object?> _data;

  /// Set when the notes file was unreadable and moved aside at load time.
  String? corruptNotice;

  File get file => File('${dir.path}/notes.json');

  static Map<String, Object?> _empty() => {
        'version': 1,
        'position': <String, Object?>{},
        'records': <Object?>[],
      };

  Map<String, Object?> get data => _data;

  Map<String, Object?> get position =>
      Map<String, Object?>.from(_data['position']! as Map);

  List<Map<String, Object?>> get records => [
        for (final r in _data['records']! as List)
          Map<String, Object?>.from(r as Map),
      ];

  void load() {
    corruptNotice = null;
    if (!file.existsSync()) {
      _data = _empty();
      return;
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map ||
          decoded['version'] != 1 ||
          decoded['records'] is! List ||
          (decoded['position'] != null && decoded['position'] is! Map)) {
        throw const FormatException('unexpected shape');
      }
      _data = {
        'version': 1,
        'position': Map<String, Object?>.from(
          (decoded['position'] as Map?) ?? const {},
        ),
        'records': [
          for (final r in decoded['records'] as List)
            Map<String, Object?>.from(r as Map),
        ],
      };
    } on Object catch (e) {
      final stamp = DateTime.now().toUtc().millisecondsSinceEpoch;
      final aside = '${dir.path}/notes.corrupt-$stamp.json';
      file.renameSync(aside);
      corruptNotice =
          'The notes file could not be read ($e). It was moved to $aside.';
      _data = _empty();
    }
  }

  void save() {
    dir.createSync(recursive: true);
    final tmp = File('${dir.path}/notes.json.tmp');
    final raf = tmp.openSync(mode: FileMode.write);
    try {
      raf
        ..writeStringSync(
          '${const JsonEncoder.withIndent('  ').convert(_data)}\n',
        )
        ..flushSync();
    } finally {
      raf.closeSync();
    }
    if (file.existsSync()) {
      file.copySync('${dir.path}/notes.json.bak');
    }
    tmp.renameSync(file.path);
  }

  /// Inserts or replaces the record with the same id. The server stamps the
  /// time, and the commit when the caller sent none.
  Map<String, Object?> upsert(
    Map<String, Object?> record, {
    required DateTime now,
    String? commit,
  }) {
    final id = record['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('record needs an id');
    }
    final next = Map<String, Object?>.from(record)
      ..['time'] = now.toUtc().toIso8601String()
      ..remove('changed')
      ..remove('removed');
    if (commit != null && (next['commit'] ?? '') == '') next['commit'] = commit;
    final list = _data['records']! as List;
    final at = list.indexWhere((r) => (r as Map)['id'] == id);
    final old = at < 0 ? null : list[at] as Map;
    // The record that was reset keeps its earlier answer for reference.
    if (old != null && old['previous'] != null && next['previous'] == null) {
      next['previous'] = old['previous'];
    }
    if (at < 0) {
      list.add(next);
    } else {
      list[at] = next;
    }
    save();
    return next;
  }

  void setPosition(Map<String, Object?> position) {
    _data['position'] = Map<String, Object?>.from(position);
    save();
  }

  /// Reconciles records with a new manifest (`id` to `hash`).
  ///
  /// A reviewed record whose hash changed goes back to not reviewed, and its
  /// earlier answer moves into `previous`. A record whose item left the
  /// manifest is marked `removed` and stays. Returns how many went back.
  int applyManifest(Map<String, String> hashes) {
    var reset = 0;
    final list = _data['records']! as List;
    for (var i = 0; i < list.length; i++) {
      final r = Map<String, Object?>.from(list[i] as Map);
      final hash = hashes[r['id']];
      if (hash == null) {
        r['removed'] = true;
      } else {
        r.remove('removed');
        if (r['hash'] != hash) {
          final reviewed = (r['status'] ?? 'not_reviewed') != 'not_reviewed';
          if (reviewed) {
            r['previous'] = {
              'tags': r['tags'] ?? <Object?>[],
              'comment': r['comment'] ?? '',
              'status': r['status'],
              'hash': r['hash'],
              'time': r['time'],
            };
            r['tags'] = <Object?>[];
            r['comment'] = '';
            r['status'] = 'not_reviewed';
            r['changed'] = true;
            reset++;
          }
          r['hash'] = hash;
        }
      }
      list[i] = r;
    }
    if (list.isNotEmpty) save();
    return reset;
  }
}
