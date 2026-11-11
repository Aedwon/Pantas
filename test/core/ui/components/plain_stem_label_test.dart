import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';

// A question stem carries `**strong**` and `*emphasis*` markers that the
// question screen draws. A one-line label cannot draw them, so a row that
// shows a stem must not print the markers.
void main() {
  test('plainText drops emphasis markers and keeps maths and plain stars', () {
    expect(
      ContentRenderer.plainText('What does **belligerent** mean?'),
      'What does belligerent mean?',
    );
    expect(
      ContentRenderer.plainText('The word *ginawa* comes from _gawa_.'),
      'The word ginawa comes from gawa.',
    );
    expect(
      ContentRenderer.plainText(r'Solve $2*x*3$ now'),
      r'Solve $2*x*3$ now',
    );
    expect(ContentRenderer.plainText('No markers here'), 'No markers here');
  });

  testWidgets('a wide row that shows a stem prints no markers', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: const Scaffold(
          body: SizedBox(
            width: 600,
            child: WebRow(
              mathTitle: true,
              title: 'What does **belligerent** mean in this sentence?',
            ),
          ),
        ),
      ),
    );
    expect(
      find.textContaining('What does belligerent mean', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('**', findRichText: true), findsNothing);
  });
}
