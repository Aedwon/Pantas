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
}
