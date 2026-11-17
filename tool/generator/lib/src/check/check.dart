import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../model.dart';
import 'markup.dart';
import 'signature.dart';
import 'solvers/solver.dart';

class CheckFailure {
  CheckFailure(this.typeId, this.index, this.check, this.reason);
  final String typeId;
  final int index;
  final String check;
  final String reason;
  @override
  String toString() => '$typeId #$index $check: '
      '${reason.replaceAll(RegExp(r'\s+'), ' ')}';
}

/// Braces belonging to TeX arguments are not template placeholders.
/// Use an extra brace pair for a slot in an argument: `\dfrac{{a}}{{b}}`.
Iterable<RegExpMatch> _slotMatches(String text) {
  final arguments = <int>{};
  for (final command in RegExp(r'\\[A-Za-z]+\*?|[\^_]').allMatches(text)) {
    // Only commands taking braced arguments claim braces. Operators such as
    // \times must leave a following placeholder available for substitution.
    // Extend these arities when a type adds another command with arguments.
    var remaining = switch (command.group(0)!.replaceAll('*', '')) {
      r'\frac' ||
      r'\dfrac' ||
      r'\tfrac' ||
      r'\binom' ||
      r'\dbinom' ||
      r'\tbinom' ||
      r'\overset' ||
      r'\underset' ||
      r'\stackrel' =>
        2,
      '^' ||
      '_' ||
      r'\sqrt' ||
      r'\text' ||
      r'\textrm' ||
      r'\textbf' ||
      r'\textit' ||
      r'\operatorname' ||
      r'\mathrm' ||
      r'\mathbf' ||
      r'\mathit' ||
      r'\mathsf' ||
      r'\mathtt' ||
      r'\mathbb' ||
      r'\mathcal' ||
      r'\mathfrak' ||
      r'\overline' ||
      r'\underline' ||
      r'\overbrace' ||
      r'\underbrace' ||
      r'\boxed' ||
      r'\phantom' ||
      r'\hphantom' ||
      r'\vphantom' ||
      r'\bar' ||
      r'\hat' ||
      r'\widehat' ||
      r'\vec' ||
      r'\dot' ||
      r'\ddot' ||
      r'\tilde' ||
      r'\widetilde' =>
        1,
      _ => 0,
    };
    var cursor = command.end;
    while (cursor < text.length && remaining > 0) {
      if (text[cursor].trim().isEmpty) {
        cursor++;
        continue;
      }
      // Optional TeX arguments, such as the root degree in \sqrt[3]{x}.
      final optional = text[cursor] == '[';
      if (!optional && text[cursor] != '{') break;
      if (!optional) {
        arguments.add(cursor);
        remaining--;
      }
      final open = optional ? '[' : '{';
      final close = optional ? ']' : '}';
      var depth = 0;
      do {
        if (text[cursor] == r'\') {
          cursor += 2;
          continue;
        }
        if (text[cursor] == open) depth++;
        if (text[cursor] == close) depth--;
        cursor++;
      } while (cursor < text.length && depth > 0);
    }
  }
  return RegExp(r'\{([A-Za-z][A-Za-z0-9_]*)\}')
      .allMatches(text)
      .where((match) => !arguments.contains(match.start));
}

String fillSlots(String text, Map<String, Object?> slots) {
  final result = StringBuffer();
  var cursor = 0;
  for (final match in _slotMatches(text)) {
    result
      ..write(text.substring(cursor, match.start))
      ..write(slots[match.group(1)]?.toString() ?? match.group(0)!);
    cursor = match.end;
  }
  return (result..write(text.substring(cursor))).toString();
}

/// Sources are parsed hand-written YAML questions keyed by id, never generated
/// questions. The CLI reads them from the designated production content ref.
List<CheckFailure> checkVariants(
  ProblemType type,
  List<Variant> variants, {
  Map<String, Map<String, Object?>> questions = const {},
}) {
  final failures = <CheckFailure>[];
  void report(int index, String check, String reason) =>
      failures.add(CheckFailure(type.id, index, check, reason));
  if (!mathSolvers.containsKey(type.rule) &&
      !figureSolvers.containsKey(type.rule)) {
    report(
      variants.isEmpty ? 0 : variants.first.index,
      'correctness',
      'no solver for rule ${type.rule}',
    );
  }
  final signatures = <String>{};
  final declaredSignatures = <String>{};
  final indexes = <int>{};
  for (final variant in variants) {
    void run(String check, void Function() body) {
      try {
        body();
      } on Object catch (error) {
        report(variant.index, check, '$error');
      }
    }

    void fail(String check, String reason) =>
        report(variant.index, check, reason);
    final math = mathSolvers[type.rule];
    final figure = figureSolvers[type.rule];
    final solver = variant.figureSpec == null ? math : figure;
    Map<String, Object?> candidate(VariantChoice choice) =>
        type.choiceKind == 'figure'
            ? choice.figure ?? <String, Object?>{}
            : {
                'text':
                    fillSlots(choice.text, {...variant.slots, ...choice.slots}),
                if (choice.value != null) 'value': choice.value,
              };
    run('ruleKey', () {
      if (solver == null) {
        fail('ruleKey', 'no independent solver');
        return;
      }
      final expected = sha256
          .convert(
            utf8.encode(
              dataKey(solver.ruleParams(type, variant)),
            ),
          )
          .toString();
      if (expected != variant.ruleKey) {
        fail('ruleKey', 'independent parameters do not match ruleKey');
      }
    });
    run('cosmetics', () {
      if (solver == null) {
        fail('cosmetics', 'no independent solver');
        return;
      }
      for (final reason in solver.validateCosmetics(type, variant)) {
        fail('cosmetics', reason);
      }
    });
    run('choiceKind', () {
      for (final choice in variant.choices) {
        if (type.choiceKind == 'text' && choice.toMap().containsKey('figure')) {
          fail('choiceKind', 'text choice carries figure');
        }
        if (type.choiceKind == 'figure' &&
            (choice.figure == null || choice.text.trim().isEmpty)) {
          fail('choiceKind', 'figure choice requires figure and nonempty text');
        }
      }
    });
    run('correctness', () {
      if (solver == null) {
        fail('correctness', 'no solver for rule ${type.rule}');
        return;
      }
      final choices = variant.choices;
      if (choices.where((c) => c.correct).length != 1) {
        fail('correctness', 'expected exactly one marked correct choice');
      }
      if (variant.figureSpec == null) {
        final answer = math!.solve(type, variant);
        final solved = choices
            .where((c) => c.value != null && Rational.parse(c.value!) == answer)
            .toList();
        if (solved.length != 1 || !solved.single.correct) {
          fail(
            'correctness',
            'independent answer $answer does not match one key',
          );
        }
      } else {
        final shown = variant.figureSpec!;
        if (figure!.kind != shown['kind']) {
          fail('correctness', 'solver figure kind does not match shown kind');
          return;
        }
        final solved = choices
            .where((c) => figure.fits(shown, candidate(c), variant.slots))
            .toList();
        if (solved.length != 1 || !solved.single.correct) {
          fail(
            'correctness',
            'shown figures do not support exactly one keyed answer',
          );
        }
        for (final alternative
            in figureSolvers.values.where((s) => s.kind == figure.kind)) {
          for (final choice in choices.where((c) => !c.correct)) {
            if (alternative.fits(shown, candidate(choice), variant.slots)) {
              fail('correctness', 'wrong choice completes a library rule');
            }
          }
        }
      }
    });
    run('choices', () {
      if (variant.choices.length != type.choiceCount) {
        fail('choices', 'expected ${type.choiceCount} choices');
      }
      final texts = <String>{};
      final values = <String>{};
      for (final choice in variant.choices) {
        final text =
            fillSlots(choice.text, {...variant.slots, ...choice.slots});
        if (!texts.add(text)) fail('choices', 'duplicate choice text');
        final Object value;
        if (variant.figureSpec == null) {
          value = Rational.parse(choice.value ?? '');
        } else if (type.choiceKind == 'text') {
          value = candidate(choice);
        } else {
          if (choice.figure == null) {
            fail('choices', 'missing choice figure');
            continue;
          }
          value = choice.figure!;
        }
        final key = value is Rational ? value.toString() : dataKey(value);
        if (!values.add(key)) fail('choices', 'duplicate choice value');
        if (choice.correct) continue;
        final id = choice.mistake;
        if (!type.mistakes.any((m) => m.id == id)) {
          fail('choices', 'unknown mistake $id');
          continue;
        }
        final mistake = mistakeSolvers[(type.rule, id!)];
        if (mistake == null) {
          fail('choices', 'no mistake solver for ${type.rule}/$id');
        } else {
          final expected = mistake(type, variant);
          if (value is Rational
              ? value != expected
              : dataKey(value) != dataKey(expected)) {
            fail('choices', 'choice differs from mistake $id');
          }
        }
      }
    });
    run('signature', () {
      if (!indexes.add(variant.index)) fail('signature', 'duplicate index');
      if (!declaredSignatures.add(variant.signature)) {
        fail('signature', 'duplicate stored signature');
      }
      if (!signatures.add(canonicalSignature(variant))) {
        fail('signature', 'duplicate canonical signature');
      }
    });
    run('ranges-text', () {
      if (solver != null) {
        for (final reason in solver.validateRanges(type, variant)) {
          fail('ranges-text', reason);
        }
      }
      void text(String template, Map<String, Object?> slots) {
        final rendered = fillSlots(template, slots);
        for (final slot in _slotMatches(template)) {
          if (!slots.containsKey(slot.group(1)) ||
              slots[slot.group(1)] == null ||
              slots[slot.group(1)].toString().isEmpty) {
            fail('ranges-text', 'unfilled slot ${slot.group(0)}');
          }
        }
        if (_slotMatches(rendered).isNotEmpty) {
          fail('ranges-text', 'unfilled slot after rendering');
        }
        for (final reason in checkMarkup(rendered)) {
          fail('ranges-text', reason);
        }
      }

      text(type.stem, variant.slots);
      text(type.explanation, variant.slots);
      for (final choice in variant.choices) {
        final slots = {...variant.slots, ...choice.slots};
        text(choice.text, slots);
        for (final mistake
            in type.mistakes.where((m) => m.id == choice.mistake)) {
          text(mistake.note, slots);
        }
      }
    });
  }
  // Phase 1 proxy; Task 2.1 must measure the actual exported Free document.
  final bytes = utf8
      .encode(
        jsonEncode({
          'variants': variants.map((v) => v.toMap()).toList(),
        }),
      )
      .length;
  if (bytes >= 200000) {
    report(
      variants.isEmpty ? 0 : variants.first.index,
      'size',
      'variant-list JSON is $bytes bytes, must be under 200000',
    );
  }
  for (final merged in type.mergedQuestions) {
    final matches = variants.where((v) => v.index == merged.index).toList();
    final source = questions[merged.id];
    if (matches.length != 1 || source == null) {
      report(
        merged.index,
        'merged',
        'missing variant or source question ${merged.id}',
      );
      continue;
    }
    final variant = matches.single;
    try {
      final sourceChoices =
          (source['choices']! as List).cast<Map<String, Object?>>();
      final correct = sourceChoices.where((c) => c['correct'] == true).toList();
      final actualCorrect = variant.choices.where((c) => c.correct).toList();
      final wrong = sourceChoices
          .where((c) => c['correct'] != true)
          .map((c) => c['text']! as String)
          .toList()
        ..sort();
      final actualWrong = variant.choices
          .where((c) => !c.correct)
          .map((c) => fillSlots(c.text, {...variant.slots, ...c.slots}))
          .toList()
        ..sort();
      if (variant.source != merged.id ||
          source['stem'] != fillSlots(type.stem, variant.slots) ||
          dataKey(source['figureSpec']) != dataKey(variant.figureSpec) ||
          correct.length != 1 ||
          actualCorrect.length != 1 ||
          correct.single['text'] !=
              fillSlots(
                actualCorrect.single.text,
                {...variant.slots, ...actualCorrect.single.slots},
              ) ||
          dataKey(wrong) != dataKey(actualWrong)) {
        report(
          merged.index,
          'merged',
          'does not reproduce ${merged.id} exactly',
        );
      }
    } on Object catch (error) {
      report(merged.index, 'merged', 'invalid source ${merged.id}: $error');
    }
  }
  return failures;
}
