import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App navigation shell', () {
    testWidgets('renders three tabs: Home, Learn, More', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App(flavor: Flavor.dev)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Learn'), findsWidgets);
      expect(find.text('More'), findsWidgets);
    });

    testWidgets('tapping Learn tab navigates to Learn screen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App(flavor: Flavor.dev)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Learn'), findsWidgets);
    });

    testWidgets('tapping More tab navigates to More screen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App(flavor: Flavor.dev)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('More').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('More'), findsWidgets);
    });
  });
}
