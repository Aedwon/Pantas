import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_layering.dart';

const _ds = "import 'package:pantas/core/ui/ds.dart';";
const _raw = "import 'package:pantas/core/ui/raw_controls.dart';";

void main() {
  group('R4: screens do not import the framework controls', () {
    test('material in a feature fails', () {
      final v = findLayeringViolations({
        'lib/features/quiz/presentation/a.dart':
            "import 'package:flutter/material.dart';\n",
      });
      expect(v, hasLength(1));
      expect(v.single, startsWith('R4 '));
    });

    test('cupertino and aliased material in lib/app fail', () {
      final v = findLayeringViolations({
        'lib/app/a.dart': "import 'package:flutter/cupertino.dart';\n",
        'lib/app/b.dart': "import 'package:flutter/material.dart' as m;\n",
      });
      expect(v.where((e) => e.startsWith('R4 ')), hasLength(2));
    });

    test('the design-system import, widgets and core pass', () {
      expect(
        findLayeringViolations({
          'lib/features/quiz/presentation/a.dart': '$_ds\n',
          'lib/app/b.dart': "import 'package:flutter/widgets.dart';\n",
          'lib/core/ui/c.dart': "import 'package:flutter/material.dart';\n",
        }),
        isEmpty,
      );
    });
  });

  group('R5: the raw-controls import carries a reason', () {
    test('no marker fails', () {
      final v = findLayeringViolations({
        'lib/features/a/presentation/a.dart': '$_ds\n$_raw\n',
      });
      expect(v.single, startsWith('R5 '));
    });

    test('an empty reason fails', () {
      final v = findLayeringViolations({
        'lib/features/a/presentation/a.dart': '// ds-raw:\n$_raw\n',
      });
      expect(v.single, startsWith('R5 '));
    });

    test('a marker two lines above fails', () {
      final v = findLayeringViolations({
        'lib/features/a/presentation/a.dart': '// ds-raw: why\n$_ds\n$_raw\n',
      });
      expect(v.single, startsWith('R5 '));
    });

    test('a reason on the line above passes', () {
      expect(
        findLayeringViolations({
          'lib/features/a/presentation/a.dart':
              '$_ds\n// ds-raw: bare input, no box\n$_raw\n',
        }),
        isEmpty,
      );
    });

    test('a reason on the same line passes', () {
      expect(
        findLayeringViolations({
          'lib/app/a.dart': '$_raw // ds-raw: bare input\n',
        }),
        isEmpty,
      );
    });

    test('core may import it without a marker', () {
      expect(
        findLayeringViolations({'lib/core/ui/a.dart': '$_raw\n'}),
        isEmpty,
      );
    });
  });

  test('the earlier rules still hold', () {
    final v = findLayeringViolations({
      'lib/core/a.dart': "import 'package:pantas/features/x/y.dart';\n",
      'lib/features/a/domain/b.dart':
          "import 'package:flutter/widgets.dart';\n",
      'lib/features/a/presentation/c.dart':
          "import 'package:pantas/features/b/presentation/d.dart';\n",
    });
    expect(v.map((e) => e.substring(0, 2)), ['R1', 'R3', 'R2']);
  });
}
