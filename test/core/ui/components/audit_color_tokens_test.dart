import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/theme/legacy_theme_shim.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  test('board additions are named light/dark tokens', () {
    const light = PantasColors.light;
    const dark = PantasColors.dark;
    final pairs = <String, (Color, Color, int, int)>{
      'controlOutline': (
        light.controlOutline,
        dark.controlOutline,
        0xFF8A8A8E,
        0xFF8E8E93,
      ),
      'pickerBackground': (
        light.pickerBackground,
        dark.pickerBackground,
        0xFFFBFBFC,
        0xFF1F1F1F,
      ),
      'warningText': (
        light.warningText,
        dark.warningText,
        0xFFB25000,
        0xFFF0A35A,
      ),
      'choiceOutline': (
        light.choiceOutline,
        dark.choiceOutline,
        0xFF8A8A8E,
        0xFF8E8E93,
      ),
      'toastBackground': (
        light.toastBackground,
        dark.toastBackground,
        0xFF1D1D1F,
        0xFF3A3A3C,
      ),
      'toastAction': (
        light.toastAction,
        dark.toastAction,
        0xFF7FD8C6,
        0xFF7FD8C6,
      ),
      'onToast': (
        light.onToast,
        dark.onToast,
        0xFFFFFFFF,
        0xFFFFFFFF,
      ),
      'shadow': (
        light.shadow,
        dark.shadow,
        0xFF000000,
        0xFF000000,
      ),
      'transparent': (
        light.transparent,
        dark.transparent,
        0x00000000,
        0x00000000,
      ),
      'onAccent': (
        light.onAccent,
        dark.onAccent,
        0xFFFFFFFF,
        0xFFFFFFFF,
      ),
      'onDestructive': (
        light.onDestructive,
        dark.onDestructive,
        0xFFFFFFFF,
        0xFFFFFFFF,
      ),
      'figureBackground': (
        light.figureBackground,
        dark.figureBackground,
        0xFFFFFFFF,
        0xFFFFFFFF,
      ),
      'figureViewerBackground': (
        light.figureViewerBackground,
        dark.figureViewerBackground,
        0xFF000000,
        0xFF000000,
      ),
      'onFigureViewer': (
        light.onFigureViewer,
        dark.onFigureViewer,
        0xFFFFFFFF,
        0xFFFFFFFF,
      ),
      'floatingRight': (
        light.floatingRight,
        dark.floatingRight,
        0xFFEFF7F5,
        0xFF18332D,
      ),
      'floatingWrong': (
        light.floatingWrong,
        dark.floatingWrong,
        0xFFFFF3F4,
        0xFF2E1E1D,
      ),
      'inactiveDateLabel': (
        light.inactiveDateLabel,
        dark.inactiveDateLabel,
        0xFF6E6E73,
        0xFFA3A3A3,
      ),
      'searchPlaceholder': (
        light.searchPlaceholder,
        dark.searchPlaceholder,
        0xFF6E6E73,
        0xFFA3A3A3,
      ),
      'pendingMark': (
        light.pendingMark,
        dark.pendingMark,
        0xFFD1D1D6,
        0xFF3D3D3D,
      ),
      'switchThumb': (
        light.switchThumb,
        dark.switchThumb,
        0xFFFFFFFF,
        0xFFFFFFFF,
      ),
      'switchThumbShadow': (
        light.switchThumbShadow,
        dark.switchThumbShadow,
        0x33000000,
        0x80000000,
      ),
      'segmentedShadow': (
        light.segmentedShadow,
        dark.segmentedShadow,
        0x1A000000,
        0x80000000,
      ),
    };
    for (final entry in pairs.entries) {
      expect(
        entry.value.$1,
        Color(entry.value.$3),
        reason: '${entry.key} light',
      );
      expect(
        entry.value.$2,
        Color(entry.value.$4),
        reason: '${entry.key} dark',
      );
    }
    expect(
      PantasColors.light.copyWith(borderControl: Colors.red).controlOutline,
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
            find.byKey(const ValueKey('selection-mark')),
          )
          .decoration! as BoxDecoration;
      final surface = brightness == Brightness.light
          ? PantasColors.light.surface
          : PantasColors.dark.surface;
      // Aedwon, Nov 2: light mode asserts the board ring color; dark keeps 3:1.
      final roles = brightness == Brightness.light
          ? PantasColors.light
          : PantasColors.dark;
      expect((outline.border! as Border).top.color, roles.borderControl);
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
          .widget<Container>(find.byKey(const ValueKey('selection-mark')))
          .decoration! as BoxDecoration;
      final roles2 = brightness == Brightness.light
          ? PantasColors.light
          : PantasColors.dark;
      expect((circle.border! as Border).top.color, roles2.borderControl);
      expectContrast(
        (circle.border! as Border).top.color,
        surface,
        minimum: 3,
      );
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
        RegExp(r'\bColor\(0x|\bColors\.(?!transparent\b)').hasMatch(
          File('lib/core/ui/components/$path.dart').readAsStringSync(),
        ),
        isFalse,
        reason: path,
      );
    }
  });
}
