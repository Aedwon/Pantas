import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProcessResult> _runChecker(List<String> args) => Process.run(
      'python3',
      ['tools/audit/check_lesson_illustrations.py', ...args],
    );

void main() {
  group('check_lesson_illustrations.py --phase inventory', () {
    test(
      'passes on the production strategy manifest with exact totals',
      () async {
        final result = await _runChecker(['--phase', 'inventory']);
        expect(result.exitCode, 0, reason: result.stderr.toString());
        expect(
          result.stdout.toString(),
          contains('total=279 code=241 open=4 native=23 cut=8 founder=3'),
        );
      },
    );

    test('production open strategy is exactly the approved four keys', () {
      final strategyLines =
          File('docs/content/illustrations/strategy.tsv').readAsLinesSync();
      final header = strategyLines.first.split('\t');
      final subjectIdx = header.indexOf('subject');
      final topicIdx = header.indexOf('topic');
      final lessonIdx = header.indexOf('lesson');
      final seqIdx = header.indexOf('seq');
      final strategyIdx = header.indexOf('strategy');

      final openKeys = <String>{};
      for (final line in strategyLines.skip(1)) {
        if (line.trim().isEmpty) continue;
        final parts = line.split('\t');
        if (parts[strategyIdx] != 'open') continue;
        final topic = parts[topicIdx];
        final lessonPath = topic.isEmpty
            ? '${parts[subjectIdx]}/${parts[lessonIdx]}'
            : '${parts[subjectIdx]}/$topic/${parts[lessonIdx]}';
        openKeys.add('$lessonPath#${parts[seqIdx]}');
      }

      expect(openKeys, <String>{
        'science/chemistry/mixtures-and-separation#1',
        'science/chemistry/nuclear-chemistry#1',
        'science/earth-science-astronomy/layers-of-the-earth#1',
        'science/earth-science-astronomy/layers-of-the-earth#2',
      });
    });

    test('rejects duplicate keys in strategy manifest', () async {
      final tmp = await Directory.systemTemp.createTemp('illus_dup_');
      addTearDown(() => tmp.delete(recursive: true));

      final strategyFile = File('${tmp.path}/strategy.tsv')
        ..writeAsStringSync(
          'subject\ttopic\tlesson\tseq\ttarget_file\t'
          'description\tstrategy\tbatch\n'
          'science\tbiology\tbotany\t1\tcontent/illustrations/01.png\t'
          'plant\topen\topen-a\n'
          'science\tbiology\tbotany\t1\tcontent/illustrations/01.png\t'
          'plant\topen\topen-a\n',
        );
      final worklistFile = File('${tmp.path}/worklist.tsv')
        ..writeAsStringSync(
          'subject\ttopic\tlesson\tseq\tline\ttarget_file\t'
          'status\tdescription\n'
          'science\tbiology\tbotany\t1\t10\tcontent/illustrations/01.png\t'
          'todo\tplant\n',
        );

      final result = await _runChecker([
        '--phase',
        'inventory',
        '--strategy',
        strategyFile.path,
        '--worklist',
        worklistFile.path,
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('duplicate'));
    });

    test('rejects unknown strategy', () async {
      final tmp = await Directory.systemTemp.createTemp('illus_unk_');
      addTearDown(() => tmp.delete(recursive: true));

      final strategyFile = File('${tmp.path}/strategy.tsv')
        ..writeAsStringSync(
          'subject\ttopic\tlesson\tseq\ttarget_file\t'
          'description\tstrategy\tbatch\n'
          'science\tbiology\tbotany\t1\tcontent/illustrations/01.png\t'
          'plant\tunknown_strategy\topen-a\n',
        );
      final worklistFile = File('${tmp.path}/worklist.tsv')
        ..writeAsStringSync(
          'subject\ttopic\tlesson\tseq\tline\ttarget_file\t'
          'status\tdescription\n'
          'science\tbiology\tbotany\t1\t10\tcontent/illustrations/01.png\t'
          'todo\tplant\n',
        );

      final result = await _runChecker([
        '--phase',
        'inventory',
        '--strategy',
        strategyFile.path,
        '--worklist',
        worklistFile.path,
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('unknown strategy'));
    });

    test('rejects missing keys from worklist in strategy manifest', () async {
      final tmp = await Directory.systemTemp.createTemp('illus_miss_');
      addTearDown(() => tmp.delete(recursive: true));

      final strategyFile = File('${tmp.path}/strategy.tsv')
        ..writeAsStringSync(
          'subject\ttopic\tlesson\tseq\ttarget_file\t'
          'description\tstrategy\tbatch\n'
          'science\tbiology\tbotany\t1\tcontent/illustrations/01.png\t'
          'plant\topen\topen-a\n',
        );
      final worklistFile = File('${tmp.path}/worklist.tsv')
        ..writeAsStringSync(
          'subject\ttopic\tlesson\tseq\tline\ttarget_file\t'
          'status\tdescription\n'
          'science\tbiology\tbotany\t1\t10\tcontent/illustrations/01.png\t'
          'todo\tplant\n'
          'science\tbiology\tbotany\t2\t20\tcontent/illustrations/02.png\t'
          'todo\tflower\n',
        );

      final result = await _runChecker([
        '--phase',
        'inventory',
        '--strategy',
        strategyFile.path,
        '--worklist',
        worklistFile.path,
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('missing'));
    });

    test('rejects count mismatch from the approved breakdown', () async {
      final tmp = await Directory.systemTemp.createTemp('illus_cnt_');
      addTearDown(() => tmp.delete(recursive: true));

      final strategyFile = File('${tmp.path}/strategy.tsv')
        ..writeAsStringSync(
          'subject\ttopic\tlesson\tseq\ttarget_file\t'
          'description\tstrategy\tbatch\n'
          'science\tbiology\tbotany\t1\tcontent/illustrations/01.png\t'
          'plant\topen\topen-a\n',
        );
      final worklistFile = File('${tmp.path}/worklist.tsv')
        ..writeAsStringSync(
          'subject\ttopic\tlesson\tseq\tline\ttarget_file\t'
          'status\tdescription\n'
          'science\tbiology\tbotany\t1\t10\tcontent/illustrations/01.png\t'
          'todo\tplant\n',
        );

      final result = await _runChecker([
        '--phase',
        'inventory',
        '--strategy',
        strategyFile.path,
        '--worklist',
        worklistFile.path,
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('total count mismatch'));
    });
  });

  group('production review state', () {
    test('is version 1 with all 59 current rows approved', () {
      final parsed = jsonDecode(
        File('docs/content/illustrations/review.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      expect(parsed['version'], 1);

      final items = (parsed['items']! as Map).cast<String, dynamic>();
      expect(items, hasLength(59));
      expect(
        items.values.every((value) {
          if (value is! Map) return false;
          final item = value.cast<String, dynamic>();
          final digest = item['reviewedDigest'];
          final reviewedAt = item['reviewedAt'];
          return item['status'] == 'approved' &&
              digest is String &&
              RegExp(r'^[0-9a-f]{64}$').hasMatch(digest) &&
              reviewedAt is String &&
              reviewedAt.isNotEmpty;
        }),
        isTrue,
      );
    });
  });

  group('check_lesson_illustrations.py --phase review-ready', () {
    test(
        'passes with 52 two-theme previews, four Commons, and missing founders',
        () async {
      final fixture = await _ReviewFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));

      final result = await _runChecker(fixture.args('review-ready'));
      expect(result.exitCode, 0, reason: result.stderr.toString());
      expect(
        result.stdout.toString(),
        contains(
          'review-ready: 52 code previews ready, 4 Commons assets ready, '
          '3 founder assets missing (allowed)',
        ),
      );
      for (final row in fixture.founderRows) {
        expect(result.stdout.toString(), contains(row.targetFile));
      }
    });

    test('fails when one code theme preview is missing', () async {
      final fixture = await _ReviewFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));
      File(fixture.darkPathFor(fixture.codeRows.first)).deleteSync();

      final result = await _runChecker(fixture.args('review-ready'));
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('preview PNG'));
      expect(result.stderr.toString(), contains(fixture.codeRows.first.key));
    });

    test('fails when a required Commons PNG is missing', () async {
      final fixture = await _ReviewFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));
      File(fixture.assetPathFor(fixture.openRows.first)).deleteSync();

      final result = await _runChecker(fixture.args('review-ready'));
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('Commons PNG'));
      expect(result.stderr.toString(), contains(fixture.openRows.first.key));
    });

    test('fails when required Commons bytes do not match the declared digest',
        () async {
      final fixture = await _ReviewFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));
      File(fixture.assetPathFor(fixture.openRows.first))
          .writeAsBytesSync(utf8.encode('changed Commons bytes'));

      final result = await _runChecker(fixture.args('review-ready'));
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('Commons digest mismatch'));
      expect(result.stderr.toString(), contains(fixture.openRows.first.key));
    });

    test('rejects malformed review JSON', () async {
      final fixture = await _ReviewFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));
      fixture.reviewFile.writeAsStringSync('{not json');

      final result = await _runChecker(fixture.args('review-ready'));
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('Invalid review JSON'));
    });

    test('rejects invalid review version or shape', () async {
      final fixture = await _ReviewFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));
      fixture.reviewFile.writeAsStringSync(
        jsonEncode(<String, dynamic>{'version': 2, 'items': <dynamic>[]}),
      );

      final result = await _runChecker(fixture.args('review-ready'));
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('Invalid review JSON shape'));
    });

    test('rejects an unknown extra review key', () async {
      final fixture = await _ReviewFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));
      fixture.writeReviewItems(<String, dynamic>{
        'unknown/topic/lesson#1': fixture.reviewItem(
          status: 'approved',
          digest: List<String>.filled(64, '0').join(),
        ),
      });

      final result = await _runChecker(fixture.args('review-ready'));
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('Unknown review key'));
    });

    test('rejects traversal from a preview manifest path', () async {
      final fixture = await _ReviewFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));
      final manifest = fixture.readManifest();
      final items = manifest['items']! as List<dynamic>;
      final first = items.first as Map<String, dynamic>;
      first['lightPath'] = '../outside.png';
      File('${fixture.previewRoot.parent.path}/outside.png')
          .writeAsBytesSync(utf8.encode('outside'));
      fixture.writeManifest(manifest);

      final result = await _runChecker(fixture.args('review-ready'));
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        anyOf(contains('traversal'), contains('preview path')),
      );
    });

    test('still rejects a FIGURE marker moved to the wrong lesson', () async {
      final fixture = await _ReviewFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));
      final source = fixture.rowByKey(
        'mathematics/algebra/functions-and-relations#1',
      );
      final destination = fixture.rowByKey(
        'mathematics/algebra/linear-equations-inequalities#1',
      );
      File(fixture.lessonPathFor(source))
          .writeAsStringSync('# ${source.lesson}\n');
      File(fixture.lessonPathFor(destination)).writeAsStringSync(
        '# ${destination.lesson}\n\n'
        '<!-- FIGURE: {"kind":"coordinate-graph"} -->\n'
        '<!-- FIGURE: {"kind":"coordinate-graph"} -->\n',
      );

      final result = await _runChecker(fixture.args('review-ready'));
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        contains('mathematics/algebra/functions-and-relations'),
      );
    });

    test('still rejects a native or cut illustration marker', () async {
      final fixture = await _ReviewFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));
      final native = fixture.rows.firstWhere((row) => row.strategy == 'native');
      final open = fixture.openRows.first;
      File(fixture.lessonPathFor(native)).writeAsStringSync(
        '# ${native.lesson}\n\n<!-- ILLUSTRATION: ${native.description} -->\n',
      );
      File(fixture.lessonPathFor(open)).writeAsStringSync('# ${open.lesson}\n');

      final result = await _runChecker(fixture.args('review-ready'));
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        anyOf(contains('native/cut'), contains(native.lesson)),
      );
    });
  });

  group('check_lesson_illustrations.py --phase complete', () {
    test('passes when all 59 current digests are approved', () async {
      final fixture = await _ReviewFixture.create(founderFiles: true);
      addTearDown(() => fixture.dir.delete(recursive: true));
      fixture.approveAll();

      final result = await _runChecker(fixture.args('complete'));
      expect(result.exitCode, 0, reason: result.stderr.toString());
      expect(
        result.stdout.toString(),
        contains('complete: 59 current illustration digests approved'),
      );
    });

    test('fails when one current item is pending', () async {
      final fixture = await _ReviewFixture.create(founderFiles: true);
      addTearDown(() => fixture.dir.delete(recursive: true));
      fixture
        ..approveAll()
        ..setStatus(fixture.codeRows.first.key, 'pending');

      final result = await _runChecker(fixture.args('complete'));
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('pending'));
      expect(result.stderr.toString(), contains(fixture.codeRows.first.key));
    });

    test('fails when one current item has changes requested', () async {
      final fixture = await _ReviewFixture.create(founderFiles: true);
      addTearDown(() => fixture.dir.delete(recursive: true));
      fixture
        ..approveAll()
        ..setStatus(fixture.codeRows.first.key, 'changes-requested');

      final result = await _runChecker(fixture.args('complete'));
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('changes-requested'));
    });

    test('fails when a reviewed digest is stale', () async {
      final fixture = await _ReviewFixture.create(founderFiles: true);
      addTearDown(() => fixture.dir.delete(recursive: true));
      fixture
        ..approveAll()
        ..setReviewedDigest(
          fixture.codeRows.first.key,
          List<String>.filled(64, '0').join(),
        );

      final result = await _runChecker(fixture.args('complete'));
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('stale reviewed digest'));
      expect(result.stderr.toString(), contains(fixture.codeRows.first.key));
    });

    test('recomputes code digest from changed PNG bytes after approval',
        () async {
      final fixture = await _ReviewFixture.create(founderFiles: true);
      addTearDown(() => fixture.dir.delete(recursive: true));
      fixture.approveAll();
      File(fixture.lightPathFor(fixture.codeRows.first))
          .writeAsBytesSync(utf8.encode('changed after approval'));

      final result = await _runChecker(fixture.args('complete'));
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('stale reviewed digest'));
      expect(result.stderr.toString(), contains(fixture.codeRows.first.key));
    });

    test('fails when a founder file is missing', () async {
      final fixture = await _ReviewFixture.create(founderFiles: true);
      addTearDown(() => fixture.dir.delete(recursive: true));
      fixture.approveAll();
      File(fixture.assetPathFor(fixture.founderRows.first)).deleteSync();

      final result = await _runChecker(fixture.args('complete'));
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('Founder PNG'));
      expect(result.stderr.toString(), contains(fixture.founderRows.first.key));
    });

    test('fails when an extra unknown review key is present', () async {
      final fixture = await _ReviewFixture.create(founderFiles: true);
      addTearDown(() => fixture.dir.delete(recursive: true));
      fixture.approveAll();
      final items = fixture.readReviewItems();
      items['unknown/topic/lesson#1'] = fixture.reviewItem(
        status: 'approved',
        digest: List<String>.filled(64, '0').join(),
      );
      fixture.writeReviewItems(items);

      final result = await _runChecker(fixture.args('complete'));
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('Unknown review key'));
    });
  });
}

class _StrategyRow {
  const _StrategyRow({
    required this.subject,
    required this.topic,
    required this.lesson,
    required this.seq,
    required this.targetFile,
    required this.description,
    required this.strategy,
    required this.batch,
  });

  final String subject;
  final String topic;
  final String lesson;
  final String seq;
  final String targetFile;
  final String description;
  final String strategy;
  final String batch;

  String get lessonKey =>
      topic.isEmpty ? '$subject/$lesson' : '$subject/$topic/$lesson';
  String get key => '$lessonKey#$seq';
  bool get isReviewCode =>
      batch == 'original-code-a' || batch == 'original-code-b';
}

class _ReviewFixture {
  _ReviewFixture({
    required this.dir,
    required this.lessonsDir,
    required this.illustrationsDir,
    required this.previewRoot,
    required this.reviewFile,
    required this.rows,
  });

  final Directory dir;
  final Directory lessonsDir;
  final Directory illustrationsDir;
  final Directory previewRoot;
  final File reviewFile;
  final List<_StrategyRow> rows;

  List<_StrategyRow> get codeRows =>
      rows.where((row) => row.isReviewCode).toList(growable: false);
  List<_StrategyRow> get openRows =>
      rows.where((row) => row.strategy == 'open').toList(growable: false);
  List<_StrategyRow> get founderRows =>
      rows.where((row) => row.strategy == 'founder').toList(growable: false);

  static Future<_ReviewFixture> create({bool founderFiles = false}) async {
    final tmp = await Directory.systemTemp.createTemp('illus_review_');
    final lessonsDir = Directory('${tmp.path}/lessons')
      ..createSync(recursive: true);
    final illustrationsDir = Directory('${tmp.path}/illustrations')
      ..createSync(recursive: true);
    final previewRoot = Directory('${tmp.path}/previews')
      ..createSync(recursive: true);
    Directory('${previewRoot.path}/light').createSync(recursive: true);
    Directory('${previewRoot.path}/dark').createSync(recursive: true);
    final reviewFile = File('${tmp.path}/review.json');

    final rows = _readStrategyRows();
    final lessonRows = <String, List<_StrategyRow>>{};
    for (final row in rows) {
      lessonRows.putIfAbsent(row.lessonKey, () => <_StrategyRow>[]).add(row);
      if (row.strategy == 'open') {
        final source = File(row.targetFile);
        if (!source.existsSync()) {
          throw StateError(
            'Production Commons fixture is missing: ${row.targetFile}',
          );
        }
        final target = File(_assetPath(illustrationsDir, row.targetFile));
        target.parent.createSync(recursive: true);
        target.writeAsBytesSync(source.readAsBytesSync());
      } else if (row.strategy == 'founder' && founderFiles) {
        final target = File(_assetPath(illustrationsDir, row.targetFile));
        target.parent.createSync(recursive: true);
        target.writeAsBytesSync(utf8.encode('founder fixture ${row.key}'));
      }
    }

    for (final entry in lessonRows.entries) {
      final first = entry.value.first;
      final lessonDir = (first.topic.isEmpty
          ? Directory('${lessonsDir.path}/${first.subject}')
          : Directory('${lessonsDir.path}/${first.subject}/${first.topic}'))
        ..createSync(recursive: true);
      final file = File('${lessonDir.path}/${first.lesson}.md');
      final buffer = StringBuffer('# ${first.lesson}\n\n');
      for (final row in entry.value) {
        if (row.strategy == 'code') {
          buffer.writeln('<!-- FIGURE: {"kind":"coordinate-graph"} -->');
        } else if (row.strategy == 'open' || row.strategy == 'founder') {
          buffer.writeln('<!-- ILLUSTRATION: ${row.description} -->');
        } else {
          buffer.writeln('Native content for ${row.description}');
        }
      }
      file.writeAsStringSync(buffer.toString());
    }

    final manifestItems = <Map<String, dynamic>>[];
    for (final row in rows.where((candidate) => candidate.isReviewCode)) {
      final stem = _previewStem(row.key);
      final lightPath = 'light/$stem.png';
      final darkPath = 'dark/$stem.png';
      final lightBytes = utf8.encode('light ${row.key}');
      final darkBytes = utf8.encode('dark ${row.key}');
      File('${previewRoot.path}/$lightPath').writeAsBytesSync(lightBytes);
      File('${previewRoot.path}/$darkPath').writeAsBytesSync(darkBytes);
      manifestItems.add(<String, dynamic>{
        'key': row.key,
        'lightPath': lightPath,
        'darkPath': darkPath,
        'digest': _combinedDigest(lightBytes, darkBytes),
        'width': 390,
        'height': 200,
      });
    }
    File('${previewRoot.path}/manifest.json').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
            'version': 1,
            'items': manifestItems,
          })}\n',
    );
    reviewFile.writeAsStringSync('{\n  "version": 1,\n  "items": {}\n}\n');

    return _ReviewFixture(
      dir: tmp,
      lessonsDir: lessonsDir,
      illustrationsDir: illustrationsDir,
      previewRoot: previewRoot,
      reviewFile: reviewFile,
      rows: rows,
    );
  }

  List<String> args(String phase) => <String>[
        '--phase',
        phase,
        '--lessons',
        lessonsDir.path,
        '--illustrations',
        illustrationsDir.path,
        '--previews',
        previewRoot.path,
        '--review',
        reviewFile.path,
      ];

  _StrategyRow rowByKey(String key) => rows.firstWhere((row) => row.key == key);

  String lessonPathFor(_StrategyRow row) => row.topic.isEmpty
      ? '${lessonsDir.path}/${row.subject}/${row.lesson}.md'
      : '${lessonsDir.path}/${row.subject}/${row.topic}/${row.lesson}.md';

  String assetPathFor(_StrategyRow row) =>
      _assetPath(illustrationsDir, row.targetFile);

  String lightPathFor(_StrategyRow row) =>
      '${previewRoot.path}/light/${_previewStem(row.key)}.png';

  String darkPathFor(_StrategyRow row) =>
      '${previewRoot.path}/dark/${_previewStem(row.key)}.png';

  Map<String, dynamic> readManifest() =>
      jsonDecode(File('${previewRoot.path}/manifest.json').readAsStringSync())
          as Map<String, dynamic>;

  void writeManifest(Map<String, dynamic> manifest) {
    File('${previewRoot.path}/manifest.json').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(manifest)}\n',
    );
  }

  Map<String, dynamic> reviewItem({
    required String status,
    required String digest,
  }) =>
      <String, dynamic>{
        'status': status,
        'notes': '',
        'reviewedDigest': digest,
        'reviewedAt': '2026-08-23T00:00:00.000Z',
      };

  Map<String, dynamic> readReviewItems() {
    final parsed =
        jsonDecode(reviewFile.readAsStringSync()) as Map<String, dynamic>;
    return Map<String, dynamic>.from(parsed['items']! as Map<String, dynamic>);
  }

  void writeReviewItems(Map<String, dynamic> items) {
    reviewFile.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
            'version': 1,
            'items': items,
          })}\n',
    );
  }

  void approveAll() {
    final digests = currentDigests();
    final items = <String, dynamic>{};
    for (final key in digests.keys.toList()..sort()) {
      items[key] = reviewItem(status: 'approved', digest: digests[key]!);
    }
    expect(items, hasLength(59));
    writeReviewItems(items);
  }

  Map<String, String> currentDigests() {
    final result = <String, String>{};
    for (final row in codeRows) {
      final light = File(lightPathFor(row)).readAsBytesSync();
      final dark = File(darkPathFor(row)).readAsBytesSync();
      result[row.key] = _combinedDigest(light, dark);
    }
    for (final row in [...openRows, ...founderRows]) {
      final file = File(assetPathFor(row));
      if (file.existsSync()) {
        result[row.key] = sha256.convert(file.readAsBytesSync()).toString();
      }
    }
    return result;
  }

  void setStatus(String key, String status) {
    final items = readReviewItems();
    final item = Map<String, dynamic>.from(items[key]! as Map<String, dynamic>);
    item['status'] = status;
    items[key] = item;
    writeReviewItems(items);
  }

  void setReviewedDigest(String key, String digest) {
    final items = readReviewItems();
    final item = Map<String, dynamic>.from(items[key]! as Map<String, dynamic>);
    item['reviewedDigest'] = digest;
    items[key] = item;
    writeReviewItems(items);
  }

  static List<_StrategyRow> _readStrategyRows() {
    final lines =
        File('docs/content/illustrations/strategy.tsv').readAsLinesSync();
    final header = lines.first.split('\t');
    int index(String name) {
      final value = header.indexOf(name);
      if (value < 0) throw StateError('Missing strategy column $name');
      return value;
    }

    final subjectIdx = index('subject');
    final topicIdx = index('topic');
    final lessonIdx = index('lesson');
    final seqIdx = index('seq');
    final targetIdx = index('target_file');
    final descriptionIdx = index('description');
    final strategyIdx = index('strategy');
    final batchIdx = index('batch');
    return <_StrategyRow>[
      for (final line in lines.skip(1))
        if (line.trim().isNotEmpty)
          (() {
            final parts = line.split('\t');
            return _StrategyRow(
              subject: parts[subjectIdx],
              topic: parts[topicIdx],
              lesson: parts[lessonIdx],
              seq: parts[seqIdx],
              targetFile: parts[targetIdx],
              description: parts[descriptionIdx],
              strategy: parts[strategyIdx],
              batch: parts[batchIdx],
            );
          })(),
    ];
  }

  static String _assetPath(Directory root, String targetFile) {
    const prefix = 'content/illustrations/';
    final relative = targetFile.startsWith(prefix)
        ? targetFile.substring(prefix.length)
        : targetFile;
    return '${root.path}/$relative';
  }
}

String _previewStem(String key) =>
    key.replaceAll(RegExp('[^A-Za-z0-9._-]'), '__');

String _combinedDigest(List<int> lightBytes, List<int> darkBytes) {
  final lightHash = sha256.convert(lightBytes).toString();
  final darkHash = sha256.convert(darkBytes).toString();
  return sha256.convert(utf8.encode('$lightHash:$darkHash')).toString();
}
