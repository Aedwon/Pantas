import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/new_design/question_card.dart';
import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('question subject has the board eight pixel gap $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const QuestionCard(subject: 'Science', stem: 'What is inside?'),
        brightness: brightness,
      );
      expect(
        tester.getTopLeft(find.byType(ContentRenderer)).dy -
            tester.getBottomLeft(find.text('SCIENCE')).dy,
        8,
      );
    });
  }
}
