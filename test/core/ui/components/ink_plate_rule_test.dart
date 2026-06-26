import 'package:cse_cet_reviewer/core/ui/components/ink_plate_rule.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('InkPlateRule is 1.6px tall and colored with ink',
      (tester) async {
    await tester.pumpApp(const InkPlateRule());

    final rule =
        tester.widget<Container>(find.byKey(const Key('inkPlateRule')));
    expect(rule.constraints?.maxHeight, InkPlateRule.height);
    expect(rule.color, AppColors.light.ink);
    expect(InkPlateRule.height, 1.6);
  });
}
