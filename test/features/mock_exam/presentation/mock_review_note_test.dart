import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_review_note.dart';
void main() {
  testWidgets('blank reasons save the chosen value without a miss reason', (tester) async {
    MockReviewNoteValue? saved;
    await tester.pumpWidget(MaterialApp(theme: buildLightTheme(), home: Scaffold(body: MockReviewNote(
      blank: true, onCancel: () {}, onSave: (value) async => saved = value))));
    await tester.tap(find.text('I skipped it to come back later'));
    await tester.tap(find.text('Add Note')); await tester.pumpAndSettle();
    expect(saved!.blankReason, BlankReason.skippedToReturn);
    expect(saved!.missReason, isNull);
  });
  testWidgets('own note restores and failed saving keeps the exact payload for Retry', (tester) async {
    final saved = <MockReviewNoteValue>[];
    await tester.pumpWidget(MaterialApp(theme: buildDarkTheme(), home: Scaffold(body: MockReviewNote(
      blank: false, initial: const MockAnswer(selectedIndex: 0, atSec: 4, missReason: MissReason.other, reasonNote: 'Forgot the sign'),
      onCancel: () {}, onSave: (value) async { saved.add(value); if (saved.length == 1) throw StateError('offline'); }))));
    expect(find.text('Forgot the sign'), findsOneWidget);
    await tester.tap(find.text('Add Note')); await tester.pumpAndSettle();
    await tester.tap(find.text('Try Again')); await tester.pumpAndSettle();
    expect(saved, hasLength(2)); expect(identical(saved[0], saved[1]), isTrue);
    expect(saved[1].missReason, MissReason.other);
    expect(saved[1].reasonNote, 'Forgot the sign');
  });
}
