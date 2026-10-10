import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/new_design/question_grid_sheet.dart';
import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  test('wrong text token follows Aedwon decision', () {
    expect(PantasColors.light.wrongText, const Color(0xFFD70015));
    expect(PantasColors.dark.wrongText, const Color(0xFFFF6961));
    expectContrast(PantasColors.dark.wrongText, PantasColors.dark.wrongTint);
  });
  for (final brightness in Brightness.values) {
    testWidgets('confirmation variants and keyboard $brightness',
        (tester) async {
      var confirmed = 0;
      for (final destructive in [false, true]) {
        final dialog = CenteredDialog(
          title: 'Leave the quiz?',
          message: 'Your answers stay here.',
          primaryLabel: destructive ? 'Discard' : 'Keep going',
          secondaryLabel: 'Cancel',
          onConfirm: () => confirmed++,
          onCancel: () {},
          destructive: destructive,
        );
        await pumpAccessibilitySurface(tester, dialog, brightness: brightness);
        final title = tester.widget<Text>(find.text('Leave the quiz?'));
        expect(title.style!.fontSize, 20);
        expect(title.style!.fontWeight, FontWeight.w700);
        expect(
          tester
              .widget<Text>(find.text('Your answers stay here.'))
              .style!
              .height,
          1.45,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await expectSurvivesTextScale(
          tester,
          dialog,
          viewportSize: const Size(390, 844),
          brightness: brightness,
          disableAnimations: true,
        );
      }
      expect(confirmed, greaterThan(0));
    });
    testWidgets(
        'toast metrics, undo keyboard and intermediate rise $brightness',
        (tester) async {
      var undo = 0;
      final toast = Toast(message: 'Flagged.', onUndo: () => undo++);
      await pumpAccessibilitySurface(tester, toast, brightness: brightness);
      await tester.pump(const Duration(milliseconds: 125));
      final transform =
          tester.widget<Transform>(find.byKey(const ValueKey('toast-rise')));
      expect(
        transform.transform.storage[13],
        closeTo(0.6926965297805845, .002),
      );
      await tester.pump(const Duration(milliseconds: 125));
      final text = tester.widget<Text>(find.text('Flagged.'));
      expect(text.style!.fontSize, 15);
      expect(text.style!.fontWeight, FontWeight.w500);
      expectContrast(text.style!.color!, const Color(0xFF1D1D1F));
      expectContrast(
        tester.widget<Text>(find.text('Undo')).style!.color!,
        const Color(0xFF1D1D1F),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(undo, 1);
      await expectSurvivesTextScale(
        tester,
        toast,
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
    });
    testWidgets('notice dimensions, expansion and no solid actions $brightness',
        (tester) async {
      var expanded = false;
      var closed = 0;
      final notice = StatefulBuilder(
        builder: (context, setState) => NoticeStrip(
          title: 'Add your exam date',
          detail: 'Your plan paces each day to it.',
          expanded: expanded,
          onToggle: () => setState(() => expanded = !expanded),
          onClose: () => closed++,
          primaryLabel: 'Add date',
          onPrimary: () {},
          secondaryLabel: 'Not now',
          onSecondary: () {},
        ),
      );
      await pumpAccessibilitySurface(tester, notice, brightness: brightness);
      expect(
        tester.getSize(find.byKey(const ValueKey('notice-row'))).height,
        52,
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('notice-close'))),
        const Size(44, 44),
      );
      final closedHeight = tester.getSize(find.byType(NoticeStrip)).height;
      await tester.tap(find.text('Add your exam date'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 175));
      final middleHeight = tester.getSize(find.byType(NoticeStrip)).height;
      await tester.pump(const Duration(milliseconds: 175));
      final finalHeight = tester.getSize(find.byType(NoticeStrip)).height;
      expect((middleHeight - closedHeight) / (finalHeight - closedHeight),
          closeTo(.9423, .025),);
      expect(
          tester
              .widget<Text>(find.text('Your plan paces each day to it.'))
              .style!
              .fontSize,
          13,);
      expect(tester.widget<Text>(find.text('Add date')).style!.fontSize, 15);
      expect(
        find.text('Your plan paces each day to it.').hitTestable(),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('notice-close')));
      expect(closed, 1);
      await expectSurvivesTextScale(
        tester,
        notice,
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
    });
    testWidgets('floating bar states and slots $brightness', (tester) async {
      for (final state in FloatingBarState.values) {
        final bar = FloatingBar(
          state: state,
          left: TextButton(onPressed: () {}, child: const Text('Back')),
          counter: '4 of 10',
          right: TextButton(onPressed: () {}, child: const Text('Next')),
        );
        await pumpAccessibilitySurface(tester, bar, brightness: brightness);
        expect(tester.getSize(find.byType(FloatingBar)).height, 60);
        expect(tester.widget<Text>(find.text('4 of 10')).style!.fontSize, 15);
        await expectSurvivesTextScale(
          tester,
          bar,
          brightness: brightness,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
      }
    });
    testWidgets('grid modes columns, all states and keyboard $brightness',
        (tester) async {
      int? picked;
      for (final mock in [false, true]) {
        final entries = List.generate(
          12,
          (i) => GridQuestion(
            number: i + 1,
            state:
                GridQuestionState.values[i % GridQuestionState.values.length],
            current: i == 3,
            flagged: i == 1,
          ),
        );
        final grid = QuestionGridSheet(
          page: const Text('Page'),
          open: true,
          onDismiss: () {},
          mock: mock,
          parts: [
            QuestionGridPart(title: 'Part 1', questions: entries),
            QuestionGridPart(
              title: 'Part 2',
              questions: entries,
              enabled: false,
            ),
          ],
          onSelected: (n) => picked = n,
        );
        await pumpAccessibilitySurface(
          tester,
          grid,
          brightness: brightness,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
        final first = find.byKey(const ValueKey('grid-question-0-1'));
        final wrap = find.byKey(ValueKey('grid-question-0-${mock ? 7 : 6}'));
        expect(
          tester.getTopLeft(wrap).dy,
          greaterThan(tester.getTopLeft(first).dy),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(picked, isNotNull);
        await expectSurvivesTextScale(
          tester,
          grid,
          brightness: brightness,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
      }
    });
  }
}
