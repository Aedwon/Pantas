import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/no_middle_dot_separator.dart';

void main() {
  const path = 'lib/features/home/presentation/a.dart';

  test('the Nov 28 option "Verbal Ability · 30%" fails', () {
    final found = findMiddleDotSeparators(
      path,
      "\nfinal label = Text('Verbal Ability · 30%');",
    );
    expect(found.single.where, endsWith('a.dart:2'));
    expect(found.single.message, contains('·'));
  });

  test('middle dots and in-line bullets in shown text fail', () {
    for (final text in [
      r"'Part $part · $name'",
      r'"Reviews · Session 1 of 2"',
      r"'$exam · $plan'",
      "'equal time • equal swept area'",
      r"'near Sun\nlonger arc • faster'",
    ]) {
      expect(findMiddleDotSeparators(path, text), isNotEmpty, reason: text);
    }
  });

  test('the replacements, list bullets and comments pass', () {
    for (final text in [
      "'Analytical Ability (35%)'",
      r"'Part $part: $name'",
      "'Reviews: Session 1 of 2'",
      "marker = '•';",
      "'• Account: an account ID'",
      r"'Intro\n• Study records'",
      '// Part 2 · Verbal Ability',
      '/// "CSE Pro · Pro" was the old line',
    ]) {
      expect(findMiddleDotSeparators(path, text), isEmpty, reason: text);
    }
  });
}
