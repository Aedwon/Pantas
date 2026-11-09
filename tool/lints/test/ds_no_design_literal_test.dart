import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pantas_lints/src/ds_no_design_literal.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'support.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DsNoDesignLiteralTest);
  });
}

@reflectiveTest
class DsNoDesignLiteralTest extends AnalysisRuleTest with AnnotatedAsserts {
  @override
  void setUp() {
    rule = DsNoDesignLiteral();
    writeSupport();
    super.setUp();
  }

  String body(String statements) =>
      '''
$importFlutter
${RegExp(r'\b(Space|Dur|Palette)\.').hasMatch(statements) ? importTokens : ''}

Widget build(bool flag, double scale) {
  $statements
}
''';

  // ---- sizes ----------------------------------------------------------------

  Future<void> test_sizedBox_width_literal() =>
      assertMarked(body('return const SizedBox(width: «10»);'));

  Future<void> test_sizedBox_height_double_literal() =>
      assertMarked(body('return const SizedBox(height: «10.5»);'));

  Future<void> test_sizedBox_square_dimension() =>
      assertMarked(body('return const SizedBox.square(dimension: «40»);'));

  Future<void> test_container_width_and_height() =>
      assertMarked(body('return const Container(width: «100», height: «50»);'));

  Future<void> test_sizedBox_token_is_clean() => assertNoDiagnostics(
    body('return const SizedBox(width: Space.md, height: Space.lg);'),
  );

  Future<void> test_zero_is_not_a_design_value() => assertNoDiagnostics(
    body('return const SizedBox(width: 0, height: 0.0);'),
  );

  Future<void> test_other_widget_parameters_are_not_checked() =>
      assertNoDiagnostics(body('return const Gap(size: 12);'));

  Future<void> test_boxConstraints_literal() => assertMarked(
    body(
      'return const Container(constraints: BoxConstraints(maxWidth: «320»));',
    ),
  );

  // ---- spacing --------------------------------------------------------------

  Future<void> test_edgeInsets_all() => assertMarked(
    body('return const Container(margin: EdgeInsets.all(«8»));'),
  );

  Future<void> test_edgeInsets_symmetric_reports_each_literal() => assertMarked(
    body(
      'return const Container(margin: '
      'EdgeInsets.symmetric(vertical: «4», horizontal: «12»));',
    ),
  );

  Future<void> test_edgeInsets_zero_and_tokens_are_clean() =>
      assertNoDiagnostics(
        body(
          'return const Container(margin: '
          'EdgeInsets.only(left: Space.md, top: 0));',
        ),
      );

  Future<void> test_edgeInsets_token_plus_literal() => assertMarked(
    body('return Container(margin: EdgeInsets.all(Space.md + «4»));'),
  );

  Future<void>
  test_edgeInsets_token_scaled_by_literal_is_clean() => assertNoDiagnostics(
    body(
      'return Container(margin: EdgeInsets.all(Space.md * 2 + Space.lg / 2));',
    ),
  );

  Future<void> test_two_literals_multiplied_are_reported() => assertMarked(
    body('return Container(margin: EdgeInsets.all(«2» * «3»));'),
  );

  Future<void> test_a_divisor_does_not_carry_the_value() =>
      assertNoDiagnostics('''
$importFlutter

const double _base = 40;

Widget build(double w) => SizedBox(width: w / _base);
''');

  // ---- text -----------------------------------------------------------------

  Future<void> test_textStyle_fontSize_letterSpacing_height() => assertMarked(
    body('''
const style = TextStyle(fontSize: «14», letterSpacing: «0.5», height: «1.4»);
  return Container(width: style.hashCode.toDouble());'''),
  );

  Future<void> test_textStyle_copyWith_fontSize() => assertMarked(
    body('''
final style = const TextStyle().copyWith(fontSize: «15»);
  return Container(width: style.hashCode.toDouble());'''),
  );

  // ---- colors ---------------------------------------------------------------

  Future<void> test_color_hex() =>
      assertMarked(body('return const Container(color: Color(«0xFF112233»));'));

  Future<void> test_color_fromARGB_and_fromRGBO() => assertMarked(
    body(
      'return const Container(color: Color.fromARGB(«255», «10», 0, «20»));',
    ),
  );

  Future<void> test_color_in_a_private_const() => assertMarked('''
$importFlutter

const _ink = Color(«0xFF000001»);

Color pick() => _ink;
''');

  Future<void> test_colors_name() =>
      assertMarked(body('return const Container(color: «Colors.red»);'));

  Future<void> test_colors_name_with_alpha_reports_the_name_once() =>
      assertMarked(
        body('return Container(color: «Colors.white».withValues(alpha: 0.5));'),
      );

  Future<void> test_colors_transparent_is_allowed() => assertNoDiagnostics(
    body('return const Container(color: Colors.transparent);'),
  );

  Future<void> test_color_from_a_token_is_clean() =>
      assertNoDiagnostics(body('return const Container(color: Palette.ink);'));

  // ---- radius and curves ----------------------------------------------------

  Future<void> test_borderRadius_circular() => assertMarked('''
$importFlutter

BorderRadius radius() => const BorderRadius.circular(«8»);
''');

  Future<void> test_radius_circular() => assertMarked('''
$importFlutter

BorderRadius radius() => const BorderRadius.all(Radius.circular(«4»));
''');

  Future<void> test_radius_zero_is_clean() => assertNoDiagnostics('''
$importFlutter

BorderRadius radius() => const BorderRadius.circular(0);
''');

  Future<void> test_cubic() => assertMarked('''
$importFlutter

const curve = Cubic(«0.2», 0, «0.2», «1»);
''');

  // ---- durations ------------------------------------------------------------

  Future<void> test_duration_reaching_an_animation_parameter() => assertMarked(
    body(
      'return const Fade(duration: Duration(milliseconds: «200»), '
      'reverseDuration: Duration(seconds: «1»));',
    ),
  );

  Future<void> test_duration_zero_and_tokens_are_clean() => assertNoDiagnostics(
    body(
      'return const Fade(duration: Duration.zero, '
      'reverseDuration: Dur.fast);',
    ),
  );

  Future<void> test_duration_outside_animation_apis_is_clean() =>
      assertNoDiagnostics('''
Future<void> wait() => Future<void>.delayed(const Duration(seconds: 3));
''');

  // ---- following values -----------------------------------------------------

  Future<void> test_conditional_reports_both_branches() =>
      assertMarked(body('return SizedBox(width: flag ? «8» : «12»);'));

  Future<void> test_local_final_is_followed_to_the_use() => assertMarked(
    body('''
const gap = 12.0;
  return const SizedBox(width: «gap»);'''),
  );

  Future<void> test_chain_of_variables_reports_at_the_outer_use() =>
      assertMarked('''
$importFlutter

const double _wide = 80;
const double _narrow = 60;

Widget build(bool flag) {
  final size = flag ? _wide : _narrow;
  return SizedBox(width: «size»);
}
''');

  Future<void> test_private_const_is_followed_to_the_use() => assertMarked('''
$importFlutter

const double _gap = 20;

Widget build() => const SizedBox(height: «_gap»);
''');

  Future<void> test_variable_derived_from_a_token_is_clean() =>
      assertNoDiagnostics(
        body('''
final gap = Space.md * 2;
  return SizedBox(width: gap);'''),
      );

  Future<void> test_clamp_and_max_reach_the_parameter() => assertMarked(
    body('return SizedBox(width: scale.clamp(«10», Space.lg));'),
  );

  Future<void> test_duration_const_is_followed() => assertMarked('''
$importFlutter

const _slow = Duration(milliseconds: 900);

Widget build() => const Fade(duration: «_slow»);
''');

  // ---- markers --------------------------------------------------------------

  Future<void> test_geometry_marker_exempts_a_radius_on_its_line() =>
      assertNoDiagnostics('''
$importFlutter

BorderRadius radius() =>
    const BorderRadius.circular(18); // ds-geometry: logo corner
''');

  Future<void> test_geometry_marker_on_the_line_that_starts_the_argument() =>
      assertNoDiagnostics('''
$importFlutter

BorderRadius radius() => const BorderRadius.only(
  topLeft: Radius.circular( // ds-geometry: arc of the dial
    18,
  ),
);
''');

  Future<void> test_geometry_marker_does_not_reach_past_the_design_value() =>
      assertMarked('''
$importFlutter

Widget build() => Container( // ds-geometry: not for this call
  margin: const EdgeInsets.all(«8»),
);
''');

  Future<void> test_geometry_marker_exempts_a_cubic() => assertNoDiagnostics('''
$importFlutter

const curve = Cubic(0.2, 0.5, 0.2, 1); // ds-geometry: data file easing
''');

  Future<void> test_geometry_marker_without_a_reason_does_not_exempt() =>
      assertMarked('''
$importFlutter

BorderRadius radius() =>
    const BorderRadius.circular(«18»); // ds-geometry:
''');

  Future<void> test_geometry_marker_never_exempts_a_font_size() => assertMarked(
    body('''
const style = TextStyle(fontSize: «14»); // ds-geometry: not allowed here
  return Container(width: style.hashCode.toDouble());'''),
  );

  Future<void> test_geometry_marker_never_exempts_a_color() => assertMarked(
    body(
      'return const Container(color: Color(«0xFF123456»)); '
      '// ds-geometry: not allowed here',
    ),
  );

  Future<void> test_geometry_marker_never_exempts_spacing() => assertMarked(
    body(
      'return const Container(margin: EdgeInsets.all(«8»)); '
      '// ds-geometry: not allowed here',
    ),
  );

  // ---- ds-board ---------------------------------------------------------------

  Future<void> test_board_marker_exempts_a_size_on_its_line() =>
      assertNoDiagnostics(
        body(
          'return const SizedBox(width: 280); // ds-board: Home board, rail',
        ),
      );

  Future<void> test_board_marker_exempts_spacing_duration_and_text_size() =>
      assertNoDiagnostics(
        body(
          '''
const style = TextStyle(fontSize: 13); // ds-board: Quiz board, stem size
  const margin = EdgeInsets.all(6); // ds-board: Quiz board, chip gap
  const fade = Fade(duration: Duration(milliseconds: 90)); // ds-board: motion board
  return Container(width: style.hashCode.toDouble() + margin.hashCode + fade.hashCode);''',
        ),
      );

  Future<void> test_marker_on_a_comment_line_just_above() =>
      assertNoDiagnostics(
        body('''// ds-board: Home board, rail width, no token for 280
  return const SizedBox(width: 280);'''),
      );

  Future<void> test_marker_trailing_the_previous_statement_does_not_count() =>
      assertMarked(
        body(
          '''const a = SizedBox(width: 0); // ds-board: only for the line above
  return const SizedBox(width: «280»);''',
        ),
      );

  Future<void> test_clamp_to_a_unit_and_counts_are_not_design_values() =>
      assertNoDiagnostics(
        body(
          'return SizedBox(width: Space.md * scale.clamp(0, 1).toDouble());',
        ),
      );

  Future<void> test_board_marker_never_exempts_a_color() => assertMarked(
    body(
      'return const Container(color: Color(«0xFF123456»)); '
      '// ds-board: not allowed here',
    ),
  );

  Future<void> test_board_marker_without_a_reason_does_not_exempt() =>
      assertMarked(body('return const SizedBox(width: «280»); // ds-board:'));

  Future<void> test_board_marker_on_the_line_that_starts_the_argument() =>
      assertNoDiagnostics(
        body('''return const Container(
    margin: EdgeInsets.symmetric( // ds-board: Quiz board, chip gap
      vertical: 6,
      horizontal: 9,
    ),
  );'''),
      );

  Future<void> test_const_with_a_board_marker_is_accepted_at_its_use() =>
      assertNoDiagnostics('''
$importFlutter

const double _rail = 280; // ds-board: Home board, rail width

Widget build() => const SizedBox(width: _rail);
''');

  Future<void> test_const_with_a_board_marker_on_the_line_above() =>
      assertNoDiagnostics('''
$importFlutter

// ds-board: Home board, rail width
const double _rail = 280;

Widget build() => const SizedBox(width: _rail);
''');

  Future<void> test_icons_and_figures_folders_are_exempt() async {
    await assertMarkedIn('core/ui/icons/own/glyph.dart', '''
$importFlutter

const gap = SizedBox(width: 12);
''');
    await assertMarkedIn('core/ui/figures/diagram.dart', '''
$importFlutter

const gap = SizedBox(width: 12);
''');
  }

  // ---- scope ----------------------------------------------------------------

  Future<void> test_token_folder_is_exempt() =>
      assertMarkedIn('core/ui/theme/tokens/extra.dart', '''
$importFlutter

const gap = SizedBox(width: 12);
''');

  Future<void> test_motion_folder_is_exempt() =>
      assertMarkedIn('core/ui/motion/fade.dart', '''
$importFlutter

const fade = Fade(duration: Duration(milliseconds: 90));
''');

  Future<void> test_generated_files_are_exempt() =>
      assertMarkedIn('features/a/model.g.dart', '''
$importFlutter

const gap = SizedBox(width: 12);
''');

  Future<void> test_features_are_checked() =>
      assertMarkedIn('features/a/page.dart', '''
$importFlutter

const gap = SizedBox(width: «12»);
''');

  Future<void> test_core_components_are_checked() =>
      assertMarkedIn('core/ui/components/card.dart', '''
$importFlutter

const gap = SizedBox(width: «12»);
''');
}
