import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

/// A small stand-in for the Flutter classes the rules look at. The rules match
/// on class name and on a `package:flutter/` library, so a stub is enough.
const flutterStub = r'''
class Widget {
  const Widget();
}

class Color {
  const Color(int value);
  const Color.fromARGB(int a, int r, int g, int b);
  const Color.fromRGBO(int r, int g, int b, double opacity);
  Color withValues({double? alpha}) => this;
}

class Colors {
  const Colors._();
  static const Color transparent = Color(0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Color(0xFFFF0000);
}

class Curve {
  const Curve();
}

class Cubic extends Curve {
  const Cubic(double a, double b, double c, double d);
}

class Curves {
  const Curves._();
  static const Curve linear = Cubic(0, 0, 1, 1);
  static const Curve easeIn = Cubic(0.42, 0, 1, 1);
  static const Curve easeOut = Cubic(0, 0, 0.58, 1);
}

class HSLColor {
  const HSLColor.fromAHSL(double a, double h, double s, double l);
  Color toColor() => const Color(0);
}

class HSVColor {
  const HSVColor.fromAHSV(double a, double h, double s, double v);
  Color toColor() => const Color(0);
}

class Icon extends Widget {
  const Icon(int data, {double? size});
}

class PageRouteLike {
  const PageRouteLike({Duration? transitionDuration, Curve? curve});
}

class Radius {
  const Radius.circular(double radius);
  static const Radius zero = Radius.circular(0);
}

class BorderRadius {
  const BorderRadius.all(Radius radius);
  const BorderRadius.circular(double radius);
  const BorderRadius.only({Radius topLeft = Radius.zero});
}

class EdgeInsetsGeometry {
  const EdgeInsetsGeometry();
}

class EdgeInsets extends EdgeInsetsGeometry {
  const EdgeInsets.all(double value);
  const EdgeInsets.symmetric({double vertical = 0, double horizontal = 0});
  const EdgeInsets.only({double left = 0, double top = 0});
}

class BoxConstraints {
  const BoxConstraints({double minHeight = 0, double maxWidth = 0});
}

class TextStyle {
  const TextStyle({double? fontSize, double? letterSpacing, double? height});
  TextStyle copyWith({double? fontSize}) => this;
}

class SizedBox extends Widget {
  const SizedBox({double? width, double? height, Widget? child});
  const SizedBox.square({double? dimension, Widget? child});
}

class Container extends Widget {
  const Container({
    double? width,
    double? height,
    Color? color,
    EdgeInsetsGeometry? margin,
    BoxConstraints? constraints,
    Widget? child,
  });
}

class Fade extends Widget {
  const Fade({
    required Duration duration,
    Duration? reverseDuration,
    Curve? curve,
  });
}

class Gap extends Widget {
  const Gap({double? size});
}
''';

/// Token stand-ins in an exempt folder, so using them reports nothing.
const tokensSource = r'''
import 'package:flutter/widgets.dart';

abstract final class Space {
  static const double md = 16;
  static const double lg = 24;
}

abstract final class Dur {
  static const Duration fast = Duration(milliseconds: 120);
}

abstract final class Palette {
  static const Color ink = Color(0xFF101010);
}
''';

const importFlutter = "import 'package:flutter/widgets.dart';";
const importTokens = "import 'package:test/core/ui/theme/tokens.dart';";

/// The expected reports in a source text, marked with guillemets:
/// `SizedBox(width: «10»)` reports the text between the marks.
class Annotated {
  Annotated(String marked) {
    final text = StringBuffer();
    var open = -1;
    for (final rune in marked.runes) {
      final char = String.fromCharCode(rune);
      if (char == '«') {
        open = text.length;
      } else if (char == '»') {
        spans.add((open, text.length - open));
      } else {
        text.write(char);
      }
    }
    source = text.toString();
  }

  late final String source;
  final List<(int, int)> spans = [];
}

mixin AnnotatedAsserts on AnalysisRuleTest {
  /// Reports the marked spans and nothing else in the default test file.
  Future<void> assertMarked(String marked) async {
    final annotated = Annotated(marked);
    await assertDiagnostics(annotated.source, [
      for (final (offset, length) in annotated.spans) lint(offset, length),
    ]);
  }

  /// Same, for a file at [libPath] (relative to `lib/`).
  Future<void> assertMarkedIn(String libPath, String marked) async {
    final annotated = Annotated(marked);
    final file = newFile('$testPackageLibPath/$libPath', annotated.source);
    await assertDiagnosticsInFile(file.path, [
      for (final (offset, length) in annotated.spans) lint(offset, length),
    ]);
  }

  void writeSupport() {
    newPackage('flutter').addFile('lib/widgets.dart', flutterStub);
    newFile('$testPackageLibPath/core/ui/theme/tokens.dart', tokensSource);
  }
}
