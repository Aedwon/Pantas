import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/exam_name_line.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the name is the same size on every tab', (tester) async {
    await tester.pumpApp(const ExamNameLine('UPCAT'));
    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.text('UPCAT'));
    expect(text.style?.fontSize, PantasType.create().sectionHero.fontSize);
  });
}
