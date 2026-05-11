import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots and renders the navigation shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: App(flavor: Flavor.dev)),
    );
    await tester.pumpAndSettle();

    // Shell renders with three tabs visible.
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Learn'), findsWidgets);
    expect(find.text('More'), findsWidgets);
  });
}
