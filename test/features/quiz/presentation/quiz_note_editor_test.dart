import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/presentation/quiz_note_editor.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('add note requires a reason and saves selected real value',
      (tester) async {
    MistakeTag? saved;
    await tester.pumpApp(
      QuizNoteEditor(
        onCancel: () {},
        onSave: (tag, note) async => saved = tag,
      ),
    );
    expect(find.text('Why did you miss it?'), findsOneWidget);
    expect(
      tester
          .widget<PantasButton>(find.widgetWithText(PantasButton, 'Add Note'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('I misread it'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Note'));
    await tester.pumpAndSettle();
    expect(saved, MistakeTag.misread);
  });
  testWidgets('own words require text and trim only the saved note',
      (tester) async {
    String? saved;
    MistakeTag? reason;
    await tester.pumpApp(
      QuizNoteEditor(
        onCancel: () {},
        onSave: (tag, note) async {
          reason = tag;
          saved = note;
        },
      ),
    );
    await tester.tap(find.text('Type my own'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PantasButton>(find.widgetWithText(PantasButton, 'Add Note'))
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), '  Check the units.  ');
    await tester.pump();
    await tester.ensureVisible(find.text('Add Note'));
    await tester.tap(find.text('Add Note'));
    await tester.pumpAndSettle();
    expect(reason, MistakeTag.other);
    expect(saved, 'Check the units.');
  });
  testWidgets('edit supports explicit removal and retry preserves the draft',
      (tester) async {
    final results = <(MistakeTag?, String?)>[];
    var fail = true;
    await tester.pumpApp(
      QuizNoteEditor(
        tag: MistakeTag.other,
        note: 'Old note',
        onCancel: () {},
        onSave: (tag, note) async {
          if (fail) throw StateError('private diagnostic');
          results.add((tag, note));
        },
      ),
    );
    expect(find.text('Update'), findsOneWidget);
    await tester.tap(find.text('I misread it'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.textContaining('private diagnostic'), findsNothing);
    fail = false;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(results, [(MistakeTag.misread, null)]);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(results.last, (null, null));
  });
  testWidgets('pending save cannot submit twice or cancel', (tester) async {
    var saves = 0;
    var cancels = 0;
    final pending = Completer<void>();
    await tester.pumpApp(
      QuizNoteEditor(
        onCancel: () => cancels++,
        onSave: (tag, note) {
          saves++;
          return pending.future;
        },
      ),
    );
    await tester.tap(find.text('I misread it'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Note'));
    await tester.pump();
    await tester.tap(find.text('Add Note'));
    await tester.tap(find.text('Cancel'));
    expect(saves, 1);
    expect(cancels, 0);
    pending.complete();
    await tester.pumpAndSettle();
  });
  testWidgets(
      'unchanged note cannot update and returning to it disables Update',
      (tester) async {
    await tester.pumpApp(
      QuizNoteEditor(
        tag: MistakeTag.other,
        note: 'Check the units',
        onCancel: () {},
        onSave: (_, __) async {},
      ),
    );
    final update = find.widgetWithText(PantasButton, 'Update');
    expect(tester.widget<PantasButton>(update).onPressed, isNull);
    await tester.tap(find.text('I misread it'));
    await tester.pumpAndSettle();
    expect(tester.widget<PantasButton>(update).onPressed, isNotNull);
    await tester.tap(find.text('Type my own'));
    await tester.pumpAndSettle();
    expect(tester.widget<PantasButton>(update).onPressed, isNull);
  });

  testWidgets('selected reason dot follows the approved pop timing',
      (tester) async {
    await tester
        .pumpApp(QuizNoteEditor(onCancel: () {}, onSave: (_, __) async {}));
    final colors = tester.element(find.byType(QuizNoteEditor)).colors;
    await tester.tap(find.text('I misread it'));
    await tester.pump();
    double scale() {
      final dot = find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle &&
            (w.decoration as BoxDecoration).color == colors.accent,
      );
      final box = tester.renderObject<RenderBox>(dot);
      final parent =
          tester.renderObject<RenderBox>(find.byType(QuizNoteEditor));
      return MatrixUtils.transformRect(
            box.getTransformTo(parent),
            Offset.zero & box.size,
          ).width /
          box.size.width;
    }

    expect(scale(), closeTo(.5, .001));
    await tester.pump(const Duration(milliseconds: 220));
    expect(scale(), closeTo(1.15, .001));
    await tester.pump(const Duration(milliseconds: 160));
    expect(scale(), closeTo(1, .001));
  });

  testWidgets('ready action fades from disabled paint after the drawn delay',
      (tester) async {
    await tester
        .pumpApp(QuizNoteEditor(onCancel: () {}, onSave: (_, __) async {}));
    final colors = tester.element(find.byType(QuizNoteEditor)).colors;
    await tester.tap(find.text('I misread it'));
    await tester.pump();
    Color? background() => tester
        .widget<TextButton>(
          find.descendant(
            of: find.widgetWithText(PantasButton, 'Add Note'),
            matching: find.byType(TextButton),
          ),
        )
        .style!
        .backgroundColor!
        .resolve(<WidgetState>{});
    expectPaint(background()!, colors.fill);
    await tester.pump(const Duration(milliseconds: 100));
    expectPaint(background()!, colors.fill);
    await tester.pump(const Duration(milliseconds: 100));
    expectPaint(background()!, Color.lerp(colors.fill, colors.accentFill, .5)!);
    await tester.pump(const Duration(milliseconds: 100));
    expectPaint(background()!, colors.accentFill);
  });

  testWidgets('existing reason keeps the drawn frame and full Remove target',
      (tester) async {
    await tester.pumpApp(
      QuizNoteEditor(
        tag: MistakeTag.misread,
        onCancel: () {},
        onSave: (_, __) async {},
      ),
    );
    expect(tester.getSize(find.byType(FloatingBar)).height, closeTo(318, .01));
    expect(
      tester.getSize(find.widgetWithText(TextButton, 'Remove')).height,
      greaterThanOrEqualTo(44),
    );
  });
}

void expectPaint(Color actual, Color expected) {
  expect(actual.a, closeTo(expected.a, 1e-9));
  expect(actual.r, closeTo(expected.r, 1e-9));
  expect(actual.g, closeTo(expected.g, 1e-9));
  expect(actual.b, closeTo(expected.b, 1e-9));
}
