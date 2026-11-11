// Pins the screen-facing color names and the phone type bundle, so moving
// them out of the old shim changes no rendered value. Values were recorded
// from the head before the move.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

Map<String, Color> _colors(PantasColors c) => <String, Color>{
      'background': c.background,
      'surface': c.surface,
      'segmentOn': c.segmentOn,
      'cardEdge': c.cardEdge,
      'label': c.label,
      'secondaryLabel': c.secondaryLabel,
      'tertiaryLabel': c.tertiaryLabel,
      'disabledActionLabel': c.disabledActionLabel,
      'separator': c.separator,
      'onFillLabel': c.onFillLabel,
      'skeleton': c.skeleton,
      'chevron': c.chevron,
      'destructive': c.destructive,
      'wrongTint': c.wrongTint,
      'wrongText': c.wrongText,
      'controlOutline': c.controlOutline,
      'pickerBackground': c.pickerBackground,
      'toastBackground': c.toastBackground,
      'onToast': c.onToast,
      'onDestructive': c.onDestructive,
      'figureBackground': c.figureBackground,
      'readerFigureBackground': c.readerFigureBackground,
      'figureViewerBackground': c.figureViewerBackground,
      'onFigureViewer': c.onFigureViewer,
      'floatingRight': c.floatingRight,
      'floatingWrong': c.floatingWrong,
      'pendingMark': c.pendingMark,
      'readerWarn': c.readerWarn,
      'readerWarnTint': c.readerWarnTint,
      'readerWarnText': c.readerWarnText,
      'shadow': c.shadow,
      'transparent': c.transparent,
    };

const _light = <String, int>{
  'background': 0xFFF5F5F7,
  'surface': 0xFFFFFFFF,
  'segmentOn': 0xFFFFFFFF,
  'cardEdge': 0x00000000,
  'label': 0xFF1D1D1F,
  'secondaryLabel': 0xFF6E6E73,
  'tertiaryLabel': 0xFF6E6E73,
  'disabledActionLabel': 0xFFAEAEB2,
  'separator': 0xFFE3E3E8,
  'onFillLabel': 0xFF636366,
  'skeleton': 0xFFE3E3E8,
  'chevron': 0xFF8E8E93,
  'destructive': 0xFFD70015,
  'wrongTint': 0xFFFDECEE,
  'wrongText': 0xFFD70015,
  'controlOutline': 0xFF8A8A8E,
  'pickerBackground': 0xFFFBFBFC,
  'toastBackground': 0xFF1D1D1F,
  'onToast': 0xFFFFFFFF,
  'onDestructive': 0xFFFFFFFF,
  'figureBackground': 0xFFFFFFFF,
  'readerFigureBackground': 0xFFFAFAF7,
  'figureViewerBackground': 0xFF000000,
  'onFigureViewer': 0xFFFFFFFF,
  'floatingRight': 0xFFEFF7F5,
  'floatingWrong': 0xFFFFF3F4,
  'pendingMark': 0xFFD1D1D6,
  'readerWarn': 0xFFC1121F,
  'readerWarnTint': 0xFFFDECEE,
  'readerWarnText': 0xFF7A1420,
  'shadow': 0xFF000000,
  'transparent': 0x00000000,
};

const _dark = <String, int>{
  'background': 0xFF151515,
  'surface': 0xFF1F1F1F,
  'segmentOn': 0xFF4A4A4A,
  'cardEdge': 0xFF2A2A2A,
  'label': 0xFFF5F5F5,
  'secondaryLabel': 0xFFA3A3A3,
  'tertiaryLabel': 0xFFA3A3A3,
  'disabledActionLabel': 0xFF6B6B6B,
  'separator': 0xFF303030,
  'onFillLabel': 0xFFA3A3A3,
  'skeleton': 0xFF3D3D3D,
  'chevron': 0xFF949494,
  'destructive': 0xFFC44A46,
  'wrongTint': 0xFF33201F,
  'wrongText': 0xFFE0706B,
  'controlOutline': 0xFF8E8E93,
  'pickerBackground': 0xFF1F1F1F,
  'toastBackground': 0xFF3A3A3C,
  'onToast': 0xFFFFFFFF,
  'onDestructive': 0xFFFFFFFF,
  'figureBackground': 0xFFFFFFFF,
  'readerFigureBackground': 0xFFFAFAF7,
  'figureViewerBackground': 0xFF000000,
  'onFigureViewer': 0xFFFFFFFF,
  'floatingRight': 0xFF18332D,
  'floatingWrong': 0xFF2E1E1D,
  'pendingMark': 0xFF3D3D3D,
  'readerWarn': 0xFFE0706B,
  'readerWarnTint': 0xFF2E1E1D,
  'readerWarnText': 0xFFF4D6D4,
  'shadow': 0xFF000000,
  'transparent': 0x00000000,
};

// family, size, weight, height, letterSpacing, color
const _lightType = <String, List<Object?>>{
  'largeTitle': <Object?>['Geist', 34.0, 700, 1.12, -0.748, 0xFF1D1D1F],
  'pageTitle': <Object?>['Geist', 28.0, 700, 1.2, -0.616, 0xFF1D1D1F],
  'pageTitleCompact': <Object?>['Geist', 28.0, 700, 1.2, -0.616, 0xFF1D1D1F],
  'sectionHero': <Object?>['Geist', 22.0, 700, 1.35, -0.264, 0xFF1D1D1F],
  'body': <Object?>['Geist', 17.0, 400, 1.35, -0.204, 0xFF1D1D1F],
  'rowValue': <Object?>['Geist', 17.0, 400, 1.35, -0.204, 0xFF6E6E73],
  'emphasized': <Object?>['Geist', 17.0, 600, 1.35, -0.204, 0xFF1D1D1F],
  'subhead': <Object?>['Geist', 15.0, 400, 1.35, 0.0, 0xFF1D1D1F],
  'subheadStrong': <Object?>['Geist', 15.0, 600, 1.35, 0.0, 0xFF1D1D1F],
  'footnote': <Object?>['Geist', 13.0, 400, 1.35, 0.0, 0xFF6E6E73],
  'sectionHeader': <Object?>['Geist', 13.0, 600, 1.35, 0.26, 0xFF6E6E73],
  'caption': <Object?>['Geist', 12.0, 400, 1.35, 0.0, 0xFF6E6E73],
  'captionSmall': <Object?>['Geist', 10.0, 600, 1.35, 0.0, 0xFF6E6E73],
  'captionStrong': <Object?>['Geist', 10.0, 600, 1.35, 0.0, 0xFF6E6E73],
  'mathSerif': <Object?>[
    'packages/flutter_math_fork/KaTeX_Main',
    17.0,
    400,
    1.5,
    0.0,
    0xFF1D1D1F,
  ],
};

const _darkType = <String, List<Object?>>{
  'largeTitle': <Object?>['Geist', 34.0, 700, 1.12, -0.748, 0xFFF5F5F5],
  'pageTitle': <Object?>['Geist', 28.0, 700, 1.2, -0.616, 0xFFF5F5F5],
  'pageTitleCompact': <Object?>['Geist', 28.0, 700, 1.2, -0.616, 0xFFF5F5F5],
  'sectionHero': <Object?>['Geist', 22.0, 700, 1.35, -0.264, 0xFFF5F5F5],
  'body': <Object?>['Geist', 17.0, 400, 1.35, -0.204, 0xFFF5F5F5],
  'rowValue': <Object?>['Geist', 17.0, 400, 1.35, -0.204, 0xFFA3A3A3],
  'emphasized': <Object?>['Geist', 17.0, 600, 1.35, -0.204, 0xFFF5F5F5],
  'subhead': <Object?>['Geist', 15.0, 400, 1.35, 0.0, 0xFFF5F5F5],
  'subheadStrong': <Object?>['Geist', 15.0, 600, 1.35, 0.0, 0xFFF5F5F5],
  'footnote': <Object?>['Geist', 13.0, 400, 1.35, 0.0, 0xFFA3A3A3],
  'sectionHeader': <Object?>['Geist', 13.0, 600, 1.35, 0.26, 0xFFA3A3A3],
  'caption': <Object?>['Geist', 12.0, 400, 1.35, 0.0, 0xFFA3A3A3],
  'captionSmall': <Object?>['Geist', 10.0, 600, 1.35, 0.0, 0xFFA3A3A3],
  'captionStrong': <Object?>['Geist', 10.0, 600, 1.35, 0.0, 0xFFA3A3A3],
  'mathSerif': <Object?>[
    'packages/flutter_math_fork/KaTeX_Main',
    17.0,
    400,
    1.5,
    0.0,
    0xFFF5F5F5,
  ],
};

void main() {
  test('color names keep their light values', () {
    final got = _colors(PantasColors.light);
    expect(got.keys, _light.keys);
    _light.forEach((k, v) => expect(got[k]!.toARGB32(), v, reason: k));
  });

  test('color names keep their dark values', () {
    final got = _colors(PantasColors.dark);
    expect(got.keys, _dark.keys);
    _dark.forEach((k, v) => expect(got[k]!.toARGB32(), v, reason: k));
  });

  for (final dark in [false, true]) {
    testWidgets('phone type bundle keeps its styles (dark: $dark)',
        (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme() : buildLightTheme(),
          home: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      );
      final t = captured.type;
      final got = <String, TextStyle>{
        'largeTitle': t.largeTitle,
        'pageTitle': t.pageTitle,
        'pageTitleCompact': t.pageTitleCompact,
        'sectionHero': t.sectionHero,
        'body': t.body,
        'rowValue': t.rowValue,
        'emphasized': t.emphasized,
        'subhead': t.subhead,
        'subheadStrong': t.subheadStrong,
        'footnote': t.footnote,
        'sectionHeader': t.sectionHeader,
        'caption': t.caption,
        'captionSmall': t.captionSmall,
        'captionStrong': t.captionStrong,
        'mathSerif': t.mathSerif,
      };
      final want = dark ? _darkType : _lightType;
      expect(got.keys, want.keys);
      want.forEach((k, v) {
        final s = got[k]!;
        expect(
          <Object?>[
            s.fontFamily,
            s.fontSize,
            s.fontWeight?.value,
            s.height,
            s.letterSpacing,
            s.color!.toARGB32(),
          ],
          v,
          reason: k,
        );
      });
    });
  }
}
