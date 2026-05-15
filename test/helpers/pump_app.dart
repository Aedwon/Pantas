import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          extensions: [AppColors.light, AppTextStyles.create()],
        ),
        home: Scaffold(body: widget),
      ),
    );
    await pump();
  }
}

extension PumpAppRiverpod on WidgetTester {
  Future<void> pumpAppWithProviders(
    Widget child, {
    List<Override> overrides = const [],
  }) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            extensions: [AppColors.light, AppTextStyles.create()],
          ),
          home: child,
        ),
      ),
    );
    await pump();
  }

  Future<void> pumpAppWithRouter(
    GoRouter router, {
    List<Override> overrides = const [],
  }) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp.router(
          theme: ThemeData(
            useMaterial3: true,
            extensions: [AppColors.light, AppTextStyles.create()],
          ),
          routerConfig: router,
        ),
      ),
    );
    await pump();
  }
}
