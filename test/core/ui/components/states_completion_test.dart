import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/steps_screen.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  test('skeleton token copies and interpolates', () {
    expect(PantasColors.light.skeleton, const Color(0xFFE6E6EA));
    expect(PantasColors.dark.skeleton, const Color(0xFF2A2A2A));
    expect(
      PantasColors.light.copyWith(skeleton: Colors.red).skeleton,
      Colors.red,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).skeleton,
      PantasColors.dark.skeleton,
    );
  });
  for (final brightness in Brightness.values) {
    testWidgets('steps check follows the 240ms keyframe $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const StepsScreen(
          title: 'Restore',
          steps: [WorkStep(label: 'Done', state: WorkStepState.done)],
        ),
        brightness: brightness,
      );
      await tester.pump(const Duration(milliseconds: 240));
      final transform = find
          .ancestor(
            of: find.byKey(const ValueKey('step-done-0')),
            matching: find.byType(Transform),
          )
          .first;
      expect(
        tester.widget<Transform>(transform).transform.storage[0],
        closeTo(1.12, .001),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('step-done-0'))),
        const Size(22, 22),
      );
    });
    testWidgets('loading delay and CSS opacity at keyframes $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const LoadingShapes(),
        brightness: brightness,
      );
      expect(
        find.byKey(const ValueKey('loading-shapes-opacity')),
        findsNothing,
      );
      await tester.pump(const Duration(milliseconds: 299));
      expect(
        find.byKey(const ValueKey('loading-shapes-opacity')),
        findsNothing,
      );
      await tester.pump(const Duration(milliseconds: 1));
      expect(
        find.byKey(const ValueKey('loading-shapes-opacity')),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 650));
      expect(
        tester
            .widget<Opacity>(
              find.byKey(const ValueKey('loading-shapes-opacity')),
            )
            .opacity,
        closeTo(.45, .001),
      );
      await tester.pump(const Duration(milliseconds: 650));
      expect(
        tester
            .widget<Opacity>(
              find.byKey(const ValueKey('loading-shapes-opacity')),
            )
            .opacity,
        closeTo(1, .001),
      );
      await pumpAccessibilitySurface(
        tester,
        const LoadingShapes(proGate: true),
        brightness: brightness,
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 650));
      expect(
        tester
            .widget<Opacity>(
              find.byKey(const ValueKey('loading-shapes-opacity')),
            )
            .opacity,
        1,
      );
      await expectSurvivesTextScale(
        tester,
        const LoadingShapes(),
        brightness: brightness,
        disableAnimations: true,
      );
      await tester.pump(const Duration(milliseconds: 300));
    });
    testWidgets('steps all states and typography $brightness', (tester) async {
      const screen = StepsScreen(
        title: 'Restoring purchases',
        subtitle: 'This may take a moment.',
        steps: [
          WorkStep(label: 'Find purchases', state: WorkStepState.done),
          WorkStep(label: 'Restore Pro', state: WorkStepState.active),
          WorkStep(label: 'Finish', state: WorkStepState.pending),
        ],
      );
      await pumpAccessibilitySurface(
        tester,
        screen,
        brightness: brightness,
        disableAnimations: true,
      );
      final title = tester.widget<Text>(find.text('Restoring purchases'));
      expect(title.style!.fontSize, 26);
      expect(title.style!.fontWeight, FontWeight.w700);
      expect(title.style!.height, 1.35);
      expect(
        tester.widget<Text>(find.text('Find purchases')).style!.fontSize,
        17,
      );
      await expectSurvivesTextScale(
        tester,
        screen,
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
    });
    testWidgets('inline and full error never expose raw exceptions $brightness',
        (tester) async {
      var retries = 0;
      final error = Exception('private database path');
      for (final full in [false, true]) {
        final state = full
            ? StateView.fullScreen(error: error, onRetry: () => retries++)
            : StateView(
                message: 'Could not load your progress.',
                error: error,
                onRetry: () => retries++,
              );
        await pumpAccessibilitySurface(tester, state, brightness: brightness);
        expect(find.textContaining('private database'), findsNothing);
        if (full) {
          expect(find.text('Something went wrong.'), findsOneWidget);
          expect(find.text("Nothing you've done is lost."), findsOneWidget);
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(retries, greaterThan(0));
        await expectSurvivesTextScale(
          tester,
          state,
          brightness: brightness,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
      }
    });
    testWidgets('Pro tag metrics and actual contrast $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const ProTag(),
        brightness: brightness,
      );
      expect(tester.getSize(find.byType(ProTag)).height, 20);
      final text = tester.widget<Text>(find.text('Pro'));
      expect(text.style!.fontSize, 12);
      expect(text.style!.fontWeight, FontWeight.w700);
      final box = tester
          .widget<Container>(find.byKey(const ValueKey('pro-tag-surface')));
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(6));
      expectContrast(text.style!.color!, decoration.color!);
      await expectSurvivesTextScale(
        tester,
        const ProTag(),
        brightness: brightness,
        disableAnimations: true,
      );
    });
  }
}
