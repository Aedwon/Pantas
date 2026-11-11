import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/section_header.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/ds_matrix.dart';

void main() {
  dsMatrix(
    'SectionHeader is an uppercase 13/600 eyebrow with an optional link',
    (context) => const SectionHeader(
      'Your Quiz Topics And Settings',
      link: Text('See All'),
    ),
    check: (tester, cell) async {
      final c = tester.element(find.byType(SectionHeader)).colors;
      final title =
          tester.widget<Text>(find.text('YOUR QUIZ TOPICS AND SETTINGS'));
      expect(title.style!.fontSize, 13);
      expect(title.style!.fontWeight, FontWeight.w600);
      expect(title.style!.color, c.textSecondary);
      expect(find.text('See All'), findsOneWidget);
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(SectionHeader),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding, const EdgeInsets.fromLTRB(4, 0, 4, 8));
    },
  );

  dsMatrix(
    'SectionHeader in a card is a 20/700 title on the card inset',
    (context) => const SectionHeader('Your Quiz', inCard: true),
    check: (tester, cell) async {
      final c = tester.element(find.byType(SectionHeader)).colors;
      final title = tester.widget<Text>(find.text('Your Quiz'));
      expect(title.style!.fontSize, 20);
      expect(title.style!.fontWeight, FontWeight.w700);
      expect(title.style!.color, c.textPrimary);
      expect(
        tester.getTopLeft(find.text('Your Quiz')).dx,
        16,
        reason: 'no side padding of its own',
      );
    },
  );

  dsMatrix(
    'phone SectionHeader pads 0 16 7; label and note pad as the system says',
    (context) => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader('Account', phone: true),
        GroupLabel('Study'),
        GroupNote('Your plan renews on March 1.'),
      ],
    ),
    check: (tester, cell) async {
      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('STUDY'), findsOneWidget);
      expect(tester.getTopLeft(find.text('ACCOUNT')).dx, 32);
      final note =
          tester.widget<Text>(find.text('Your plan renews on March 1.'));
      expect(note.style!.fontSize, 13);
    },
  );

  testWidgets('the header is announced as a heading', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpDs(tester, dsCells.first, const SectionHeader('Account'));
    expect(
      tester.getSemantics(find.text('ACCOUNT')).flagsCollection.isHeader,
      isTrue,
    );
    handle.dispose();
  });
}
