import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('empty lessons stay dimmed and out of topic picks at $scale',
        (tester) async {
      Set<String>? changed;
      await pumpAccessibilitySurface(
        tester,
        ScopePicker(
          atLeastOne: false,
          selectedIds: const {},
          subjects: const [
            ScopeSubject(
              title: 'Subject',
              topics: [
                ScopeTopic(
                  id: 't',
                  title: 'A long topic title for truncation',
                  lessons: [
                    ScopeLesson(id: 'a', title: 'Available'),
                    ScopeLesson(
                      id: 'none',
                      title: 'Empty',
                      hasQuestions: false,
                    ),
                  ],
                ),
              ],
            ),
          ],
          onChanged: (ids) => changed = ids,
        ),
        textScale: scale,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
      final title = tester.widget<Text>(
        find.text('A long topic title for truncation'),
      );
      expect(title.maxLines, 1);
      await tester.tap(find.byKey(const ValueKey('scope-select-t')));
      await tester.pump();
      expect(changed, {'a'});
      await tester.tap(find.byKey(const ValueKey('scope-expand-t')));
      await tester.pumpAndSettle();
      expect(find.text('No questions yet'), findsOneWidget);
      changed = null;
      await tester.tap(find.byKey(const ValueKey('scope-select-none')));
      await tester.pump();
      expect(changed, isNull);
      expect(tester.takeException(), isNull);
    });
  }
}
