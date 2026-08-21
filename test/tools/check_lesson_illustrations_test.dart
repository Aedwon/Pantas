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
    test('fails on unreplaced illustrations and missing PNGs in live repo',
        () async {
      final result = await _runChecker(['--phase', 'complete']);
      expect(result.exitCode, isNot(0));
    });

    test('passes on a fully conforming complete fixture', () async {
      final fixture = await _CompleteFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));

      final result = await _runChecker([
        '--phase',
        'complete',
        '--lessons',
        fixture.lessonsDir.path,
        '--illustrations',
        fixture.illustrationsDir.path,
      ]);
      expect(result.exitCode, 0, reason: result.stderr.toString());
      expect(
        result.stdout.toString(),
        contains(
          'complete: 189 valid figures, 59 illustrations (59 pngs), 0 native/cut markers remaining',
        ),
      );
    });

    test('rejects FIGURE markers placed in the wrong lesson', () async {
      final fixture = await _CompleteFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));

      // functions-and-relations has 1 code figure;
      // linear-equations-inequalities has 1 code figure.
      // Move the figure from functions-and-relations into
      // linear-equations-inequalities.
      // Global count of FIGURE markers remains 189, but lesson-level count is
      // wrong (0 and 2).
      final fnFile = File(
        '${fixture.lessonsDir.path}/mathematics/algebra/functions-and-relations.md',
      );
      final linFile = File(
        '${fixture.lessonsDir.path}/mathematics/algebra/linear-equations-inequalities.md',
      );

      fnFile.writeAsStringSync('# functions-and-relations\n');
      linFile.writeAsStringSync(
        '# linear-equations-inequalities\n\n'
        '<!-- FIGURE: {"kind": "coordinate-graph"} -->\n'
        '<!-- FIGURE: {"kind": "coordinate-graph"} -->\n',
      );

      final result = await _runChecker([
        '--phase',
        'complete',
        '--lessons',
        fixture.lessonsDir.path,
        '--illustrations',
        fixture.illustrationsDir.path,
      ]);
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        contains('mathematics/algebra/functions-and-relations'),
      );
    });

    test('rejects remaining native marker description', () async {
      final fixture = await _CompleteFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));

      // Add a native marker description to modifiers.md and remove one open
      // marker from speeches.md so global count remains 59.
      final nativeFile = File(
        '${fixture.lessonsDir.path}/language-proficiency/grammar-and-structure/modifiers.md',
      );
      final openFile = File(
        '${fixture.lessonsDir.path}/reading-comprehension/text-types/speeches.md',
      );

      nativeFile.writeAsStringSync(
        '# modifiers\n\n'
        '<!-- ILLUSTRATION: two side-by-side sentence diagrams, one '
        'showing a modifier phrase with an arrow pointing to the wrong '
        'word far away (misplaced), and one showing a modifier phrase '
        'with an arrow pointing to nothing, a large question mark where '
        'the intended subject should be (dangling) -->\n',
      );
      openFile.writeAsStringSync('# speeches\n');

      final result = await _runChecker([
        '--phase',
        'complete',
        '--lessons',
        fixture.lessonsDir.path,
        '--illustrations',
        fixture.illustrationsDir.path,
      ]);
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        anyOf(contains('native'), contains('modifiers')),
      );
    });

    test('rejects remaining cut marker description', () async {
      final fixture = await _CompleteFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));

      final cutFile = File(
        '${fixture.lessonsDir.path}/language-proficiency/language-application/error-identification.md',
      );
      final openFile = File(
        '${fixture.lessonsDir.path}/reading-comprehension/text-types/speeches.md',
      );

      cutFile.writeAsStringSync(
        '# error-identification\n\n'
        '<!-- ILLUSTRATION: a short checklist card listing the six '
        'error categories with a small magnifying glass icon, next to '
        'a sample sentence with one word underlined in red as the error -->\n',
      );
      openFile.writeAsStringSync('# speeches\n');

      final result = await _runChecker([
        '--phase',
        'complete',
        '--lessons',
        fixture.lessonsDir.path,
        '--illustrations',
        fixture.illustrationsDir.path,
      ]);
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        anyOf(contains('cut'), contains('error-identification')),
      );
    });

    test('rejects unexpected illustration marker in lesson', () async {
      final fixture = await _CompleteFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));

      File(
        '${fixture.lessonsDir.path}/mathematics/algebra/functions-and-relations.md',
      ).writeAsStringSync(
        '# functions-and-relations\n\n'
        '<!-- FIGURE: {"kind": "coordinate-graph"} -->\n'
        '<!-- ILLUSTRATION: unexpected non-manifest illustration -->\n',
      );

      final result = await _runChecker([
        '--phase',
        'complete',
        '--lessons',
        fixture.lessonsDir.path,
        '--illustrations',
        fixture.illustrationsDir.path,
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('unexpected'));
    });

    test('rejects missing planned open/founder illustration marker', () async {
      final fixture = await _CompleteFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));

      File(
        '${fixture.lessonsDir.path}/reading-comprehension/text-types/short-stories-and-novels.md',
      ).writeAsStringSync('# short-stories-and-novels\n');

      final result = await _runChecker([
        '--phase',
        'complete',
        '--lessons',
        fixture.lessonsDir.path,
        '--illustrations',
        fixture.illustrationsDir.path,
      ]);
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        anyOf(contains('missing'), contains('short-stories-and-novels')),
      );
    });

    test('rejects glob prefix substitute when exact target_file is missing',
        () async {
      final fixture = await _CompleteFixture.create();
      addTearDown(() => fixture.dir.delete(recursive: true));

      // Rename one exact PNG to another filename with the same sequence prefix.
      final exactFile = File(
        '${fixture.illustrationsDir.path}/reading-comprehension/text-types/short-stories-and-novels/01-rising-then-falling-plot.png',
      );
      final globSubstitute = File(
        '${fixture.illustrationsDir.path}/reading-comprehension/text-types/short-stories-and-novels/01-different-slug.png',
      );
      expect(exactFile.existsSync(), isTrue);
      exactFile.renameSync(globSubstitute.path);

      final result = await _runChecker([
        '--phase',
        'complete',
        '--lessons',
        fixture.lessonsDir.path,
        '--illustrations',
        fixture.illustrationsDir.path,
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('missing PNG'));
      expect(
        result.stderr.toString(),
        contains('01-rising-then-falling-plot.png'),
      );
    });
  });
}

class _CompleteFixture {
  _CompleteFixture(this.dir, this.lessonsDir, this.illustrationsDir);

  final Directory dir;
  final Directory lessonsDir;
  final Directory illustrationsDir;

  static Future<_CompleteFixture> create() async {
    final tmp = await Directory.systemTemp.createTemp('illus_complete_');
    final lessonsDir = Directory('${tmp.path}/lessons')
      ..createSync(recursive: true);
    final illustrationsDir = Directory('${tmp.path}/illustrations')
      ..createSync(recursive: true);

    final strategyLines =
        File('docs/content/illustrations/strategy.tsv').readAsLinesSync();
    final header = strategyLines.first.split('\t');
    final subjectIdx = header.indexOf('subject');
    final topicIdx = header.indexOf('topic');
    final lessonIdx = header.indexOf('lesson');
    final targetIdx = header.indexOf('target_file');
    final descIdx = header.indexOf('description');
    final stratIdx = header.indexOf('strategy');

    final lessonRows = <String, List<Map<String, String>>>{};

    for (final line in strategyLines.skip(1)) {
      if (line.trim().isEmpty) continue;
      final parts = line.split('\t');
      final row = {
        'subject': parts[subjectIdx],
        'topic': parts[topicIdx],
        'lesson': parts[lessonIdx],
        'target_file': parts[targetIdx],
        'description': parts[descIdx],
        'strategy': parts[stratIdx],
      };
      final lessonKey =
          '${parts[subjectIdx]}/${parts[topicIdx]}/${parts[lessonIdx]}';
      lessonRows.putIfAbsent(lessonKey, () => []).add(row);

      if (parts[stratIdx] == 'open' || parts[stratIdx] == 'founder') {
        final targetRel = parts[targetIdx];
        final subpath = targetRel.startsWith('content/illustrations/')
            ? targetRel.substring('content/illustrations/'.length)
            : targetRel;
        File('${illustrationsDir.path}/$subpath').createSync(recursive: true);
      }
    }

    for (final entry in lessonRows.entries) {
      final parts = entry.key.split('/');
      final sub = parts[0];
      final top = parts[1];
      final les = parts[2];
      final lessonDir = Directory('${lessonsDir.path}/$sub/$top')
        ..createSync(recursive: true);
      final file = File('${lessonDir.path}/$les.md');
      final buffer = StringBuffer('# $les\n\n');

      for (final r in entry.value) {
        final strat = r['strategy'];
        final desc = r['description'];
        if (strat == 'code') {
          buffer.writeln('<!-- FIGURE: {"kind": "coordinate-graph"} -->');
        } else if (strat == 'open' || strat == 'founder') {
          buffer.writeln('<!-- ILLUSTRATION: $desc -->');
        } else {
          buffer.writeln('Native content for $desc');
        }
      }
      file.writeAsStringSync(buffer.toString());
    }

    return _CompleteFixture(tmp, lessonsDir, illustrationsDir);
  }
}
