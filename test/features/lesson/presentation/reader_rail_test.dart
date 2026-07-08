import 'package:cse_cet_reviewer/core/ui/components/progress_rule.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/reader_rail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the rail fills to the fraction it is given', (tester) async {
    await tester.pumpApp(const ReaderRail(progress: 0.5));

    final rule = tester.widget<ProgressRule>(find.byType(ProgressRule));
    expect(rule.value, 0.5);
  });
}
