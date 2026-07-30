import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookplate.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpPlate(
    WidgetTester tester, {
    String? studentName = 'Aedwon',
    String topicName = 'Arithmetic & Number Sense',
    String examAndSubject = 'UPCAT, Mathematics',
    String footing = '9 lessons, all read',
    String dateLine = '27 July 2026',
  }) async {
    await tester.pumpApp(
      Bookplate(
        studentName: studentName,
        topicName: topicName,
        examAndSubject: examAndSubject,
        footing: footing,
        dateLine: dateLine,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the plate carries every line in order', (tester) async {
    await pumpPlate(tester);

    expect(find.text('Aedwon'), findsOneWidget);
    expect(find.text('Arithmetic & Number Sense'), findsOneWidget);
    expect(find.text('UPCAT, Mathematics'), findsOneWidget);
    expect(find.text('9 lessons, all read'), findsOneWidget);
    expect(find.text('27 July 2026'), findsOneWidget);
  });

  testWidgets('a skipped name leaves no gap where it was', (tester) async {
    await pumpPlate(tester, studentName: null);
    final without =
        tester.getSize(find.byKey(const ValueKey('bookplate-card'))).height;
    expect(find.text('Aedwon'), findsNothing);

    await pumpPlate(tester);
    final with_ =
        tester.getSize(find.byKey(const ValueKey('bookplate-card'))).height;

    expect(without, lessThan(with_));
  });

  testWidgets('the plate prints no figure but the footing', (tester) async {
    await pumpPlate(tester);

    // No bare numeral anywhere: the counts live inside the footing sentence.
    expect(find.text('9'), findsNothing);
    expect(find.textContaining('min'), findsNothing);
  });

  testWidgets('a topic stopped short changes only the footing', (tester) async {
    await pumpPlate(tester, footing: '6 of 9 lessons read');

    expect(find.text('6 of 9 lessons read'), findsOneWidget);
    expect(find.textContaining('The end of'), findsNothing);
  });
}
