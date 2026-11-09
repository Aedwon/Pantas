import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/design_lint.dart';

const _root = '/work/pantas';

String _row(String rule, String path, int line, [int column = 5]) =>
    'WARNING|STATIC_WARNING|$rule|$_root/$path|$line|$column|3|Hand-written.';

void main() {
  group('parsing', () {
    test('keeps ds_ rules, makes paths relative and drops duplicates', () {
      final found = parseMachineOutput(
        [
          _row('DS_NO_DESIGN_LITERAL', 'lib/app/a.dart', 10),
          _row('DS_NO_DESIGN_LITERAL', 'lib/app/a.dart', 10),
          _row('DS_NO_DESIGN_LITERAL', 'lib/app/a.dart', 12),
          _row('DS_BOARD_VALUE_REASON', 'lib/app/b.dart', 3),
          'INFO|LINT|PREFER_CONST|$_root/lib/app/a.dart|1|1|1|Use const.',
          'not a diagnostic line',
        ].join('\n'),
        _root,
      );
      expect(countFindings(found), {
        'lib/app/a.dart ds_no_design_literal': 2,
        'lib/app/b.dart ds_board_value_reason': 1,
      });
    });

    test('the baseline round trips, sorted, with no line numbers', () {
      final counts = {
        'lib/features/b.dart ds_no_design_literal': 2,
        'lib/app/a.dart ds_board_value_reason': 1,
      };
      final text = formatBaseline(counts);
      expect(
        text,
        '1 lib/app/a.dart ds_board_value_reason\n'
        '2 lib/features/b.dart ds_no_design_literal\n',
      );
      expect(parseBaseline(text), counts);
    });
  });

  group('comparison', () {
    const base = {'lib/app/a.dart ds_no_design_literal': 3};

    test('equal counts pass', () {
      expect(compareWithBaseline(base, Map.of(base)), isEmpty);
    });

    test('a rising count fails', () {
      final problems = compareWithBaseline(base, {
        'lib/app/a.dart ds_no_design_literal': 4,
      });
      expect(problems.single, contains('rose from 3 to 4'));
    });

    test('a new file and rule fails', () {
      final problems = compareWithBaseline(base, {
        ...base,
        'lib/app/c.dart ds_no_design_literal': 1,
      });
      expect(problems.single, contains('lib/app/c.dart'));
      expect(problems.single, contains('new'));
    });

    test('a falling count fails and names the refresh command', () {
      final problems = compareWithBaseline(base, {
        'lib/app/a.dart ds_no_design_literal': 2,
      });
      expect(problems.first, contains('fell from 3 to 2'));
      expect(problems.last, contains(refreshCommand));
    });

    test('a finding that disappears entirely fails like a fall', () {
      final problems = compareWithBaseline(base, {});
      expect(problems.first, contains('fell from 3 to 0'));
    });

    test('lib/core and tool always fail, baseline or not', () {
      for (final path in ['lib/core/ui/x.dart', 'tool/y.dart']) {
        final key = '$path ds_no_design_literal';
        expect(
          compareWithBaseline({key: 1}, {key: 1}).single,
          contains('must be clean'),
        );
        expect(
          compareWithBaseline({}, {key: 1}).single,
          contains('must be clean'),
        );
      }
    });
  });

  group('canary', () {
    test('the canary finding is found and left out of the counts', () {
      final found = parseMachineOutput(
        [
          _row('DS_NO_DESIGN_LITERAL', canaryPath, 2),
          _row('DS_NO_DESIGN_LITERAL', 'lib/app/a.dart', 10),
        ].join('\n'),
        _root,
      );
      expect(hasCanary(found), isTrue);
      expect(countFindings(withoutCanary(found)), {
        'lib/app/a.dart ds_no_design_literal': 1,
      });
    });

    test('without the canary finding the plugin did not load', () {
      final found = parseMachineOutput(
        _row('DS_NO_DESIGN_LITERAL', 'lib/app/a.dart', 10),
        _root,
      );
      expect(hasCanary(found), isFalse);
      expect(hasCanary(const []), isFalse);
    });

    test('the canary must be a design literal finding', () {
      final found = parseMachineOutput(
        _row('DS_BOARD_VALUE_REASON', canaryPath, 2),
        _root,
      );
      expect(hasCanary(found), isFalse);
    });
  });

  group('update guard', () {
    const base = {
      'lib/app/a.dart ds_no_design_literal': 3,
      'lib/app/b.dart ds_board_value_reason': 1,
    };

    test('a rename keeps the rule total and passes', () {
      expect(
        updateProblems(base, {
          'lib/app/z.dart ds_no_design_literal': 3,
          'lib/app/b.dart ds_board_value_reason': 1,
        }),
        isEmpty,
      );
    });

    test('a smaller total passes', () {
      expect(updateProblems(base, {}), isEmpty);
    });

    test('a rule total that rises is refused, naming the rule', () {
      final problems = updateProblems(base, {
        'lib/app/a.dart ds_no_design_literal': 2,
        'lib/app/c.dart ds_no_design_literal': 2,
        'lib/app/b.dart ds_board_value_reason': 1,
      });
      expect(problems.single, contains('ds_no_design_literal'));
      expect(problems.single, contains('3 to 4'));
    });

    test('a rule that was absent and appears is refused', () {
      final problems = updateProblems(base, {
        ...base,
        'lib/app/b.dart ds_marker_reason': 1,
      });
      expect(problems.single, contains('ds_marker_reason'));
    });
  });
}
