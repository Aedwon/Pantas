import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots and renders the home stub', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: App(flavor: Flavor.dev)),
    );
    await tester.pumpAndSettle();

    // Home stub is the initial route.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Home — placeholder'), findsOneWidget);
  });
}
