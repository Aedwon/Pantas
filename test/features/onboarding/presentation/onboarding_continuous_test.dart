import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';

import '../../../helpers/onboarding_steps_harness.dart';

// ignore_for_file: cascade_invocations

/// Aedwon, Nov 2, 2026: every onboarding step keeps the same size and feel.
void main() {
  setUpAll(loadGeist);

  Finder primaryButton() => find.byWidgetPredicate(
        (w) => w is OnboardingButton && w.variant.name == 'primary',
      );

  group('wide web', () {
    testWidgets('every framed step shares one column and a still steps list',
        (tester) async {
      final columns = <String, Rect>{};
      Offset? rail;
      for (final step in framedOnboardingSteps) {
        await pumpFramedStep(tester, step, wide: true);
        expect(tester.takeException(), isNull, reason: step);
        final railNow = tester.getTopLeft(find.text('Birth year'));
        rail ??= railNow;
        expect(railNow, rail, reason: '$step moved the steps list');
        // Back is the first thing in the column: its left edge is the
        // column's left edge. The inline action's right edge is the right.
        final left = tester.getTopLeft(find.text('Back')).dx;
        final action = primaryButton();
        expect(action, findsOneWidget, reason: '$step has no inline action');
        final right = tester.getTopRight(action).dx;
        columns[step] = Rect.fromLTRB(left, 0, right, 0);
      }
      final first = columns.values.first;
      columns.forEach((step, rect) {
        expect(rect.right, first.right, reason: '$step right edge');
        // Back's icon sits a few pixels inside the column edge, equally.
        expect(rect.left, first.left, reason: '$step left edge');
      });
      expect(first.right - first.left, lessThanOrEqualTo(580));
    });

    testWidgets('the picker is one column of rows, with no pinned bar',
        (tester) async {
      await pumpFramedStep(tester, 'picker', wide: true);
      final rows = tester
          .widgetList(
            find.byWidgetPredicate(
              (w) => w.key.toString().contains("'exam-exam_"),
            ),
          )
          .length;
      expect(rows, 18);
      final upcat =
          tester.getRect(find.byKey(const ValueKey('exam-exam_upcat')));
      final cse =
          tester.getRect(find.byKey(const ValueKey('exam-exam_cse_pro')));
      expect(upcat.left, cse.left);
      expect(upcat.width, cse.width);
      expect(upcat.width, greaterThan(500));
      // No pinned bar: the action sits in the scrolling column.
      expect(find.byType(OverlayPortal), findsNothing);
      expect(find.text('Enter'), findsOneWidget);
    });

    testWidgets('the longest exam names fit their rows', (tester) async {
      await pumpFramedStep(tester, 'picker', wide: true);
      // Long names with no organization line show the full name, wrapped.
      for (final id in ['exam_dlsucet', 'exam_afpsat', 'exam_napolcom']) {
        final key = find.byKey(ValueKey('exam-$id'));
        await tester.ensureVisible(key);
        await tester.pump();
        expect(tester.takeException(), isNull, reason: id);
        final rect = tester.getRect(key);
        for (final text in tester.widgetList<Text>(
          find.descendant(of: key, matching: find.byType(Text)),
        )) {
          expect(text.data, isNotEmpty);
        }
        for (final render in tester.renderObjectList<RenderBox>(
          find.descendant(of: key, matching: find.byType(Text)),
        )) {
          final box = render.localToGlobal(Offset.zero) & render.size;
          expect(rect.contains(box.topLeft), isTrue, reason: id);
          expect(box.right, lessThanOrEqualTo(rect.right), reason: id);
        }
      }
    });

    testWidgets('picking a row and pressing Enter continues', (tester) async {
      final picked = <String>[];
      await pumpFramedStep(tester, 'picker', wide: true, onPicked: picked.add);
      final continueBtn = find.widgetWithText(WebButton, 'Continue');
      expect(tester.widget<WebButton>(continueBtn).onPressed, isNull);
      // A not-yet-available exam cannot be picked.
      await tester.ensureVisible(find.byKey(const ValueKey('exam-exam_upcat')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('exam-exam_upcat')));
      await tester.pump();
      expect(tester.widget<WebButton>(continueBtn).onPressed, isNull);
      await tester.ensureVisible(
        find.byKey(const ValueKey('exam-exam_cse_pro')),
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('exam-exam_cse_pro')));
      await tester.pump();
      // The pick shows only as the row's selected state.
      final card = find.ancestor(
        of: find.byKey(const ValueKey('exam-exam_cse_pro')),
        matching: find.byType(WebCard),
      );
      expect(tester.widget<WebCard>(card).selected, isTrue);
      expect(tester.widget<WebButton>(continueBtn).onPressed, isNotNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked, ['exam_cse_pro']);
      expect(tester.takeException(), isNull);
    });
  });

  group('phone', () {
    testWidgets('the picker uses the shared frame like every other step',
        (tester) async {
      Rect? back;
      Rect? bar;
      for (final step in framedOnboardingSteps) {
        await pumpFramedStep(tester, step, wide: false);
        expect(tester.takeException(), isNull, reason: step);
        final backRect = tester.getRect(find.text('Back'));
        final segments = find.byKey(const ValueKey('onboarding-segment'));
        expect(segments, findsNWidgets(6), reason: '$step progress bar');
        final barRect = tester.getRect(segments.first);
        back ??= backRect;
        bar ??= barRect;
        expect(backRect, back, reason: '$step Back moved');
        expect(barRect, bar, reason: '$step progress bar moved');
        expect(find.byType(OnboardingFrame), findsOneWidget);
        // Same action placement: the primary button sits at the bottom with
        // the standard 20 px side margins.
        final button = find.byWidgetPredicate(
          (w) => w is PantasButton && w.variant == PantasButtonVariant.primary,
        );
        expect(button, findsOneWidget, reason: '$step action');
        final rect = tester.getRect(button);
        expect(rect.left, 20, reason: '$step action margin');
        expect(rect.right, 390 - 20, reason: '$step action margin');
        expect(
          find.byType(ExamPickerScreen),
          step == 'picker' ? findsOneWidget : findsNothing,
        );
      }
    });
  });
}
