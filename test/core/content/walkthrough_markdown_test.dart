import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/walkthrough_markdown.dart';

import '../../helpers/walkthrough_fixtures.dart';

FormatException _error(int line, String message) =>
    FormatException('$message @$line');

WalkPlan _plan(String body) =>
    planWalkthrough(body.split('\n'), firstLine: 1, error: _error);

void main() {
  group('headingSlug', () {
    test('follows the sweep rule', () {
      expect(headingSlug('What a Percent Means'), 'what-a-percent-means');
      expect(headingSlug('#1: Basic Discount'), '1-basic-discount');
      expect(headingSlug('Speed Tricks & Shortcuts'), 'speed-tricks-shortcuts');
      expect(headingSlug('  Hello!! '), 'hello');
    });
  });

  group('splitChecklistText', () {
    test('splits at the first colon and keeps it in the cue', () {
      final parts = splitChecklistText('Cue words: the move: more');
      expect(parts.cue, 'Cue words:');
      expect(parts.move, 'the move: more');
    });

    test('skips a colon inside inline math', () {
      final parts = splitChecklistText(r'Ratio $a:b$: keep the order');
      expect(parts.cue, r'Ratio $a:b$:');
      expect(parts.move, 'keep the order');
    });

    test('with no colon the cue is empty', () {
      final parts = splitChecklistText('Just a move');
      expect(parts.cue, isEmpty);
      expect(parts.move, 'Just a move');
    });
  });

  group('planWalkthrough', () {
    test('a lesson with no fence is not a walk-through lesson', () {
      final plan = _plan('## Core Concept\n\n### Rule\n\nText.');
      expect(plan.isWalk, isFalse);
      expect(plan.fences, isEmpty);
    });

    test('counts the fences of each sample', () {
      const expected = {
        'discounted-prices': {
          WalkKind.check: 4,
          WalkKind.checklist: 1,
          WalkKind.pair: 2,
          WalkKind.tryIt: 1,
          WalkKind.why: 2,
        },
        'finding-subjects-and-matching-verbs': {
          WalkKind.check: 2,
          WalkKind.checklist: 1,
          WalkKind.pair: 2,
          WalkKind.tryIt: 1,
          WalkKind.why: 1,
        },
        'signed-integer-operations': {
          WalkKind.check: 5,
          WalkKind.checklist: 1,
          WalkKind.pair: 2,
          WalkKind.tryIt: 1,
          WalkKind.why: 3,
        },
        'substituting-negative-numbers': {
          WalkKind.check: 3,
          WalkKind.checklist: 1,
          WalkKind.pair: 2,
          WalkKind.tryIt: 1,
          WalkKind.why: 1,
        },
        'filipino_markers': {
          WalkKind.check: 1,
          WalkKind.checklist: 1,
          WalkKind.pair: 1,
          WalkKind.tryIt: 1,
          WalkKind.why: 1,
        },
      };
      for (final name in walkthroughSamples) {
        final plan = _plan(walkthroughFixture(name));
        expect(plan.isWalk, isTrue, reason: name);
        final counts = <WalkKind, int>{};
        for (final fence in plan.fences.values) {
          counts[fence.kind] = (counts[fence.kind] ?? 0) + 1;
        }
        expect(counts, expected[name], reason: name);
      }
    });

    test('a checklist target may be a heading and may come before its pair',
        () {
      final plan = _plan(
        [
          ':::checklist',
          '- Rule: do it. {#late-pair}',
          '- Other: do that. {#my-heading}',
          ':::',
          '',
          '### My Heading',
          '',
          ':::pair #late-pair',
          'Right: yes',
          'Wrong: no',
          'Note.',
          ':::',
        ].join('\n'),
      );
      expect(plan.fences.length, 2);
    });

    test('a pair with Wrong before Right is refused', () {
      expect(
        () => _plan(':::pair #p\nWrong: no\nRight: yes\nNote.\n:::'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            ':::pair #p needs one Right: line, then one Wrong: line @1',
          ),
        ),
      );
    });

    test('a pair with a second Right line is refused', () {
      expect(
        () => _plan(':::pair #p\nRight: a\nWrong: b\nRight: c\n:::'),
        throwsFormatException,
      );
    });

    test('a stray answer outside any block is refused', () {
      expect(
        () => _plan('Text.\n:::answer\n:::'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            ':::answer is only allowed inside :::check or :::try @2',
          ),
        ),
      );
    });

    test('a figure marker inside a block is refused', () {
      expect(
        () => _plan(':::why\n<!-- FIGURE: {} -->\n:::'),
        throwsFormatException,
      );
    });

    for (final entry in walkthroughBadCases.entries) {
      test('${entry.key} names line ${entry.value.$1}', () {
        final (line, words) = entry.value;
        expect(
          () => _plan(walkthroughFixture(entry.key)),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              allOf(contains(words), endsWith('@$line')),
            ),
          ),
        );
      });
    }
  });
}
