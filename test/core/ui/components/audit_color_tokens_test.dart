import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  test('board additions are named light/dark tokens', () {
    expect(PantasColors.light.controlOutline, const Color(0xFF8A8A8E));
    expect(PantasColors.dark.controlOutline, const Color(0xFF8E8E93));
    expect(PantasColors.light.pickerBackground, const Color(0xFFFBFBFC));
    expect(PantasColors.light.warningText, const Color(0xFFB25000));
    expect(PantasColors.light.choiceOutline, const Color(0xFFD1D1D6));
    expect(PantasColors.light.toastBackground, const Color(0xFF1D1D1F));
    expect(PantasColors.light.toastAction, const Color(0xFF7FD4C4));
    expect(PantasColors.light.floatingRight, const Color(0xFFEFF7F5));
    expect(PantasColors.light.floatingWrong, const Color(0xFFFFF3F4));
    expect(PantasColors.light.inactiveDateLabel, const Color(0xFFC7C7CC));
    expect(PantasColors.light.searchPlaceholder, const Color(0xFF8E8E93));
    expect(
      PantasColors.light.copyWith(controlOutline: Colors.red).controlOutline,
      Colors.red,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).controlOutline,
      PantasColors.dark.controlOutline,
    );
  });
  for (final brightness in Brightness.values) {
    testWidgets(
        'unchecked controls and credit use compliant real pairs $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        ListRow(title: 'Option', variant: ListRowVariant.radio, onTap: () {}),
        brightness: brightness,
      );
      final outline = tester
          .widget<Container>(
            find.descendant(
              of: find.byType(ListRow),
              matching: find.byWidgetPredicate(
                (w) =>
                    w is Container &&
                    w.decoration is BoxDecoration &&
                    (w.decoration! as BoxDecoration).shape == BoxShape.circle,
              ),
            ),
          )
          .decoration! as BoxDecoration;
      final surface = brightness == Brightness.light
          ? PantasColors.light.surface
          : PantasColors.dark.surface;
      expectContrast(
        (outline.border! as Border).top.color,
        surface,
        minimum: 3,
      );
      await pumpAccessibilitySurface(
        tester,
        ScopePicker(
          subjects: const [
            ScopeSubject(
              title: 'Math',
              topics: [ScopeTopic(id: 'a', title: 'Algebra')],
            ),
          ],
          selectedIds: const {},
          onChanged: (_) {},
        ),
        brightness: brightness,
      );
      final circle = tester
          .widget<Container>(
            find.byWidgetPredicate(
              (w) =>
                  w is Container &&
                  w.decoration is BoxDecoration &&
                  (w.decoration! as BoxDecoration).shape == BoxShape.circle,
            ),
          )
          .decoration! as BoxDecoration;
      expectContrast((circle.border! as Border).top.color, surface, minimum: 3);
      await pumpAccessibilitySurface(
        tester,
        ContentRenderer(
          blocks: const [
            {
              '_type': 'figureSpec',
              'spec': {'kind': 'test'},
              'credit': 'Credit',
            }
          ],
          figureBuilder: (context, spec) => const SizedBox(height: 60),
        ),
        brightness: brightness,
      );
      final credit = tester.widget<Text>(find.text('Credit'));
      expect(
        credit.style!.color,
        brightness == Brightness.light
            ? PantasColors.light.secondaryLabel
            : PantasColors.dark.secondaryLabel,
      );
      expectContrast(
        credit.style!.color!,
        brightness == Brightness.light
            ? PantasColors.light.surface
            : PantasColors.dark.background,
      );
    });
  }
  test('W2 components contain no local color literals', () {
    final paths = <String>[
      'accuracy_bar',
      'avatar',
      'button_pair',
      'centered_dialog',
      'check_mark',
      'choice_row',
      'content_renderer',
      'floating_bar',
      'grouped_section',
      'half_ring_gauge',
      'list_row',
      'loading_shapes',
      'math_text',
      'month_first_date_picker',
      'notice_strip',
      'pantas_button',
      'pantas_page',
      'pantas_sheet',
      'pantas_switch',
      'pro_paused_line',
      'pro_tag',
      'progress_ring',
      'scope_picker',
      'search_field',
      'segmented_switch',
      'sort_cycle_button',
      'state_view',
      'steps_screen',
      'toast',
      'value_wheel',
      'week_strip',
      'new_design/question_card',
      'new_design/answer_reveal',
      'new_design/passage_card',
      'new_design/question_grid_sheet',
    ];
    for (final path in paths) {
      expect(
        RegExp(r'\bColor\(0x|\bColors\.').hasMatch(
          File('lib/core/ui/components/$path.dart').readAsStringSync(),
        ),
        isFalse,
        reason: path,
      );
    }
  });
}
