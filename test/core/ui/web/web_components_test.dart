import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';

Future<void> mount(
  WidgetTester tester,
  Widget child, {
  bool dark = false,
  bool reduced = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

void main() {
  testWidgets('dark keyboard and bottom-bar hints use secondary text',
      (tester) async {
    await mount(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WebKeyHint('Ctrl K'),
          WebBottomBar(
            counter: '1 of 10',
            hint: 'Pick an answer',
            action: WebButton(label: 'Next', pill: true),
          ),
        ],
      ),
      dark: true,
    );
    for (final label in ['Ctrl K', 'Pick an answer']) {
      expect(
        tester.widget<Text>(find.text(label)).style!.color,
        const Color(0xFFA3A3A3),
      );
    }
  });
  testWidgets('busy action keeps its primary color and cannot run twice',
      (tester) async {
    var calls = 0;
    await mount(
      tester,
      WebButton(label: 'Saving', busy: true, onPressed: () => calls++),
      reduced: true,
    );
    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(
      button.style!.backgroundColor!.resolve({WidgetState.disabled}),
      const Color(0xFF0B7A68),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(TextButton));
    expect(calls, 0);
  });
  testWidgets('dark wrong option and wrong bar override hard-coded light reds',
      (tester) async {
    await mount(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WebAnswerOption(
            letter: 'A',
            state: WebOptionState.wrong,
            child: Text('Wrong answer'),
          ),
          WebBottomBar(
            counter: '1 of 10',
            state: WebBarState.wrong,
            action: WebButton(label: 'Next', pill: true),
          ),
        ],
      ),
      dark: true,
    );
    final option = tester.widget<TextButton>(
      find.descendant(
        of: find.byType(WebAnswerOption),
        matching: find.byType(TextButton),
      ),
    );
    expect(option.style!.side!.resolve({})!.color, const Color(0xFFC44A46));
    expect(option.style!.backgroundColor!.resolve({}), const Color(0xFF33201F));
    final bar = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(WebBottomBar),
            matching: find.byType(Container),
          )
          .first,
    );
    expect((bar.decoration! as BoxDecoration).color, const Color(0xFF2E1E1D));
  });
  testWidgets('button hover and keyboard focus use the canvas states',
      (tester) async {
    await mount(tester, WebButton(label: 'Continue', onPressed: () {}));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(TextButton)));
    await tester.pumpAndSettle();
    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(
      button.style!.backgroundColor!.resolve({WidgetState.hovered}),
      const Color(0xFF086A5A),
    );
    expect(button.style!.side!.resolve({WidgetState.focused})!.width, 2);
    await mouse.removePointer();
  });
  testWidgets('top bar uses 64px with leading title and trailing actions',
      (tester) async {
    await mount(
      tester,
      const WebTopBar(
        leading: Text('Study'),
        title: Text('1 of 5'),
        trailing: WebKeyHint('Esc'),
      ),
    );
    expect(tester.getSize(find.byType(WebTopBar)).height, 64);
    expect(find.text('Study'), findsOneWidget);
    expect(find.text('1 of 5'), findsOneWidget);
    expect(find.text('Esc'), findsOneWidget);
  });
  testWidgets('dark cards, segments and danger controls use final overrides',
      (tester) async {
    await mount(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const WebCard(child: Text('Card content')),
          SizedBox(
            width: 300,
            child: WebSegmentedControl(
              labels: const ['Subjects', 'Topics'],
              selected: 0,
              onChanged: (_) {},
            ),
          ),
          WebButton(
            label: 'Delete',
            variant: WebButtonVariant.danger,
            onPressed: () {},
          ),
          WebButton(
            label: 'Remove',
            variant: WebButtonVariant.dangerOutline,
            onPressed: () {},
          ),
        ],
      ),
      dark: true,
    );
    final card = tester.widget<Container>(
      find.descendant(
        of: find.byType(WebCard),
        matching: find.byType(Container),
      ),
    );
    final decoration = card.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFF1F1F1F));
    expect((decoration.border! as Border).top.color, const Color(0xFF2C2C2C));
    final buttons =
        tester.widgetList<TextButton>(find.byType(TextButton)).toList();
    expect(
      buttons[0].style!.backgroundColor!.resolve({}),
      const Color(0xFF4A4A4A),
    );
    expect(
      buttons[2].style!.backgroundColor!.resolve({}),
      const Color(0xFFB2423E),
    );
    expect(
      buttons[2].style!.backgroundColor!.resolve({WidgetState.hovered}),
      const Color(0xFFA33C38),
    );
    expect(
      buttons[3].style!.foregroundColor!.resolve({}),
      const Color(0xFFE0706B),
    );
    expect(buttons[3].style!.side!.resolve({})!.color, const Color(0xFFC44A46));
  });
  testWidgets('rows have hover, selected and dimmed states', (tester) async {
    await mount(
      tester,
      SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WebRow(title: 'Normal', onPressed: () {}),
            WebRow(title: 'Selected', selected: true, onPressed: () {}),
            WebRow(title: 'Dimmed', dimmed: true, onPressed: () {}),
          ],
        ),
      ),
    );
    final buttons =
        tester.widgetList<TextButton>(find.byType(TextButton)).toList();
    expect(
      buttons[0].style!.backgroundColor!.resolve({WidgetState.hovered}),
      const Color(0xFFF7F7F9),
    );
    expect(
      buttons[1].style!.backgroundColor!.resolve({}),
      const Color(0xFFE4F1EE),
    );
    expect(buttons[2].onPressed, isNull);
  });
  for (final state in WebBarState.values) {
    testWidgets('bottom bar $state uses the correct light surface',
        (tester) async {
      await mount(
        tester,
        WebBottomBar(
          counter: '1 of 10',
          state: state,
          action: const WebButton(label: 'Next', pill: true),
        ),
      );
      final bar = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(WebBottomBar),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (bar.decoration! as BoxDecoration).color,
        switch (state) {
          WebBarState.neutral => Colors.white,
          WebBarState.right => const Color(0xFFEEF8F5),
          WebBarState.wrong => const Color(0xFFFFF3F4),
        },
      );
    });
  }
  for (final variant in WebButtonVariant.values) {
    testWidgets('$variant is natural width, enabled and disabled',
        (tester) async {
      var calls = 0;
      await mount(
        tester,
        WebButton(
          label: 'Keep Going',
          variant: variant,
          onPressed: () => calls++,
        ),
      );
      final button = find.byType(TextButton);
      expect(tester.getSize(button).height, 44);
      expect(tester.getSize(button).width, lessThan(300));
      await tester.tap(button);
      expect(calls, 1);
      await mount(tester, WebButton(label: 'Keep Going', variant: variant));
      await tester.tap(button);
      expect(calls, 1);
    });
  }
  testWidgets('large button, key hint and pill have canvas heights',
      (tester) async {
    await mount(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WebButton(
            label: 'Continue',
            large: true,
            keyHint: 'Enter',
            onPressed: () {},
          ),
          WebButton(label: 'Next', pill: true, onPressed: () {}),
          const WebKeyHint('Esc'),
        ],
      ),
    );
    expect(tester.getSize(find.byType(TextButton).at(0)).height, 50);
    expect(tester.getSize(find.byType(TextButton).at(1)).height, 46);
    expect(find.text('Enter'), findsOneWidget);
    expect(find.text('Esc'), findsOneWidget);
  });
  testWidgets('text link moves its arrow 4px and respects reduced motion',
      (tester) async {
    await mount(
      tester,
      WebTextLink(label: 'See all questions', onPressed: () {}),
      reduced: true,
    );
    final arrow = find.text('→');
    final before = tester.getTopLeft(arrow);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(WebTextLink)));
    await tester.pump();
    expect(tester.getTopLeft(arrow).dx, before.dx + 4);
    expect(
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).duration,
      Duration.zero,
    );
    await mouse.removePointer();
  });
  testWidgets('card and row retain copy, selection and disabled behavior',
      (tester) async {
    var calls = 0;
    await mount(
      tester,
      SizedBox(
        width: 400,
        child: WebCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WebRow(
                title: 'Lessons',
                subtitle: 'Ready to read',
                value: 'Open',
                selected: true,
                onPressed: () => calls++,
              ),
              WebRow(
                title: 'Rest',
                dimmed: true,
                divider: false,
                onPressed: () => calls++,
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Ready to read'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    await tester.tap(find.text('Lessons'));
    await tester.tap(find.text('Rest'));
    expect(calls, 1);
  });
  testWidgets('segments expose selection and invoke the chosen index',
      (tester) async {
    var value = 0;
    await mount(
      tester,
      SizedBox(
        width: 300,
        child: WebSegmentedControl(
          labels: const ['Subjects', 'Topics'],
          selected: 0,
          onChanged: (i) => value = i,
        ),
      ),
    );
    expect(tester.getSize(find.byType(WebSegmentedControl)).height, 38);
    await tester.tap(find.text('Topics'));
    expect(value, 1);
  });
  for (final state in WebOptionState.values) {
    testWidgets('option $state has copy and appropriate interactivity',
        (tester) async {
      var calls = 0;
      await mount(
        tester,
        SizedBox(
          width: 500,
          child: WebAnswerOption(
            letter: 'A',
            state: state,
            onPressed: () => calls++,
            child: const Text('An answer'),
          ),
        ),
        dark: true,
      );
      expect(
        tester.getSize(find.byType(WebAnswerOption)).height,
        greaterThanOrEqualTo(64),
      );
      expect(find.text('An answer'), findsOneWidget);
      await tester.tap(find.text('An answer'));
      expect(
        calls,
        state == WebOptionState.normal || state == WebOptionState.selected
            ? 1
            : 0,
      );
    });
  }
  testWidgets('type scale and bottom bar support shared canvas structure',
      (tester) async {
    await mount(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const WebText('Heading', kind: WebTextKind.h1),
          const WebText('Section', kind: WebTextKind.eyebrow),
          WebBottomBar(
            counter: '1 of 10',
            action: WebButton(label: 'Check', pill: true, onPressed: () {}),
          ),
        ],
      ),
    );
    expect(tester.widget<Text>(find.text('Heading')).style!.fontSize, 38);
    expect(find.text('SECTION'), findsOneWidget);
    expect(tester.getSize(find.byType(WebBottomBar)).height, 64);
    expect(
      tester.getSize(find.byType(WebBottomBar)).width,
      lessThanOrEqualTo(720),
    );
  });
}
