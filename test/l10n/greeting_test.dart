import 'package:cse_cet_reviewer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'AppLocalizations is reachable and resolves greeting for time of day',
      (tester) async {
    late AppLocalizations l10n;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context)!;
            return Text(l10n.greeting('umaga'));
          },
        ),
      ),
    );

    expect(l10n.greeting('umaga'), 'Magandang umaga,');
    expect(l10n.greeting('hapon'), 'Magandang hapon,');
    expect(l10n.greeting('gabi'), 'Magandang gabi,');
    expect(find.text('Magandang umaga,'), findsOneWidget);
  });
}
