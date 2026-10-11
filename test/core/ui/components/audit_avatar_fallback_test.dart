import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('ST_Avatars uses people for nonletters $brightness',
        (tester) async {
      for (final name in ['123', '@me', '']) {
        await pumpAccessibilitySurface(tester, Avatar(name: name),
            brightness: brightness);
        expect(find.byIcon(PantasIcons.profile), findsOneWidget);
        final box = tester.widget<Container>(find
            .descendant(
                of: find.byType(Avatar), matching: find.byType(Container))
            .first);
        expect(
            box.color,
            brightness == Brightness.light
                ? PantasColors.light.fill
                : PantasColors.dark.fill);
      }
      for (final entry
          in {'alice': 'A', 'Émile': 'É', '林': '林', '👩‍🔬': '👩‍🔬'}.entries) {
        await pumpAccessibilitySurface(tester, Avatar(name: entry.key),
            brightness: brightness);
        expect(find.text(entry.value), findsOneWidget);
        expect(find.byIcon(PantasIcons.profile), findsNothing);
      }
    });
  }
}
