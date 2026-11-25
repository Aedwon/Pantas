import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/internal_terms.dart';

void main() {
  test('the old board string "Taste finished" fails', () {
    final found = findInternalTerms(
      'lib/features/first_run/presentation/widgets/end.dart',
      "\nfinal title = Text('Taste finished');",
    );
    expect(found.single.where, endsWith('end.dart:2'));
    expect(found.single.message, contains('Taste'));
  });

  test('lane words and codes in shown text fail', () {
    for (final text in [
      "'Your first run'",
      '"Guided tour"',
      "'Starter lesson'",
      "'See E-179'",
      "'Ruling D191'",
      "'Fix U46'",
    ]) {
      expect(
        findInternalTerms('lib/features/home/presentation/a.dart', text),
        isNotEmpty,
        reason: text,
      );
    }
  });

  test('the shipped wording, keys, comments and the free trial pass', () {
    for (final text in [
      "'Try Pantas first'",
      "'You finished the lesson'",
      "const ValueKey('first_run_intro')",
      r"key: ValueKey('first-run-question-$index')",
      r"'Mon \u2013 Sun \u2191'",
      '// the first run starts after setup',
      "'Free for 7 days, then ₱99 a month.'",
      "'Start your free trial'",
      "import 'package:pantas/features/first_run/x.dart';",
    ]) {
      expect(
        findInternalTerms('lib/features/home/presentation/a.dart', text),
        isEmpty,
        reason: text,
      );
    }
  });

  test('code outside presentation is not checked', () {
    expect(
      findInternalTerms(
        'lib/features/first_run/data/store.dart',
        "const key = 'first run pending';",
      ),
      isEmpty,
    );
  });
}
