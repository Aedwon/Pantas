import 'dart:io';

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
          contains('total=279 code=189 open=56 native=23 cut=8 founder=3'),
        );
      },
    );

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

  group('check_lesson_illustrations.py --phase complete', () {
    test('fails on unreplaced illustrations and missing PNGs', () async {
      final result = await _runChecker(['--phase', 'complete']);
      expect(result.exitCode, isNot(0));
    });
  });
}
