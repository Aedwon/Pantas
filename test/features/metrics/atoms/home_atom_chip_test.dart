import 'package:cse_cet_reviewer/features/metrics/atoms/atom.dart';
import 'package:cse_cet_reviewer/features/metrics/atoms/home_atom_chip.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders atom text and highlighted metric', (tester) async {
    await tester.pumpApp(
      const HomeAtomChip(
        chip: AtomChip(text: 'Sharpest at 9pm', metric: '9 PM'),
      ),
    );

    expect(find.text('Sharpest at 9pm'), findsOneWidget);
    expect(find.text('9 PM'), findsOneWidget);
  });
}
