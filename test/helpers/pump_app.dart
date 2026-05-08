import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
