import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pantas_lints/src/ds_board_value_reason.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'support.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DsBoardValueReasonTest);
  });
}

@reflectiveTest
class DsBoardValueReasonTest extends AnalysisRuleTest with AnnotatedAsserts {
  @override
  void setUp() {
    rule = DsBoardValueReason();
    writeSupport();
    super.setUp();
  }

  static const _use = 'Widget use() => const SizedBox(width: _gap);\n';

  Future<void> test_top_level_const_double_that_reaches_a_size() =>
      assertMarkedIn(
        'features/a/page.dart',
        '$importFlutter\nconst double «_gap» = 12;\n$_use',
      );

  Future<void> test_static_const_double_duration_and_color() =>
      assertMarkedIn('app/shell.dart', '''
$importFlutter
class Shell {
  static const double «width» = 280;
  static const Duration «fade» = Duration(milliseconds: 90);
  static const Color «ink» = Color(0xFF101010);
  Widget build() => const Container(
    width: width,
    color: ink,
    child: Fade(duration: fade),
  );
}
''');

  Future<void> test_const_that_reaches_through_arithmetic() =>
      assertMarkedIn('features/a/page.dart', '''
$importFlutter
const double «_base» = 12;
const double «_gap» = _base + 4;
Widget use() => const SizedBox(width: _gap);
''');

  Future<void> test_const_that_never_reaches_a_design_parameter_is_clean() =>
      assertMarkedIn('features/a/page.dart', '''
const double weakToStrongStabilityDays = 12;
const Duration _timeout = Duration(seconds: 30);
double days() => weakToStrongStabilityDays * 2;
Duration wait() => _timeout;
''');

  Future<void> test_public_const_used_only_elsewhere_is_out_of_reach() =>
      assertMarkedIn('features/a/page.dart', '''
const double publicGap = 12;
''');

  Future<void> test_inferred_type_is_checked() => assertMarkedIn(
    'features/a/page.dart',
    '$importFlutter\nconst «_gap» = 12.0;\n$_use',
  );

  Future<void> test_marker_on_the_same_line() => assertMarkedIn(
    'features/a/page.dart',
    '$importFlutter\nconst double _gap = 12; // ds-board: Home board, row gap\n'
        '$_use',
  );

  Future<void> test_marker_on_the_line_above() => assertMarkedIn(
    'features/a/page.dart',
    '$importFlutter\n// ds-board: Home board, row gap\n'
        'const double _gap = 12;\n$_use',
  );

  Future<void> test_marker_above_a_doc_comment_does_not_count() =>
      assertMarkedIn(
        'features/a/page.dart',
        '$importFlutter\n// ds-board: Home board, row gap\n'
            '/// The gap.\n'
            'const double «_gap» = 12;\n$_use',
      );

  Future<void> test_marker_without_a_reason_does_not_count() => assertMarkedIn(
    'features/a/page.dart',
    '$importFlutter\nconst double «_gap» = 12; // ds-board:\n$_use',
  );

  Future<void> test_final_and_int_and_instance_fields_are_clean() =>
      assertMarkedIn('features/a/page.dart', '''
final double runtimeGap = 12;
const int count = 3;
const String label = 'x';

class Row {
  const Row();
  final double gap = 4;
}
''');

  Future<void> test_core_and_theme_are_not_checked() async {
    await assertMarkedIn(
      'core/ui/components/card.dart',
      '$importFlutter\nconst double _gap = 12;\n$_use',
    );
    await assertMarkedIn(
      'core/ui/theme/tokens/gap.dart',
      '$importFlutter\nconst double _gap = 12;\n$_use',
    );
  }
}
