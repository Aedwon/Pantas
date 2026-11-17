/// Figure-series rules. Params: forms is the five supported outlines; sizes is
/// small/medium/large. Each rule keeps the source horizon and item count except
/// ray-step (3..5), binary-fill (3..5), and arrow-alternation (4..5).
/// lengths, steps, initialDots and initialEdges select the discrete ranges
/// above; colliding answers are rejected. Constant form is cosmetic only when
/// every shown and answer item shares it.
/// No cosmetic changes a feature within a question. No whole-question transform
/// counts as extra capacity. Index 0 uses the literal production source map.
///
/// Contracts (source suffix, operation, named mistakes in answer order):
/// 0001 ray-step: equal clockwise ray step 45/90/135; start on 45-degree grid.
/// double-turn advances twice; early-restart returns first; reverse-turn goes
/// backward one step from last. Reject colliding answers.
/// 0003 binary-fill: black/white alternate, either phase. repeat-fill holds
/// last;
/// average-fill gives half; gradual-fill gives quarter.
/// 0004 size-fill: three-size cycle, any phase, black/white alternate either
/// phase. freeze-fill holds fill; reset-size-early takes first size of cycle;
/// freeze-size holds last size. Five shown items.
/// 0006 two-arrow-turns: cardinal clockwise quarter turns, three shown, horizon
/// two. one-step-only advances once; reverse-once backs once; zero-steps holds.
/// 0009 dots-size: dots start 0..2, grow one, three shown; two distinct sizes
/// alternate. freeze-size; freeze-dots; restart-dots-on-matching-size uses
/// second displayed dot count.
/// 0010 arrow-alternation: two neighboring clockwise cardinal arrows alternate.
/// assume-continuous-turn continues clockwise from last; repeat-last holds;
/// invent-four-direction-cycle takes the unused direction opposite second.
/// 0011 two-fill-steps: quarter/half/three-quarter cycle, any phase, five
/// shown,
/// horizon two. keep-increasing gives full; repeat-last holds; one-step-only
/// advances once. Reject answer collisions.
/// 0012 outline-triple: ordered three distinct forms, five shown. restart-early
/// takes first; repeat-last takes last; increase-sides uses the next side
/// count: triangle to square or square to pentagon.
/// Reject triples containing that extra form or needing an unsupported polygon.
/// 0013 four-tracks: two distinct forms alternate; two distinct sizes
/// alternate;
/// ray advances clockwise 90, start on 45 grid; edges start 0..2, rise one;
/// three shown. freeze-edge-count; freeze-size; freeze-form-and-ray.
/// 0014 corner-edge-count: clockwise corner walk, any phase; edges start 0..1,
/// four shown. freeze-dot; freeze-lines; skip-corner advances twice.
/// 0015 double-fill: black,black,white cycle, any phase; five shown.
/// continue-majority-fill gives black; average-fill gives half; change-outline
/// switches to another supported form. Reject answer collisions.
/// 0016 transfer-count: three shown, dots start 0..2, edges start 3..5; each
/// step adds a dot/removes an edge. freeze-edges; freeze-dots;
/// restart-edge-count uses initial edges.
/// 0017 interleaved-count: four shown, ordered distinct forms, first odd count
/// 0..3 increases one per odd position; even count 0..5 constant.
/// continue-even-track repeats last; count-all-positions uses five dots on odd
/// form; repeat-odd-count repeats the last odd count. Reject collisions.
/// 0018 fill-ray-dots: four shown; distinct fills from
/// quarter/half/three-quarter
/// alternate; rays alternate with 45/90/135 separation, start on 45 grid; dots
/// start 0..1, rise one. freeze-fill; freeze-ray; accumulate-fill gives full.
/// Stem's requested next dot count is slotted. Cosmetic form stays constant.
/// 0020 size-corner-ray: four shown; two sizes alternate, two rays alternate
/// separated by 90 degrees; clockwise corners, any phase; relative ray/corner
/// offset on 45 grid. freeze-size; freeze-dot; freeze-ray.
///
/// All choices are single series-item maps plus text. Their form/size/fill,
/// dot count, edge count and direction fields obey the existing painter
/// contract. Generated draws reject quarter-filled triangles: the painter
/// clips their fill at the base, leaving no visible shaded area.
library;

import 'dart:convert';
import 'dart:math';

import '../../check/signature.dart';
import '../../model.dart';
import '../rule.dart';
import 'sources.dart';

const seriesPatterns = [
  'ray-step',
  'binary-fill',
  'size-fill',
  'two-arrow-turns',
  'dots-size',
  'arrow-alternation',
  'two-fill-steps',
  'outline-triple',
  'four-tracks',
  'corner-edge-count',
  'double-fill',
  'transfer-count',
  'interleaved-count',
  'fill-ray-dots',
  'size-corner-ray',
];
const _sizes = ['small', 'medium', 'large'];
const _corners = ['top-left', 'top-right', 'bottom-right', 'bottom-left'];
const _arrows = ['up', 'right', 'down', 'left'];

class SeriesRule implements Rule {
  SeriesRule(this.pattern);
  final String pattern;
  @override
  String get name => 'series-$pattern';
  @override
  int get version => 1;

  @override
  RuleResult generate(ProblemType t, Random r, int index) {
    final source = (jsonDecode(seriesSources) as Map<String, dynamic>)[pattern]
        as Map<String, dynamic>;
    final original = source['figureSpec'] as Map<String, dynamic>;
    final fixed = index == 0;
    for (var attempt = 0; attempt < 1000; attempt++) {
      T pick<T>(List<T> values) => values[r.nextInt(values.length)];
      final forms = (t.params['forms']! as List).cast<String>().toList()
        ..shuffle(r);
      final sizes = (t.params['sizes']! as List).cast<String>().toList()
        ..shuffle(r);
      final form = forms[0];
      final secondForm = forms[1];
      if (!fixed && pattern == 'size-corner-ray' && form != 'square') continue;
      final initialDots = pick((t.params['initialDots']! as List).cast<int>());
      if (!fixed && pattern == 'interleaved-count' && initialDots == 1) {
        continue;
      }
      final evenDots = r.nextInt(6);
      final edges = pick((t.params['initialEdges']! as List).cast<int>());
      final start = r.nextInt(8) * 45;
      final step = pick((t.params['steps']! as List).cast<int>());
      final corner = r.nextInt(4);
      final arrow = r.nextInt(4);
      final phase = r.nextInt(3);
      final fillPhase = r.nextBool();
      final fills = <double>[.25, .5, .75]..shuffle(r);
      final length = pick((t.params['lengths']! as List).cast<int>());
      Map<String, Object?> state(int i) {
        final parity = i % 2;
        return switch (pattern) {
          'ray-step' => {'form': form, 'line': (start + step * i) % 360},
          'binary-fill' => {
              'form': form,
              'fill': i.isEven == fillPhase ? 'black' : 'white',
            },
          'size-fill' => {
              'form': form,
              'size': _sizes[(phase + i) % 3],
              'fill': i.isEven == fillPhase ? 'black' : 'white',
            },
          'two-arrow-turns' => {
              'form': form,
              'arrow': _arrows[(arrow + i) % 4],
            },
          'dots-size' => {
              'form': form,
              'size': sizes[parity],
              'dots': initialDots + i,
            },
          'arrow-alternation' => {
              'form': form,
              'arrow': _arrows[(arrow + parity) % 4],
            },
          'two-fill-steps' => {'form': form, 'fill': ((phase + i) % 3 + 1) / 4},
          'outline-triple' => {'form': forms[i % 3]},
          'four-tracks' => {
              'form': parity == 0 ? form : secondForm,
              'size': sizes[parity],
              'edgeLines': edges + i,
              'line': (start + 90 * i) % 360,
            },
          'corner-edge-count' => {
              'form': form,
              'dot': _corners[(corner + i) % 4],
              'edgeLines': edges + i,
            },
          'double-fill' => {
              'form': form,
              'fill': (phase + i) % 3 == 2 ? 'white' : 'black',
            },
          'transfer-count' => {
              'form': form,
              'dots': initialDots + i,
              'edgeLines': edges - i,
            },
          'interleaved-count' => {
              'form': parity == 0 ? form : secondForm,
              'dots': parity == 0 ? initialDots + i ~/ 2 : evenDots,
            },
          'fill-ray-dots' => {
              'form': form,
              'fill': fills[parity],
              'line': (start + step * parity) % 360,
              'dots': initialDots + i,
            },
          'size-corner-ray' => {
              'form': form,
              'size': sizes[parity],
              'dot': _corners[(corner + i) % 4],
              'line': (start - 90 * parity) % 360,
            },
          _ => throw StateError(pattern),
        };
      }

      final items = fixed
          ? (original['items'] as List<dynamic>)
              .map((x) => Map<String, Object?>.from(x as Map<String, dynamic>))
              .toList()
          : List.generate(length, state);
      final n = items.length;
      final first = items.first;
      final last = items.last;
      final horizon =
          ['two-arrow-turns', 'two-fill-steps'].contains(pattern) ? 2 : 1;
      // The source is a reserved draw. Compute its continuation by the same
      // operation, retaining the omitted defaults in its literal figure map.
      Map<String, Object?> sourceNext() {
        final next = Map<String, Object?>.of(first);
        switch (pattern) {
          case 'ray-step':
            next['line'] = 135;
          case 'binary-fill':
            next['fill'] = 'white';
          case 'size-fill':
            next['size'] = 'large';
            next['fill'] = 'white';
          case 'two-arrow-turns':
            next['arrow'] = 'up';
          case 'dots-size':
            next['size'] = 'large';
            next['dots'] = 4;
          case 'arrow-alternation':
            next['arrow'] = 'up';
          case 'two-fill-steps':
            next['fill'] = .25;
          case 'outline-triple':
            next['form'] = 'square';
          case 'four-tracks':
            next['form'] = 'square';
            next['size'] = 'medium';
            next['edgeLines'] = 4;
            next['line'] = 270;
          case 'corner-edge-count':
            next['dot'] = 'top-left';
            next['edgeLines'] = 5;
          case 'double-fill':
            next['fill'] = 'white';
          case 'transfer-count':
            next['dots'] = 3;
            next['edgeLines'] = 0;
          case 'interleaved-count':
            next['dots'] = 3;
          case 'fill-ray-dots':
            next['dots'] = 5;
          case 'size-corner-ray':
            break;
        }
        return next;
      }

      final answer = fixed ? sourceNext() : state(n + horizon - 1);
      final extraForm = pattern == 'outline-triple'
          ? (answer['form'] == 'triangle'
              ? 'square'
              : answer['form'] == 'square'
                  ? 'pentagon'
                  : null)
          : pattern == 'double-fill'
              ? (fixed ? 'circle' : forms[1])
              : null;
      if (pattern == 'outline-triple' &&
          (extraForm == null ||
              items.take(3).any((x) => x['form'] == extraForm))) {
        continue;
      }
      final figures = <Map<String, Object?>>[answer];
      final mistakes = t.mistakes.map((m) => m.id).toList();
      for (final mistake in mistakes) {
        final wrong = Map<String, Object?>.of(answer);
        switch (mistake) {
          case 'double-turn':
            wrong['line'] = ((last['line']! as num) +
                    2 *
                        (((items[1]['line']! as num) -
                                (first['line']! as num)) %
                            360)) %
                360;
          case 'early-restart':
            wrong['line'] = first['line'];
          case 'reverse-turn':
            wrong['line'] = ((last['line']! as num) -
                    (((items[1]['line']! as num) - (first['line']! as num)) %
                        360)) %
                360;
          case 'repeat-fill' || 'freeze-fill':
            wrong['fill'] = last['fill'];
          case 'average-fill':
            wrong['fill'] = .5;
          case 'gradual-fill':
            wrong['fill'] = .25;
          case 'reset-size-early':
            wrong['size'] = 'small';
          case 'freeze-size':
            wrong['size'] = last['size'];
          case 'one-step-only':
            if (pattern == 'two-arrow-turns') {
              wrong['arrow'] =
                  _arrows[(_arrows.indexOf(last['arrow']! as String) + 1) % 4];
            } else {
              wrong['fill'] =
                  (((last['fill']! as num) * 4).toInt() % 3 + 1) / 4;
            }
          case 'reverse-once':
            wrong['arrow'] =
                _arrows[(_arrows.indexOf(last['arrow']! as String) + 3) % 4];
          case 'zero-steps' || 'repeat-last' || 'continue-even-track':
            wrong
              ..clear()
              ..addAll(last);
          case 'freeze-dots':
            wrong['dots'] = last['dots'];
          case 'restart-dots-on-matching-size':
            wrong['dots'] = items[1]['dots'];
          case 'assume-continuous-turn':
            wrong['arrow'] =
                _arrows[(_arrows.indexOf(last['arrow']! as String) + 1) % 4];
          case 'invent-four-direction-cycle':
            wrong['arrow'] = _arrows[
                (_arrows.indexOf(items[1]['arrow']! as String) + 2) % 4];
          case 'keep-increasing' || 'accumulate-fill':
            wrong['fill'] = 1;
          case 'restart-early':
            wrong['form'] = first['form'];
          case 'increase-sides' || 'change-outline':
            wrong['form'] = extraForm;
          case 'freeze-edge-count' || 'freeze-lines' || 'freeze-edges':
            wrong['edgeLines'] = last['edgeLines'];
          case 'freeze-form-and-ray':
            wrong['form'] = last['form'];
            wrong['line'] = last['line'];
          case 'freeze-dot':
            wrong['dot'] = last['dot'];
          case 'skip-corner':
            wrong['dot'] =
                _corners[(_corners.indexOf(last['dot']! as String) + 2) % 4];
          case 'continue-majority-fill':
            wrong['fill'] = 'black';
          case 'restart-edge-count':
            wrong['edgeLines'] = first['edgeLines'];
          case 'count-all-positions':
            wrong['dots'] = 5;
          case 'repeat-odd-count':
            wrong['dots'] = items[items.length - 2]['dots'];
          case 'copy-even-count':
            wrong['dots'] = items[1]['dots'];
          case 'freeze-ray':
            wrong['line'] = last['line'];
          default:
            throw StateError('Unknown mistake $mistake');
        }
        figures.add(wrong);
      }
      if (!fixed &&
          [...items, ...figures].any(
            (item) => item['form'] == 'triangle' && item['fill'] == .25,
          )) {
        continue;
      }
      if (figures.map(dataKey).toSet().length != figures.length) continue;
      final cosmetic = ![
        'outline-triple',
        'four-tracks',
        'double-fill',
        'interleaved-count',
      ].contains(pattern);
      final params = <String, Object?>{
        'pattern': pattern,
        'items': items
            .map(
              (x) => {
                for (final e in x.entries)
                  if (!cosmetic || e.key != 'form') e.key: e.value,
              },
            )
            .toList(),
      };
      final slots = <String, Object?>{
        'horizon': horizon,
        if (extraForm != null) 'extraForm': extraForm,
        'answerText': _describe(answer),
        if (pattern == 'ray-step')
          'restartAction': first['line'] == last['line']
              ? 'the last ray again'
              : 'the first ray',
        if (answer['dots'] != null)
          'answerDotCount': [
            'zero',
            'one',
            'two',
            'three',
            'four',
            'five',
          ][answer['dots']! as int],
      };
      final choices = List.generate(
        figures.length,
        (i) => <String, Object?>{
          'text': fixed
              ? ((source['choices'] as List<dynamic>)[i]
                  as Map<String, dynamic>)['text']
              : pattern == 'outline-triple'
                  ? _outlineLabel(figures[i]['form']! as String)
                  : _describe(figures[i]),
          'figure': figures[i],
          if (i == 0) 'correct': true else 'mistake': mistakes[i - 1],
        },
      );
      final raw = <String, Object?>{
        'index': index,
        if (fixed) 'source': (source['id']! as String),
        'slots': slots,
        'figureSpec': {
          'kind': 'figure-series',
          'items': items,
          'blank': horizon == 1,
        },
        'choices': choices,
        'ruleKey': 'pending',
        'cosmetics': cosmetic ? {'form': first['form']} : <String, Object?>{},
        'signature': 'pending',
      };
      final before = parseVariants({
        'variants': [raw],
      }).single;
      final variant = parseVariants({
        'variants': [
          {...raw, 'signature': canonicalSignature(before)},
        ],
      }).single;
      return RuleResult(
        variant: variant,
        ruleParams: params,
        cosmetics: variant.cosmetics,
      );
    }
    throw StateError('$name: no valid noncolliding draw');
  }
}

String _outlineLabel(String form) => switch (form) {
      'triangle' => '3-sided polygon',
      'square' => '4-sided polygon',
      'pentagon' => '5-sided polygon',
      _ => '${form[0].toUpperCase()}${form.substring(1)}',
    };
String _arrowLabel(String direction) => switch (direction) {
      'up' => 'N',
      'right' => 'E',
      'down' => 'S',
      'left' => 'W',
      _ => throw StateError(direction),
    };

String _describe(Map<String, Object?> item) {
  final parts = <String>[
    if (item['size'] != null) '${item['size']}',
    if (item['fill'] != null)
      switch (item['fill']) {
        'black' => 'black',
        'white' => 'white',
        .25 => '25%-filled',
        .5 => '50%-filled',
        .75 => '75%-filled',
        _ => 'fully filled'
      },
    '${item['form']}',
  ];
  final text = parts.join(' ');
  final arrow = item['arrow'];
  final arrowDirection = arrow == null ? '' : _arrowLabel(arrow as String);
  final ray = item['line'];
  final direction = ray == null ? '' : _directions[(ray as num) % 360 ~/ 45];
  final dotLabel = item['dots'] == 1 ? 'dot' : 'dots';
  final edgeLabel = item['edgeLines'] == 1 ? 'edge line' : 'edge lines';
  return '${text[0].toUpperCase()}${text.substring(1)}'
      '${item['dots'] != null ? '; ${item['dots']} $dotLabel' : ''}'
      '${item['edgeLines'] != null ? '; ${item['edgeLines']} $edgeLabel' : ''}'
      '${item['dot'] != null ? '; dot ${item['dot']}' : ''}'
      '${ray != null ? '; line $direction' : ''}'
      '${arrow != null ? '; arrow $arrowDirection' : ''}';
}

// Standard compass abbreviations keep ray descriptions concise.
const _directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
