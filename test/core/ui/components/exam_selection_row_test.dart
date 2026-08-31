import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/exam_selection_row.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the emblem shows the short name, not the code', (tester) async {
    await tester.pumpApp(
      ExamSelectionRow(
        exam: buildExam(code: 'CSE_PRO', shortName: 'CSE Pro'),
        selected: false,
        onTap: () {},
      ),
    );

    expect(find.text('CSE Pro'), findsOneWidget);
    expect(find.text('CSE_PRO'), findsNothing);
  });

  testWidgets('the longest short name does not wrap', (tester) async {
    await tester.pumpApp(
      ExamSelectionRow(
        exam: buildExam(code: 'DLSUCET', shortName: 'DLSU CET'),
        selected: false,
        onTap: () {},
      ),
    );

    final text = tester.renderObject<RenderParagraph>(
      find.text('DLSU CET').first,
    );
    expect(text.size.height, lessThan(30));
  });

  testWidgets('the row reports taps', (tester) async {
    var tapped = false;
    await tester.pumpApp(
      ExamSelectionRow(
        exam: buildExam(code: 'UPCAT', shortName: 'UPCAT'),
        selected: true,
        onTap: () => tapped = true,
      ),
    );

    await tester.tap(find.byType(ExamSelectionRow));
    expect(tapped, isTrue);
  });

  testWidgets('the row exposes its selected state and 48dp target',
      (tester) async {
    final exam = buildExam(code: 'UPCAT', shortName: 'UPCAT');
    await tester.pumpApp(
      ExamSelectionRow(exam: exam, selected: true, onTap: () {}),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('UPCAT, ${exam.name}')),
      matchesSemantics(
        label: 'UPCAT, ${exam.name}',
        hasSelectedState: true,
        isSelected: true,
        isButton: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSize(find.byType(ExamSelectionRow)).height,
      greaterThanOrEqualTo(48),
    );
  });
}
