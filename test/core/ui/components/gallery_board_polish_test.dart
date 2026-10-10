import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/new_design/question_grid_sheet.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';

import '../../../helpers/accessibility.dart';

void main() {
  testWidgets('unavailable topics keep their expanded lessons inactive',
      (tester) async {
    var changes = 0;
    await pumpAccessibilitySurface(
      tester,
      ScopePicker(
        subjects: const [
          ScopeSubject(
            title: 'Math',
            topics: [
              ScopeTopic(
                id: 'empty',
                title: 'Geometry',
                hasQuestions: false,
                lessons: [ScopeLesson(id: 'empty-lesson', title: 'Angles')],
              ),
            ],
          ),
        ],
        selectedIds: const {
          'ready',
        },
        onChanged: (_) => changes++,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('scope-expand-empty')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('scope-select-empty-lesson')));
    await tester.pump();
    expect(changes, 0);
  });
  testWidgets('floating bar reaches its linear 150ms color midpoint',
      (tester) async {
    var state = FloatingBarState.neutral;
    final bar = StatefulBuilder(
      builder: (context, setState) => FloatingBar(
        state: state,
        left: const Text('Back'),
        counter: '4 of 10',
        right: TextButton(
          onPressed: () => setState(() => state = FloatingBarState.right),
          child: const Text('Check'),
        ),
      ),
    );
    await pumpAccessibilitySurface(tester, bar);
    await tester.tap(find.text('Check'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final paint = find
        .descendant(
          of: find.byType(AnimatedContainer),
          matching: find.byWidgetPredicate(
            (w) =>
                w is DecoratedBox &&
                w.position == DecorationPosition.background,
          ),
        )
        .first;
    final color =
        (tester.widget<DecoratedBox>(paint).decoration as BoxDecoration).color!;
    expect(color.toARGB32(), 0xFFF7FBFA);
  });
  testWidgets('current unanswered grid number uses the dark label',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      QuestionGridSheet(
        page: const Text('Page'),
        open: true,
        onDismiss: () {},
        parts: const [
          QuestionGridPart(
            title: 'Quiz',
            questions: [
              GridQuestion(
                number: 4,
                state: GridQuestionState.unreached,
                current: true,
              ),
            ],
          ),
        ],
        onSelected: (_) {},
      ),
      disableAnimations: true,
    );
    expect(
      tester.widget<Text>(find.text('4')).style!.color,
      const Color(0xFF1D1D1F),
    );
  });
  testWidgets('primary button follows CSS press at 70 and 140ms',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      PantasButton(label: 'Save', onPressed: () {}),
    );
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    final scale = find.descendant(
      of: find.byKey(const ValueKey('pantas-button-scale')),
      matching: find.byType(ScaleTransition),
    );
    expect(
      tester.widget<ScaleTransition>(scale).scale.value,
      closeTo(.975928, .0002),
    );
    await tester.pump(const Duration(milliseconds: 70));
    expect(
      tester.widget<ScaleTransition>(scale).scale.value,
      closeTo(.97, .00001),
    );
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 140));
    expect(tester.widget<ScaleTransition>(scale).scale.value, 1);
  });
  testWidgets('grid numbers fit at 200 percent without wrapping or clipping',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      QuestionGridSheet(
        page: const Text('Page'),
        open: true,
        onDismiss: () {},
        mock: true,
        parts: [
          QuestionGridPart(
            title: 'Part 1',
            questions: List.generate(
              18,
              (i) => GridQuestion(
                number: i + 1,
                state: GridQuestionState.answered,
              ),
            ),
          ),
        ],
        onSelected: (_) {},
      ),
      textScale: 2,
      disableAnimations: true,
      viewportSize: const Size(390, 844),
    );
    final text = find.text('12');
    expect(tester.widget<Text>(text).maxLines, 1);
    final cell = find.byKey(const ValueKey('grid-question-0-12'));
    final bounds = tester.getRect(cell);
    final painted = tester.getRect(text);
    expect(painted.width, lessThanOrEqualTo(bounds.width));
    expect(painted.height, lessThanOrEqualTo(bounds.height));
    expect(
      find.ancestor(of: text, matching: find.byType(FittedBox)),
      findsOneWidget,
    );
  });
}
