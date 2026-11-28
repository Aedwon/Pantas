import 'dart:io';

/// The lesson Markdown body of a fixture in `test/fixtures/walkthrough/`,
/// without its frontmatter. Line numbers are the body's, as the converters
/// report them.
String walkthroughFixture(String name) {
  final source = File('test/fixtures/walkthrough/$name.md').readAsStringSync();
  final frontmatter = RegExp(r'^---\n(.*?)\n---\n', dotAll: true);
  final match = frontmatter.firstMatch(source);
  return match == null ? source : source.substring(match.end);
}

/// Real walk-through lessons, and a short Filipino-style one that keeps the
/// English markers.
const walkthroughSamples = [
  'discounted-prices',
  'finding-subjects-and-matching-verbs',
  'signed-integer-operations',
  'substituting-negative-numbers',
  'filipino_markers',
];

/// Every bad fixture: the line the error names and the words it carries.
const walkthroughBadCases = <String, (int, String)>{
  'bad_unclosed': (3, 'unclosed :::why block'),
  'bad_stray_close': (3, 'stray closing ::: with no open block'),
  'bad_unknown_fence': (3, 'unknown block ":::note"'),
  'bad_answer_in_why': (
    5,
    ':::answer is only allowed inside :::check or :::try',
  ),
  'bad_second_answer': (7, 'second :::answer in :::check block'),
  'bad_nested': (5, 'nested block ":::why" inside :::check'),
  'bad_check_no_answer': (3, ':::check has no :::answer'),
  'bad_pair_header': (3, 'invalid :::pair header ":::pair #Bad_Slug"'),
  'bad_pair_incomplete': (
    3,
    ':::pair #no-wrong needs one Right: line, then one Wrong: line',
  ),
  'bad_pair_duplicate': (9, 'duplicate :::pair #same'),
  'bad_pair_four': (21, 'more than 3 :::pair blocks in one lesson'),
  'bad_checklist_empty': (3, ':::checklist has no items'),
  'bad_checklist_four': (9, ':::checklist has more than 3 items'),
  'bad_checklist_no_slug': (4, 'checklist item needs a trailing {#slug}'),
  'bad_checklist_target': (
    4,
    'checklist target #does-not-exist matches no :::pair id or ### heading',
  ),
  'bad_marker_in_block': (
    5,
    'figure or illustration marker inside :::why block',
  ),
};

/// A lesson with every fence type, for the exact structure tests.
const walkthroughExactMarkdown = r'''
## Core Concept

### Signed Rule

Intro text.

:::why
Because $x$ works.
:::

:::pair #sample-trap
Right: $5-(-2)=7$
Wrong: $5-(-2)=3$
Change **both** signs.
:::

:::check
Find $4-(-1)$.
:::answer
The answer is $5$.

$$4+1=5$$
:::

## Examples

### #1: Try Example

Evaluate $8-(-2)$.

**Solution:**

1. Rewrite.

$$8+2$$

:::try
Finish: $8+2$.
:::answer
The answer is $10$.

**Check:** $10$.
:::

## Traps to Watch For

:::checklist
- Minus before a negative: change both signs. {#sample-trap}
- No colon here {#signed-rule}
- Math first $a:b$: then move. {#signed-rule}
:::
''';

/// The blocks [walkthroughExactMarkdown] must convert to.
final List<Map<String, Object?>> walkthroughExactBlocks = [
  _block([_span('Core Concept')], 'h2'),
  _block([_span('Signed Rule')], 'h3')..['anchor'] = 'signed-rule',
  _block([_span('Intro text.')]),
  {
    '_type': 'walkWhy',
    'body': [
      _block([_span('Because '), _span('x', 'latex'), _span(' works.')]),
    ],
  },
  {
    '_type': 'walkPair',
    'id': 'sample-trap',
    'right': [_span('5-(-2)=7', 'latex')],
    'wrong': [_span('5-(-2)=3', 'latex')],
    'note': [
      _block([_span('Change '), _span('both', 'strong'), _span(' signs.')]),
    ],
  },
  {
    '_type': 'walkCheck',
    'question': [
      _block([_span('Find '), _span('4-(-1)', 'latex'), _span('.')]),
    ],
    'answer': [
      _block([_span('The answer is '), _span('5', 'latex'), _span('.')]),
      {'_type': 'latex', 'body': '4+1=5'},
    ],
  },
  _block([_span('Examples')], 'h2'),
  _block([_span('#1: Try Example')], 'h3')..['anchor'] = '1-try-example',
  _block([_span('Evaluate '), _span('8-(-2)', 'latex'), _span('.')]),
  _block([_span('Solution:', 'strong')]),
  _block([_span('Rewrite.')])
    ..['listItem'] = 'number'
    ..['level'] = 1
    ..['listNumber'] = 1,
  {'_type': 'latex', 'body': '8+2'},
  {
    '_type': 'walkTry',
    'prompt': [
      _block([_span('Finish: '), _span('8+2', 'latex'), _span('.')]),
    ],
    'answer': [
      _block([_span('The answer is '), _span('10', 'latex'), _span('.')]),
      _block([
        _span('Check:', 'strong'),
        _span(' '),
        _span('10', 'latex'),
        _span('.'),
      ]),
    ],
  },
  _block([_span('Traps to Watch For')], 'h2'),
  {
    '_type': 'walkChecklist',
    'items': [
      {
        'cue': [_span('Minus before a negative:')],
        'move': [_span('change both signs.')],
        'target': 'sample-trap',
      },
      {
        'cue': <Map<String, Object?>>[],
        'move': [_span('No colon here')],
        'target': 'signed-rule',
      },
      {
        'cue': [_span('Math first '), _span('a:b', 'latex'), _span(':')],
        'move': [_span('then move.')],
        'target': 'signed-rule',
      },
    ],
  },
];

Map<String, Object?> _span(String text, [String? mark]) => {
      '_type': 'span',
      'text': text,
      'marks': [if (mark != null) mark],
    };

Map<String, Object?> _block(
  List<Map<String, Object?>> children, [
  String style = 'normal',
]) =>
    {'_type': 'block', 'style': style, 'children': children};
