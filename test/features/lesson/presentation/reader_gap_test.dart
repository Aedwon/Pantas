import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_gap.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpGap(
    WidgetTester tester, {
    bool isRead = false,
    ExamId? examId = 'e1',
    LessonId lessonId = 'l1',
  }) async {
    await tester.pumpApp(
      ReaderGap(
        isRead: isRead,
        examId: examId,
        lessonId: lessonId,
      ),
    );
  }

  testWidgets('an unread lesson shows no read line', (tester) async {
    await pumpGap(tester);

    expect(find.text('Read'), findsNothing);
    expect(find.text('marked automatically'), findsNothing);
  });

  testWidgets('a read lesson uses only the drawn Read line', (tester) async {
    await pumpGap(tester, isRead: true);

    expect(find.text('Read'), findsOneWidget);
    expect(find.text('marked automatically'), findsNothing);
    final label = tester.widget<Text>(find.text('Read'));
    expect(label.style!.fontSize, 15);
    expect(label.style!.fontWeight, FontWeight.w500);
  });

  testWidgets('there is no mark as read button anywhere', (tester) async {
    await pumpGap(tester);

    expect(find.text('Mark as read'), findsNothing);
  });

  testWidgets('the coda names its length', (tester) async {
    await pumpGap(tester);

    expect(find.text('Quiz yourself, 5 questions'), findsOneWidget);
    expect(find.byType(PantasButton), findsOneWidget);
    final button = find.descendant(
      of: find.byType(PantasButton),
      matching: find.byType(TextButton),
    );
    expect(tester.getSize(button).height, 52);
    final style = tester.widget<TextButton>(button).style!;
    expect(style.backgroundColor!.resolve({}), PantasColors.light.fill);
    expect(style.foregroundColor!.resolve({}), PantasColors.light.label);
  });

  testWidgets('no exam means no coda rather than a broken route',
      (tester) async {
    await pumpGap(tester, examId: null);

    expect(find.text('Quiz yourself, 5 questions'), findsNothing);
  });

  testWidgets('the gap never prints the estimated minutes', (tester) async {
    await pumpGap(tester, isRead: true);

    expect(find.textContaining('min'), findsNothing);
  });
}
