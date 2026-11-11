import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:pantas_lints/src/source_scope.dart';

const _ruleNames = {
  'ds_no_design_literal',
  'ds_board_value_reason',
  'ds_marker_reason',
};

/// `// ds-geometry: x`, `// ds-board: x` and `// ds-raw: x` must carry a
/// reason. An `// ignore:` or `// ignore_for_file:` that names one of these
/// rules must carry one too, after a separator:
/// `// ignore: ds_no_design_literal -- reason`.
class DsMarkerReason extends AnalysisRule {
  DsMarkerReason()
    : super(
        name: 'ds_marker_reason',
        description:
            'ds-geometry, ds-board and ds-raw markers, and ignores of the '
            'ds rules, need a reason.',
      );

  static const LintCode code = LintCode(
    'ds_marker_reason',
    '{0}',
    severity: DiagnosticSeverity.WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _Visitor(this, context));
  }
}

final RegExp _marker = RegExp(r'^//+\s*(ds-geometry|ds-board|ds-raw)\b(.*)$');
final RegExp _markerReason = RegExp(r'^\s*:\s*\S');
final RegExp _ignore = RegExp(
  r'^//\s*ignore(?:_for_file)?:\s*'
  r'(?<names>[A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*)(?<rest>.*)$',
);
final RegExp _ignoreReason = RegExp(r'^\s*[^\w\s,]+\s*\S');

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final unit = context.currentUnit;
    if (unit == null) return;
    if (!SourceScope.isHandWrittenLib(context, unit)) return;
    Token? token = node.beginToken;
    while (token != null) {
      Token? comment = token.precedingComments;
      while (comment != null) {
        _check(comment);
        comment = comment.next;
      }
      if (token.type == TokenType.EOF) break;
      token = token.next;
    }
  }

  void _check(Token comment) {
    final text = comment.lexeme;
    final marker = _marker.firstMatch(text);
    if (marker != null && !_markerReason.hasMatch(marker.group(2)!)) {
      _report(
        comment,
        'The ${marker.group(1)} marker needs a reason: '
        '"// ${marker.group(1)}: <reason>".',
      );
      return;
    }
    final ignore = _ignore.firstMatch(text);
    if (ignore == null) return;
    final names = ignore.namedGroup('names')!.split(',').map((e) => e.trim());
    final named = names.where(_ruleNames.contains);
    if (named.isEmpty) return;
    if (!_ignoreReason.hasMatch(ignore.namedGroup('rest')!)) {
      _report(
        comment,
        'An ignore of ${named.first} needs a reason after the rule names: '
        '"// ignore: ${named.first} -- <reason>".',
      );
    }
  }

  void _report(Token comment, String message) =>
      rule.reportAtToken(comment, arguments: [message]);
}
