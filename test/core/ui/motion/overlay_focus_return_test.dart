import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/tab_bar_visibility.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';

/// A page whose Enter key works only while it holds focus, and which
/// autofocuses once, as Home's Continue does.
class _Page extends StatelessWidget {
  const _Page({required this.onEnter, this.name = 'Page'});
  final VoidCallback onEnter;
  final String name;

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.enter): onEnter},
        child: Focus(autofocus: true, child: Center(child: Text(name))),
      );
}

enum _Kind { home, sheet }

// ignore: avoid_positional_boolean_parameters
late void Function(bool) _set;

Widget _overlay(_Kind kind, bool open, Widget page) => switch (kind) {
      _Kind.home => HomeWebOverlay(
          page: page,
          open: open,
          label: 'Reviews',
          drawer: true,
          onDismiss: () => _set(false),
          child: open ? const Text('Body') : const SizedBox.shrink(),
        ),
      _Kind.sheet => PantasSheet(
          page: page,
          open: open,
          label: 'Reviews',
          onDismiss: () => _set(false),
          child: const Text('Body'),
        ),
    };

Future<void> _mount(
  WidgetTester tester,
  _Kind kind,
  VoidCallback onEnter, {
  bool still = false,
  List<NavigatorObserver> observers = const [],
}) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  if (still) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  var open = false;
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLightTheme(web: true),
      navigatorObservers: observers,
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, update) {
            _set = (value) => update(() => open = value);
            return _overlay(kind, open, _Page(onEnter: onEnter));
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final kind in _Kind.values) {
    for (final still in [false, true]) {
      final how = '${kind.name}${still ? ', reduced motion' : ''}';
      testWidgets('Enter works on the page after the overlay closes ($how)',
          (tester) async {
        var enters = 0;
        await _mount(tester, kind, () => enters++, still: still);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(enters, 1);

        _set(true);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(
          enters,
          1,
          reason: 'the page is covered while the overlay is up',
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Body'), findsNothing);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(enters, 2);

        // Closed by the scrim, the second way an overlay closes.
        _set(true);
        await tester.pumpAndSettle();
        _set(false);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(enters, 3);
      });
    }
  }

  testWidgets(
      'a page pushed as the overlay closes keeps focus, and the page '
      'gets it back on return', (tester) async {
    var home = 0;
    var pushed = 0;
    await _mount(tester, _Kind.home, () => home++);
    _set(true);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(HomeWebOverlay));
    _set(false);
    // The lesson route opens in the same frame the drawer starts to close.
    final route = MaterialPageRoute<void>(
      builder: (_) => _Page(onEnter: () => pushed++, name: 'Lesson'),
    );
    final result = Navigator.of(context).push(route);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(pushed, 1);
    expect(home, 0);

    Navigator.of(context).pop();
    await result;
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(home, 1);
    expect(pushed, 1);
  });

  testWidgets('a route overlay gives the page its focus back on its own',
      (tester) async {
    var enters = 0;
    await _mount(tester, _Kind.home, () => enters++);
    final context = tester.element(find.byType(HomeWebOverlay));
    final closed = showWebOverlay<void>(
      context: context,
      motion: WebOverlayMotion.popover,
      barrierLabel: 'Close day',
      builder: (_) => const Focus(autofocus: true, child: Text('Popover')),
    );
    await tester.pumpAndSettle();
    Navigator.of(context, rootNavigator: true).pop();
    await closed;
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(enters, 1);
  });

  group('phone tab bar', () {
    tearDown(() => phoneTabBarHidden.value = false);

    testWidgets('a sheet hides the bar while it is open and until it leaves',
        (tester) async {
      await _mount(tester, _Kind.sheet, () {});
      expect(phoneTabBarHidden.value, isFalse);
      _set(true);
      await tester.pump();
      await tester.pump();
      expect(phoneTabBarHidden.value, isTrue);
      _set(false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(phoneTabBarHidden.value, isTrue, reason: 'still sliding out');
      await tester.pumpAndSettle();
      expect(phoneTabBarHidden.value, isFalse);
    });

    testWidgets('a sheet leaves a bar that another owner hid', (tester) async {
      await _mount(tester, _Kind.sheet, () {});
      phoneTabBarHidden.value = true;
      _set(true);
      await tester.pumpAndSettle();
      _set(false);
      await tester.pumpAndSettle();
      expect(phoneTabBarHidden.value, isTrue);
    });
  });
}
