import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

import '../../../helpers/in_memory_database.dart';
import 'beta_feedback_fakes.dart';

/// A plain shell for the pages. The real one is built by the route from the
/// Settings pane page; behavior tests do not need it.
Widget testFrame({
  required String title,
  required List<Widget> children,
  required String backLabel,
  required VoidCallback onBack,
  bool beta = false,
  String? subline,
  double headingGap = 24,
}) =>
    Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title),
                  if (subline != null) Text(subline),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );

/// Everything a page test builds from.
class FbHarness {
  FbHarness({
    FakeBetaFeedbackApi? api,
    FakeBetaImageSource? images,
    DateTime? now,
    this.wide = false,
    this.dark = false,
    this.reduceMotion = false,
  })  : api = api ?? FakeBetaFeedbackApi(),
        images = images ?? FakeBetaImageSource(),
        now = now ?? ph(11, 12, 20);

  final FakeBetaFeedbackApi api;
  final FakeBetaImageSource images;
  final DateTime now;
  final bool wide;
  final bool dark;
  final bool reduceMotion;
  late final AppDatabase db = inMemoryDatabase();

  /// Pumps [page] at the phone or wide size, signed in as a tester.
  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    List<Override> overrides = const [],
    bool settle = true,
    String initial = '/',
    Map<String, WidgetBuilder> routes = const {},
  }) async {
    debugWebPlatformOverride = wide ? true : null;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view
      ..physicalSize = wide ? const Size(1440, 1400) : const Size(390, 1500)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(db.close);
    final router = GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(path: '/', builder: (_, __) => page),
        for (final entry in routes.entries)
          GoRoute(
            path: entry.key,
            builder: (context, _) => entry.value(context),
          ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          ...betaOverrides(api: api, images: images, now: now),
          ...overrides,
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: dark ? buildDarkTheme(web: wide) : buildLightTheme(web: wide),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: reduceMotion),
            child: child!,
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }
}
