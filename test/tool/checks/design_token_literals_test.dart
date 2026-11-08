import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/design_token_literals.dart';

List<String> found(String code, {String path = 'lib/features/x/a.dart'}) =>
    findTokenLiterals({path: code}, const {}).map((v) => v.message).toList();

void main() {
  test('a hand-typed color fails', () {
    for (final bad in [
      'const c = Color(0xFF112233);',
      'final c = Color.fromRGBO(1, 2, 3, .5);',
      'final c = Color.fromARGB(255, 1, 2, 3);',
      'final c = Colors.red;',
      'final c = Colors.white;',
    ]) {
      expect(found(bad), hasLength(1), reason: bad);
    }
  });

  test('a hand-typed size, spacing, radius or curve fails', () {
    for (final bad in [
      'const s = TextStyle(fontSize: 17);',
      'const s = TextStyle(fontSize: 13.5);',
      'const p = EdgeInsets.all(16);',
      'const p = EdgeInsets.symmetric(horizontal: 20, vertical: 4);',
      'const p = EdgeInsets.fromLTRB(44, 28, 44, 0);',
      'const p = EdgeInsets.only(\n  top: 8,\n);',
      'const b = SizedBox(width: 12);',
      'const b = SizedBox(height: 8, child: x);',
      'final r = BorderRadius.circular(14);',
      'final r = Radius.circular(8);',
      'const c = Cubic(.2, .9, .3, 1);',
    ]) {
      expect(found(bad), hasLength(1), reason: bad);
    }
  });

  test('token reads, transparent and comments pass', () {
    for (final good in [
      'final c = Colors.transparent;',
      'final c = context.colors.textPrimary;',
      'final s = PantasType.webH1;',
      'final p = EdgeInsets.all(PantasSpace.s16);',
      'final p = EdgeInsets.symmetric(horizontal: PantasSpace.s20);',
      'const p = EdgeInsets.zero;',
      'final b = SizedBox(width: PantasSpace.s12);',
      'final b = SizedBox(width: size, height: size);',
      'final r = BorderRadius.circular(PantasRadius.md);',
      'final r = Radius.circular(radius);',
      'final c = PantasCurves.enter;',
      '// Color(0xFF112233) in a comment',
      '/// fontSize: 17 in a doc comment',
      'final c = x; // Colors.red in a trailing comment',
      "final t = 'Colors.red in a string';",
    ]) {
      expect(found(good), isEmpty, reason: good);
    }
  });

  test('the token and motion folders are exempt', () {
    const code = 'const c = Color(0xFF112233); const k = Cubic(0, 0, 1, 1);';
    expect(
      found(code, path: 'lib/core/ui/theme/tokens/pantas_colors.dart'),
      isEmpty,
    );
    expect(found(code, path: 'lib/core/ui/motion/press_scale.dart'), isEmpty);
    expect(found(code, path: 'lib/core/ui/components/card.dart'), hasLength(2));
  });

  test('a listed folder or file is skipped, any other still fails', () {
    const code = 'const c = Color(0xFF112233);';
    final allow = parseAllowlist(
      '# not yet migrated\n\nlib/features/home/\nlib/core/error/a.dart\n',
    );
    expect(
      findTokenLiterals({'lib/features/home/presentation/p.dart': code}, allow),
      isEmpty,
    );
    expect(findTokenLiterals({'lib/core/error/a.dart': code}, allow), isEmpty);
    expect(
      findTokenLiterals({'lib/features/quiz/p.dart': code}, allow),
      hasLength(1),
    );
    expect(
      findTokenLiterals({'lib/core/error/b.dart': code}, allow),
      hasLength(1),
    );
  });

  test('a finding names the file and line', () {
    final v = findTokenLiterals(
      {'lib/features/x/a.dart': 'final a = 1;\nconst c = Colors.red;\n'},
      const {},
    ).single;
    expect(v.where, 'lib/features/x/a.dart:2');
  });
}
