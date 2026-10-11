import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/platform/remote_flags.dart';
import 'package:pantas/core/platform/remote_flags_providers.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/shell/presentation/update_required_page.dart';

import '../../core/ui/components/w2_test_support.dart';
import '../../helpers/accessibility.dart';

void main() {
  /// The router as the app builds it, cut down to the routes this test
  /// needs: the gate is a redirect, so it must be exercised through one.
  GoRouter buildRouter({
    required int currentBuild,
    required int minimumSupportedBuild,
    String initialLocation = '/home',
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      redirect: (context, state) {
        final blocked = updateIsRequired(
          currentBuild: currentBuild,
          minimumSupportedBuild: minimumSupportedBuild,
        );
        if (blocked && state.matchedLocation != '/update-required') {
          return '/update-required';
        }
        if (!blocked && state.matchedLocation == '/update-required') {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/quiz/today/:examId',
          builder: (_, __) => const Scaffold(body: Text('quiz')),
        ),
        GoRoute(
          path: '/update-required',
          builder: (_, __) => const UpdateRequiredPage(),
        ),
      ],
    );
  }

  Widget harness(GoRouter router) {
    return ProviderScope(
      overrides: [
        remoteFlagsProvider.overrideWithValue(RemoteFlags.fallback),
      ],
      child: MaterialApp.router(
        theme: buildLightTheme(),
        routerConfig: router,
      ),
    );
  }

  testWidgets('a build above the minimum reaches Home normally',
      (tester) async {
    await tester.pumpWidget(
      harness(buildRouter(currentBuild: 12, minimumSupportedBuild: 10)),
    );
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('a build at the minimum is not blocked', (tester) async {
    await tester.pumpWidget(
      harness(buildRouter(currentBuild: 10, minimumSupportedBuild: 10)),
    );
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('a build below the minimum is stopped', (tester) async {
    await tester.pumpWidget(
      harness(buildRouter(currentBuild: 9, minimumSupportedBuild: 10)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Pantas needs an update to keep working.'),
      findsOneWidget,
    );
    expect(find.text('home'), findsNothing);
  });

  testWidgets('a deep link is stopped too', (tester) async {
    await tester.pumpWidget(
      harness(
        buildRouter(
          currentBuild: 9,
          minimumSupportedBuild: 10,
          initialLocation: '/quiz/today/exam_upcat',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('quiz'), findsNothing);
    expect(
      find.text('Pantas needs an update to keep working.'),
      findsOneWidget,
    );
  });

  testWidgets('the gate does not fire when no minimum is published',
      (tester) async {
    await tester.pumpWidget(
      harness(buildRouter(currentBuild: 1, minimumSupportedBuild: 0)),
    );
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('the page cannot be dismissed and says nothing extra',
      (tester) async {
    await tester.pumpWidget(
      harness(buildRouter(currentBuild: 9, minimumSupportedBuild: 10)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsNothing);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(PantasButton), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);

    // No version numbers, no changelog, no apology, no dismiss.
    expect(find.textContaining('version'), findsNothing);
    expect(find.textContaining('Sorry'), findsNothing);
    expect(find.textContaining('Later'), findsNothing);
    expect(find.byType(Icon), findsNothing);
    // A real previous route makes dropping PopScope observable.
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(body: Text('previous page')),
      ),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const UpdateRequiredPage(),
          ),
        )
        .ignore();
    await tester.pumpAndSettle();
    expect(navigator.canPop(), isTrue);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Update'), findsOneWidget);
    expect(find.text('previous page'), findsNothing);
  });
  for (final brightness in Brightness.values) {
    testWidgets('update board metrics, semantics and contrast $brightness',
        (tester) async {
      final semantics = tester.ensureSemantics();

      await pumpAccessibilitySurface(
        tester,
        const UpdateRequiredPage(),
        viewportSize: const Size(390, 844),
        brightness: brightness,
        disableAnimations: true,
      );
      final title = tester.widget<Text>(
        find.text('Pantas needs an update to keep working.'),
      );
      expect(title.textAlign, TextAlign.center);
      expect(title.style!.fontSize, 24);
      expect(title.style!.fontWeight, FontWeight.w700);
      expect(title.style!.height, 1.25);
      expect(title.style!.letterSpacing, -.288);
      expect(find.bySemanticsLabel('Pantas'), findsOneWidget);
      expect(
        tester.getSize(find.bySemanticsLabel('Pantas')),
        const Size(96, 96),
      );
      expect(
        tester
                .getTopLeft(
                  find.text('Pantas needs an update to keep working.'),
                )
                .dy -
            tester.getBottomLeft(find.bySemanticsLabel('Pantas')).dy,
        14,
      );
      expect(tester.getBottomLeft(find.byType(PantasButton)).dy, 814);
      final action = tester.widget<PantasButton>(find.byType(PantasButton));
      expect(action.height, 52);
      expect(action.radius, 14);
      expect(tester.getSize(find.byType(PantasButton)).width, 358);
      final context = tester.element(find.byType(UpdateRequiredPage));
      final scaffold = tester.widget<Scaffold>(
        find.descendant(
          of: find.byType(UpdateRequiredPage),
          matching: find.byType(Scaffold),
        ),
      );
      final background = scaffold.backgroundColor!;
      expect(background, context.colors.background);
      expectContrast(title.style!.color!, background);
      final paintedLogo = tester.widget<CustomPaint>(
        find.descendant(
          of: find.bySemanticsLabel('Pantas'),
          matching: find.byType(CustomPaint),
        ),
      );
      final pixels = (await tester.runAsync(() async {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder)..drawColor(background, BlendMode.src);
        paintedLogo.painter!.paint(canvas, const Size(96, 96));
        final picture = recorder.endRecording();
        final image = await picture.toImage(96, 96);
        final data = await image.toByteData();
        image.dispose();
        picture.dispose();
        return data!.buffer.asUint8List();
      }))!;
      Color pixelAt(int x, int y) {
        final i = (y * 96 + x) * 4;
        return Color.fromARGB(
          pixels[i + 3],
          pixels[i],
          pixels[i + 1],
          pixels[i + 2],
        );
      }

      final ink = pixelAt(48, 30);
      final tassel = pixelAt(87, 56);
      expect(
        ink,
        brightness == Brightness.light
            ? const Color(0xFF1D1D1F)
            : const Color(0xFFF5F5F7),
      );
      expect(
        tassel,
        brightness == Brightness.light
            ? const Color(0xFF0B7A68)
            : const Color(0xFF2FB39C),
      );
      expectContrast(ink, background, minimum: 3);
      expectContrast(tassel, background, minimum: 3);
      final buttonText = tester.widget<Text>(find.text('Update'));
      final button = tester.widget<TextButton>(find.byType(TextButton));
      expectContrast(
        buttonText.style!.color!,
        button.style!.backgroundColor!.resolve({})!,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.liveRegion ?? false),
        ),
        findsWidgets,
      );
      await expectSurvivesTextScale(
        tester,
        const UpdateRequiredPage(),
        viewportSize: const Size(390, 844),
        brightness: brightness,
        disableAnimations: true,
      );
      semantics.dispose();
    });
  }
  testWidgets('keyboard Update opens the real store listing externally',
      (tester) async {
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async {
        calls.add(call);
        return true;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    await pumpAccessibilitySurface(tester, const UpdateRequiredPage());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    final launch = calls.singleWhere((c) => c.method == 'launch');
    final args = launch.arguments as Map<Object?, Object?>;
    expect(
      args['url'],
      'https://play.google.com/store/apps/details?id=com.aedwon.pantas',
    );
    expect(args['useWebView'], false);
    expect(args['useSafariVC'], false);
  });
}
