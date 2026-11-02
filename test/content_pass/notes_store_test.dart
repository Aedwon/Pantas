// ignore_for_file: cascade_invocations
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/content_pass/server/notes_store.dart';

Map<String, Object?> _record(String id, {String status = 'tagged'}) => {
      'id': id,
      'kind': 'question',
      'file': 'content/questions/a.yaml',
      'exams': ['cse-pro'],
      'state': 'question',
      'size': 'phone',
      'theme': 'light',
      'tags': ['wording'],
      'comment': 'unclear stem',
      'status': status,
      'hash': 'h1',
      'commit': 'abc1234',
    };

void main() {
  late Directory dir;
  final now = DateTime.utc(2026, 11, 2, 9);

  setUp(() => dir = Directory.systemTemp.createTempSync('notes_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('a saved note and position survive a reload', () {
    final store = NotesStore(dir)..load();
    final saved = store.upsert(_record('q1'), now: now);
    store.setPosition({'exam': 'cse-pro', 'itemId': 'q1'});

    expect(saved['time'], '2026-11-02T09:00:00.000Z');
    final again = NotesStore(dir)..load();
    expect(again.records.single['id'], 'q1');
    expect(again.records.single['comment'], 'unclear stem');
    expect(again.position['itemId'], 'q1');
    expect(again.corruptNotice, isNull);
  });

  test('upsert replaces by id and keeps one backup', () {
    final store = NotesStore(dir)..load();
    store.upsert(_record('q1'), now: now);
    store.upsert({..._record('q1'), 'comment': 'second'}, now: now);

    expect(store.records, hasLength(1));
    expect(store.records.single['comment'], 'second');
    final backup = jsonDecode(
      File('${dir.path}/notes.json.bak').readAsStringSync(),
    ) as Map<String, Object?>;
    expect(
      ((backup['records']! as List).single as Map)['comment'],
      'unclear stem',
    );
    expect(File('${dir.path}/notes.json.tmp').existsSync(), isFalse);
  });

  test('the server fills in the commit only when the client sent none', () {
    final store = NotesStore(dir)..load();
    final withCommit = store.upsert(_record('q1'), now: now, commit: 'zzz');
    final without = store.upsert(
      {..._record('q2'), 'commit': ''},
      now: now,
      commit: 'zzz',
    );

    expect(withCommit['commit'], 'abc1234');
    expect(without['commit'], 'zzz');
  });

  test('an unreadable file is moved aside, reported, and not overwritten', () {
    File('${dir.path}/notes.json').writeAsStringSync('{not json');
    final store = NotesStore(dir)..load();

    expect(store.corruptNotice, contains('moved to'));
    expect(store.records, isEmpty);
    final aside = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('notes.corrupt-'))
        .single;
    expect(aside.readAsStringSync(), '{not json');
    expect(File('${dir.path}/notes.json').existsSync(), isFalse);
  });

  test('a file with the wrong shape counts as unreadable', () {
    File('${dir.path}/notes.json').writeAsStringSync('{"version": 2}');
    final store = NotesStore(dir)..load();

    expect(store.corruptNotice, isNotNull);
  });

  group('applyManifest', () {
    test('a reviewed record whose hash changed goes back to not reviewed', () {
      final store = NotesStore(dir)..load();
      store.upsert(_record('q1'), now: now);

      final reset = store.applyManifest({'q1': 'h2'});

      expect(reset, 1);
      final r = store.records.single;
      expect(r['status'], 'not_reviewed');
      expect(r['tags'], isEmpty);
      expect(r['comment'], '');
      expect(r['changed'], true);
      expect(r['hash'], 'h2');
      final previous = r['previous']! as Map;
      expect(previous['tags'], ['wording']);
      expect(previous['comment'], 'unclear stem');
      expect(previous['status'], 'tagged');
      expect(previous['hash'], 'h1');
      expect(previous['time'], '2026-11-02T09:00:00.000Z');
    });

    test('an unchanged hash leaves the record alone', () {
      final store = NotesStore(dir)..load();
      store.upsert(_record('q1'), now: now);

      expect(store.applyManifest({'q1': 'h1'}), 0);
      expect(store.records.single['status'], 'tagged');
      expect(store.records.single['changed'], isNull);
    });

    test('a not reviewed record only takes the new hash', () {
      final store = NotesStore(dir)..load();
      store.upsert(_record('q1', status: 'not_reviewed'), now: now);

      expect(store.applyManifest({'q1': 'h2'}), 0);
      expect(store.records.single['hash'], 'h2');
      expect(store.records.single['previous'], isNull);
    });

    test('a record whose item left is marked removed and kept', () {
      final store = NotesStore(dir)..load();
      store.upsert(_record('q1'), now: now);

      expect(store.applyManifest({}), 0);
      expect(store.records.single['removed'], true);
      expect(store.records.single['status'], 'tagged');

      store.applyManifest({'q1': 'h1'});
      expect(store.records.single['removed'], isNull);
    });

    test('saving a reset record again clears the changed mark', () {
      final store = NotesStore(dir)..load();
      store.upsert(_record('q1'), now: now);
      store.applyManifest({'q1': 'h2'});

      final saved = store.upsert(
        {..._record('q1'), 'hash': 'h2'},
        now: now,
      );

      expect(saved['changed'], isNull);
      expect(saved['previous'], isNotNull);
    });
  });
}
