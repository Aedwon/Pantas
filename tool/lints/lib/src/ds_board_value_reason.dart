import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:pantas_lints/src/ds_no_design_literal.dart';
import 'package:pantas_lints/src/source_scope.dart';

/// A top-level or static `const` double, Duration or Color in `lib/features/`
/// or `lib/app/` is a design value kept outside the tokens when its value
/// reaches a design parameter inside the same library (the flow of
/// `ds_no_design_literal`). It needs `// ds-board: <reason>` on its line or on
/// the line above, naming the board or design that gave the value.
///
/// Limit: reach stops at the library. A public const that is only used from
/// other libraries is not seen, so it is not reported here. Consts that never
/// reach a design parameter (a day count, a threshold) are not design values.
class DsBoardValueReason extends AnalysisRule {
  DsBoardValueReason()
    : super(
        name: 'ds_board_value_reason',
        description:
            'A const double, Duration or Color in lib/features or lib/app '
            'needs a ds-board reason.',
      );

  static const LintCode code = LintCode(
    'ds_board_value_reason',
    '{0} is a design value kept outside the tokens. Add '
        '"// ds-board: <reason>" on its line or the line above, or move it '
        'onto the tokens.',
    severity: DiagnosticSeverity.WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry
      ..addTopLevelVariableDeclaration(this, visitor)
      ..addFieldDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  MarkerLines? _markers;
  RuleContextUnit? _markersFor;
  Set<Element>? _reached;

  /// Every variable of this library whose value reaches a design parameter.
  Set<Element> _reachedVariables() {
    final cached = _reached;
    if (cached != null) return cached;
    final flow = DesignFlow(context);
    for (final unit in context.allUnits) {
      flow.unit = unit;
      unit.unit.accept(_FlowWalker(flow));
    }
    return _reached = flow.reached;
  }

  MarkerLines _markerLines(RuleContextUnit unit) {
    if (_markersFor != unit) {
      _markers = MarkerLines(unit.content, unit.unit.lineInfo);
      _markersFor = unit;
    }
    return _markers!;
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) =>
      _check(node.variables, node);

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (node.isStatic) _check(node.fields, node);
  }

  void _check(VariableDeclarationList list, AnnotatedNode declaration) {
    if (!list.isConst) return;
    final unit = context.currentUnit;
    if (unit == null || !SourceScope.isFeatureOrApp(context, unit)) return;
    final markers = _markerLines(unit);
    final startLine = markers.lineOf(
      declaration.firstTokenAfterCommentAndMetadata.offset,
    );
    for (final variable in list.variables) {
      final type = variable.declaredFragment?.element.type;
      if (type == null || !_isBoardType(type)) continue;
      final element = variable.declaredFragment?.element;
      if (element == null || !_reachedVariables().contains(element)) continue;
      final nameLine = markers.lineOf(variable.name.offset);
      if (markers.boardNear(startLine) || markers.boardNear(nameLine)) continue;
      rule.reportAtToken(variable.name, arguments: [variable.name.lexeme]);
    }
  }

  bool _isBoardType(DartType type) {
    if (type.isDartCoreDouble) return true;
    if (type is! InterfaceType) return false;
    final name = type.element.name;
    final library = type.element.library.uri;
    if (name == 'Duration') return library.scheme == 'dart';
    if (name == 'Color') {
      return library.toString() == 'dart:ui' ||
          library.toString().startsWith('package:flutter/');
    }
    return false;
  }
}

/// Feeds every node a design rule looks at into [flow].
class _FlowWalker extends RecursiveAstVisitor<void> {
  _FlowWalker(this.flow);

  final DesignFlow flow;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    flow.instanceCreation(node);
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitNamedArgument(NamedArgument node) {
    flow.namedArgument(node);
    super.visitNamedArgument(node);
  }
}
