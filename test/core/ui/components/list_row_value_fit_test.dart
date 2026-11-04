import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/list_row.dart';

import '../../../helpers/accessibility.dart';

// Settings rows at 320 px: a value that fits beside its title stays on one
// line; a title and value that cannot both fit stack, so neither is cut.
Future<void> _pump(
  WidgetTester tester, {
  required String title,
  required String value,
  double width = 320,
  double textScale = 1,
}) =>
    pumpAccessibilitySurface(
      tester,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListRow(
          title: title,
          value: value,
          leading: const SizedBox(width: 28, height: 28),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          onTap: () {},
        ),
      ),
      viewportSize: Size(width, 640),
      textScale: textScale,
      disableAnimations: true,
    );

void main() {
  // Real glyph widths: the test font would make every word a wide square.
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });

  testWidgets('Practice and 10 questions share one line at 320',
      (tester) async {
    await _pump(tester, title: 'Practice', value: '10 questions');
    final title = tester.getRect(find.text('Practice'));
    final value = tester.getRect(find.text('10 questions'));
    expect(value.height, lessThan(24), reason: 'the value is one line');
    expect((title.center.dy - value.center.dy).abs(), lessThan(2));
    expect(value.left, greaterThan(title.right));
  });

  testWidgets('a title and value that cannot both fit stack, none cut',
      (tester) async {
    await _pump(
      tester,
      title: "What's included",
      value: 'Some topics left out',
    );
    final title = find.text("What's included");
    final paragraph = tester.renderObject<RenderParagraph>(title);
    expect(paragraph.didExceedMaxLines, isFalse);
    final titleRect = tester.getRect(title);
    final valueRect = tester.getRect(find.text('Some topics left out'));
    expect(valueRect.top, greaterThanOrEqualTo(titleRect.bottom));
    expect(valueRect.left, titleRect.left);
    expect(
      tester
          .renderObject<RenderParagraph>(find.text('Some topics left out'))
          .didExceedMaxLines,
      isFalse,
    );
  });

  testWidgets('All subjects stacks under the title at 320, none cut',
      (tester) async {
    await _pump(tester, title: "What's included", value: 'All subjects');
    final paragraph =
        tester.renderObject<RenderParagraph>(find.text("What's included"));
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(
      tester.getRect(find.text('All subjects')).top,
      greaterThanOrEqualTo(tester.getRect(find.text("What's included")).bottom),
    );
  });

  testWidgets('at 393 the title is not cut and the value stays at the end',
      (tester) async {
    await _pump(
      tester,
      title: "What's included",
      value: 'Some topics left out',
      width: 393,
    );
    final title = find.text("What's included");
    expect(
      tester.renderObject<RenderParagraph>(title).didExceedMaxLines,
      isFalse,
    );
    final titleRect = tester.getRect(title);
    final valueRect = tester.getRect(find.text('Some topics left out'));
    expect(valueRect.left, greaterThan(titleRect.right));
  });
}
