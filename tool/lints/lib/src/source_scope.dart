import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/source/line_info.dart';

/// Which files a design rule looks at.
///
/// Paths are normalized to forward slashes and matched on the `/lib/`
/// segment, so the same check works in the repo and in the test harness
/// (which puts the sample package at `/home/test`).
/// The fixture `tool/checks/design_lint.dart` uses to prove the plugin loaded.
const canaryPath = 'test/tool/fixtures/design_lint_canary.dart';

class SourceScope {
  const SourceScope._();

  static final RegExp _generated = RegExp(r'\.(g|freezed|config)\.dart$');

  /// The path of [unit] relative to its package root, with forward slashes.
  /// Falls back to the part after the last `/lib/` outside a package.
  static String _relative(RuleContext context, RuleContextUnit unit) {
    final path = unit.file.path.replaceAll(r'\', '/');
    final root = context.package?.root.path.replaceAll(r'\', '/');
    if (root != null && path.startsWith('$root/')) {
      return path.substring(root.length + 1);
    }
    final index = path.lastIndexOf('/lib/');
    return index < 0 ? path : path.substring(index + 1);
  }

  /// Hand-written code under `lib/` that must use the tokens.
  ///
  /// Exempt: the token definitions (`lib/core/ui/theme/`), the motion
  /// primitives (`lib/core/ui/motion/`), drawing code (`lib/core/ui/icons/`
  /// and `lib/core/ui/figures/`), generated files and `lib/l10n/`.
  static bool isDesignScoped(RuleContext context, RuleContextUnit unit) {
    final rel = _relative(context, unit);
    if (rel == canaryPath) return true;
    if (!rel.startsWith('lib/')) return false;
    if (_generated.hasMatch(rel)) return false;
    if (rel.startsWith('lib/l10n/')) return false;
    if (rel.startsWith('lib/core/ui/theme/')) return false;
    if (rel.startsWith('lib/core/ui/motion/')) return false;
    if (rel.startsWith('lib/core/ui/icons/')) return false;
    if (rel.startsWith('lib/core/ui/figures/')) return false;
    return true;
  }

  /// Any hand-written file under `lib/`.
  static bool isHandWrittenLib(RuleContext context, RuleContextUnit unit) {
    final rel = _relative(context, unit);
    return rel.startsWith('lib/') && !_generated.hasMatch(rel);
  }

  /// `lib/features/` and `lib/app/`, where board values need a reason.
  static bool isFeatureOrApp(RuleContext context, RuleContextUnit unit) {
    final rel = _relative(context, unit);
    return rel.startsWith('lib/features/') || rel.startsWith('lib/app/');
  }
}

final RegExp geometryMarker = RegExp(r'//\s*ds-geometry:\s*\S');
final RegExp boardMarker = RegExp(r'//\s*ds-board:\s*\S');

/// Line based marker lookups on one file's text.
class MarkerLines {
  MarkerLines(String content, this.lineInfo) : _lines = content.split('\n');

  final LineInfo lineInfo;
  final List<String> _lines;

  int lineOf(int offset) => lineInfo.getLocation(offset).lineNumber;

  bool _has(int line, RegExp marker) =>
      line >= 1 && line <= _lines.length && marker.hasMatch(_lines[line - 1]);

  /// A marker on [line], or alone on the comment line just above it. The
  /// comment line lets a long reason stay inside 80 columns.
  bool geometryOnLine(int line) => _onOrAbove(line, geometryMarker);

  bool boardOnLine(int line) => _onOrAbove(line, boardMarker);

  bool _onOrAbove(int line, RegExp marker) =>
      _has(line, marker) ||
      (line >= 2 &&
          _lines[line - 2].trimLeft().startsWith('//') &&
          _has(line - 1, marker));

  /// A board marker on [line], or alone on the comment line above it.
  bool boardNear(int line) => _onOrAbove(line, boardMarker);
}
