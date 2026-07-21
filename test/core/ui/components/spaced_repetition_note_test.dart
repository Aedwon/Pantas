import 'package:cse_cet_reviewer/core/ui/components/spaced_repetition_note.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('it names spaced repetition and nothing under it',
      (tester) async {
    // Moved here from How you work on 11 August. The wording is guarded
    // wherever it lives: the identity bans naming the scheduler to a student.
    await tester.pumpApp(const SpacedRepetitionNote());
    await tester.pumpAndSettle();

    expect(find.textContaining('spaced repetition'), findsOneWidget);

    for (final word in [
      'FSRS',
      'stability',
      'retention',
      'retrievability',
      'algorithm',
      'card',
    ]) {
      expect(find.textContaining(word), findsNothing);
    }
  });
}
