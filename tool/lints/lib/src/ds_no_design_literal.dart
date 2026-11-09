import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:pantas_lints/src/source_scope.dart';

/// Design values come from the token classes, never from literals.
///
/// A literal is a non-zero number, a `Color(...)`, a `Colors.<name>` other
/// than `transparent`, a `Cubic(...)`, or a `Duration(...)`. The literal 0 is
/// not a design value.
///
/// Reported when the literal is an argument of a design-value constructor
/// (`Color`, `EdgeInsets`, `EdgeInsetsDirectional`, `BorderRadius`,
/// `BorderRadiusDirectional`, `Radius`, `BoxConstraints`, `Cubic`), or reaches
/// one of these parameters:
///
/// - `fontSize`, `letterSpacing` and `height` of `TextStyle`
/// - `width`, `height` and `dimension` of `SizedBox` and `Container`
/// - a `Duration` parameter whose name ends in `uration` (animation APIs)
///
/// The literal "reaches" a parameter through conditionals, arithmetic, `max`,
/// `min` and `clamp`, and through `final` or `const` variables declared in the
/// same library. In `a * 2` and `a / 2` the 2 scales a token and is allowed
/// when the other side is not itself a literal.
///
/// `// ds-geometry: <reason>` exempts a radius or a `Cubic` on the reported
/// line or on the line that starts the enclosing argument. It never exempts a
/// color, a font size, a size, a spacing or a duration.
class DsNoDesignLiteral extends AnalysisRule {
  DsNoDesignLiteral()
    : super(
        name: 'ds_no_design_literal',
        description:
            'Design values come from the Pantas token classes, never from '
            'literals.',
      );

  static const LintCode code = LintCode(
    'ds_no_design_literal',
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
    final visitor = _Visitor(DesignFlow(context, rule: this));
    registry
      ..addInstanceCreationExpression(this, visitor)
      ..addNamedArgument(this, visitor)
      ..addPrefixedIdentifier(this, visitor)
      ..addPropertyAccess(this, visitor);
  }
}

enum _Kind {
  color('color', 'a PantasColors role'),
  spacing('spacing', 'PantasSpace'),
  radius('radius', 'PantasRadius'),
  size('size', 'PantasSpace or PantasSize'),
  text('text size', 'a PantasType style'),
  duration('duration', 'PantasDurations'),
  curve('curve', 'PantasCurves');

  const _Kind(this.noun, this.use);
  final String noun;
  final String use;
}

class _Leaf {
  const _Leaf(this.reportAt, this.text, this.kind, {this.geometry = false});

  final AstNode reportAt;
  final String text;
  final _Kind kind;

  /// Whether a `ds-geometry` marker may exempt this leaf.
  final bool geometry;
}

const _designTypes = {
  'Color': _Kind.color,
  'EdgeInsets': _Kind.spacing,
  'EdgeInsetsDirectional': _Kind.spacing,
  'BorderRadius': _Kind.radius,
  'BorderRadiusDirectional': _Kind.radius,
  'Radius': _Kind.radius,
  'BoxConstraints': _Kind.size,
  'Cubic': _Kind.curve,
};

const _numericHelpers = {
  'max',
  'min',
  'clamp',
  'abs',
  'toDouble',
  'roundToDouble',
  'floorToDouble',
  'ceilToDouble',
  'truncateToDouble',
};

bool _isFrameworkLibrary(LibraryElement? library) {
  if (library == null) return false;
  final uri = library.uri.toString();
  return uri == 'dart:ui' || uri.startsWith('package:flutter/');
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.flow);

  final DesignFlow flow;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      flow.instanceCreation(node);

  @override
  void visitNamedArgument(NamedArgument node) => flow.namedArgument(node);

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) =>
      flow.colorsName(node.identifier, node);

  @override
  void visitPropertyAccess(PropertyAccess node) =>
      flow.colorsName(node.propertyName, node);
}

/// The flow analysis behind `ds_no_design_literal`.
///
/// With a [rule] it reports. Without one it only records, in [reached], every
/// variable whose value flows into a design parameter, which is how
/// `ds_board_value_reason` knows a const matters. Reach stops at the library:
/// a public const that is only used from other libraries is out of reach.
class DesignFlow {
  DesignFlow(this.context, {this.rule});

  final RuleContext context;
  final AnalysisRule? rule;

  /// Set when scanning a unit that is not [RuleContext.currentUnit].
  RuleContextUnit? unit;

  /// Variables read on a path that ends in a design parameter.
  final Set<Element> reached = {};

  Map<Element, _Declaration>? _initializers;
  final Map<RuleContextUnit, MarkerLines> _markers = {};

  RuleContextUnit get _unit => unit ?? context.currentUnit!;

  bool get _inScope => SourceScope.isDesignScoped(context, _unit);

  MarkerLines _markerLinesOf(RuleContextUnit u) =>
      _markers.putIfAbsent(u, () => MarkerLines(u.content, u.unit.lineInfo));

  MarkerLines get _markerLines => _markerLinesOf(_unit);

  // ---- entry points -------------------------------------------------------

  void instanceCreation(InstanceCreationExpression node) {
    if (!_inScope) return;
    final type = node.staticType;
    if (type is! InterfaceType) return;
    final element = type.element;
    if (!_isFrameworkLibrary(element.library)) return;
    final kind = _designTypes[element.name];
    if (kind == null) return;
    final geometry = kind == _Kind.radius || kind == _Kind.curve;
    final leaves = <_Leaf>[];
    for (final argument in node.argumentList.arguments) {
      _trace(argument.argumentExpression, kind, geometry, leaves, {});
    }
    _report(leaves, node);
  }

  void namedArgument(NamedArgument node) {
    if (!_inScope) return;
    final parameter = node.correspondingParameter;
    if (parameter == null) return;
    final kind = _kindOfParameter(parameter);
    if (kind == null) return;
    final leaves = <_Leaf>[];
    _trace(node.argumentExpression, kind, false, leaves, {});
    _report(leaves, node);
  }

  void colorsName(SimpleIdentifier name, AstNode node) {
    if (!_inScope) return;
    final element = name.element;
    if (element is! GetterElement) return;
    final owner = element.enclosingElement;
    if (owner is! ClassElement) return;
    if (owner.name != 'Colors' && owner.name != 'CupertinoColors') return;
    if (!_isFrameworkLibrary(owner.library)) return;
    if (name.name == 'transparent') return;
    _report([_Leaf(node, '${owner.name}.${name.name}', _Kind.color)], node);
  }

  // ---- which parameters count --------------------------------------------

  _Kind? _kindOfParameter(FormalParameterElement parameter) {
    final name = parameter.name;
    if (name == null) return null;
    final parameterType = parameter.type;
    if (parameterType is InterfaceType &&
        parameterType.element.name == 'Color' &&
        _isFrameworkLibrary(parameterType.element.library)) {
      return _Kind.color;
    }
    final owner = parameter.enclosingElement;
    final cls = switch (owner) {
      ConstructorElement() => owner.enclosingElement,
      MethodElement() => owner.enclosingElement,
      _ => null,
    };
    if (cls == null || !_isFrameworkLibrary(cls.library)) {
      // A Duration parameter on a project widget is also an animation API.
      if (_isDurationParameter(parameter, name) &&
          cls != null &&
          cls.library?.uri.scheme == 'package') {
        return _Kind.duration;
      }
      return null;
    }
    final className = cls.name;
    if (className == 'TextStyle' &&
        (name == 'fontSize' || name == 'letterSpacing' || name == 'height')) {
      return _Kind.text;
    }
    if ((className == 'SizedBox' || className == 'Container') &&
        (name == 'width' || name == 'height' || name == 'dimension')) {
      return _Kind.size;
    }
    if (_isDurationParameter(parameter, name)) return _Kind.duration;
    return null;
  }

  bool _isDurationParameter(FormalParameterElement parameter, String name) {
    final type = parameter.type;
    return type is InterfaceType &&
        type.element.name == 'Duration' &&
        name.endsWith('uration');
  }

  // ---- tracing ------------------------------------------------------------

  /// Collects the design literals that [node] can evaluate to.
  ///
  /// When [via] is set, [node] was reached through a variable, so every leaf is
  /// reported at the place that reads the variable.
  void _trace(
    Expression node,
    _Kind kind,
    bool geometry,
    List<_Leaf> leaves,
    Set<Element> seen, {
    AstNode? via,
  }) {
    switch (node) {
      case ParenthesizedExpression():
        _trace(node.expression, kind, geometry, leaves, seen, via: via);
      case IntegerLiteral():
        if ((node.value ?? 1) != 0) {
          leaves.add(
            _Leaf(via ?? node, node.literal.lexeme, kind, geometry: geometry),
          );
        }
      case DoubleLiteral():
        if (node.value != 0) {
          leaves.add(
            _Leaf(via ?? node, node.literal.lexeme, kind, geometry: geometry),
          );
        }
      case PrefixExpression()
          when node.operator.type == TokenType.MINUS ||
              node.operator.type == TokenType.PLUS:
        _trace(node.operand, kind, geometry, leaves, seen, via: via);
      case PostfixExpression() when node.operator.type == TokenType.BANG:
        _trace(node.operand, kind, geometry, leaves, seen, via: via);
      case AsExpression():
        _trace(node.expression, kind, geometry, leaves, seen, via: via);
      case ConditionalExpression():
        _trace(node.thenExpression, kind, geometry, leaves, seen, via: via);
        _trace(node.elseExpression, kind, geometry, leaves, seen, via: via);
      case BinaryExpression():
        _traceBinary(node, kind, geometry, leaves, seen, via);
      case MethodInvocation()
          when _numericHelpers.contains(node.methodName.name):
        final target = node.target;
        if (target != null && _isPlainValue(target)) {
          _trace(target, kind, geometry, leaves, seen, via: via);
        }
        // Only a plain value is a floor or a ceiling. `clamp(0, 1)` and
        // `max(0, n - 1)` are arithmetic on a count, not a design value.
        for (final argument in node.argumentList.arguments) {
          final expression = argument.argumentExpression;
          if (!_isPlainValue(expression)) continue;
          _trace(expression, kind, geometry, leaves, seen, via: via);
        }
      case InstanceCreationExpression():
        _traceCreation(node, kind, leaves, seen, via);
      case SimpleIdentifier():
        _follow(via ?? node, node.element, kind, geometry, leaves, seen);
      case PrefixedIdentifier():
        _follow(
          via ?? node,
          node.identifier.element,
          kind,
          geometry,
          leaves,
          seen,
        );
      case PropertyAccess():
        _follow(
          via ?? node,
          node.propertyName.element,
          kind,
          geometry,
          leaves,
          seen,
        );
      default:
        break;
    }
  }

  void _traceBinary(
    BinaryExpression node,
    _Kind kind,
    bool geometry,
    List<_Leaf> leaves,
    Set<Element> seen,
    AstNode? via,
  ) {
    switch (node.operator.type) {
      case TokenType.PLUS || TokenType.MINUS || TokenType.QUESTION_QUESTION:
        _trace(node.leftOperand, kind, geometry, leaves, seen, via: via);
        _trace(node.rightOperand, kind, geometry, leaves, seen, via: via);
      case TokenType.STAR:
        // A literal factor scales a token. Keep it when both sides are literals.
        final leftLiteral = _isLiteralOnly(node.leftOperand);
        final rightLiteral = _isLiteralOnly(node.rightOperand);
        if (!leftLiteral || leftLiteral == rightLiteral) {
          _trace(node.leftOperand, kind, geometry, leaves, seen, via: via);
        }
        if (!rightLiteral || leftLiteral == rightLiteral) {
          _trace(node.rightOperand, kind, geometry, leaves, seen, via: via);
        }
      case TokenType.SLASH || TokenType.TILDE_SLASH || TokenType.PERCENT:
        // Only the dividend carries the value; a divisor scales it.
        if (!_isLiteralOnly(node.leftOperand) ||
            _isLiteralOnly(node.rightOperand)) {
          _trace(node.leftOperand, kind, geometry, leaves, seen, via: via);
        }
      default:
        break;
    }
  }

  bool _isPlainValue(Expression node) => switch (node) {
    IntegerLiteral() => (node.value ?? 0) > 1,
    DoubleLiteral() => node.value > 1,
    SimpleIdentifier() || PrefixedIdentifier() || PropertyAccess() => true,
    ParenthesizedExpression() => _isPlainValue(node.expression),
    _ => false,
  };

  /// Whether [node] is a number written out, or a variable that holds one.
  /// Such a factor scales a value; it is not the value.
  bool _isLiteralOnly(Expression node, [int depth = 0]) {
    if (depth > 4) return false;
    return switch (node) {
      IntegerLiteral() || DoubleLiteral() => true,
      ParenthesizedExpression() => _isLiteralOnly(node.expression, depth + 1),
      PrefixExpression() => _isLiteralOnly(node.operand, depth + 1),
      BinaryExpression() =>
        _isLiteralOnly(node.leftOperand, depth + 1) &&
            _isLiteralOnly(node.rightOperand, depth + 1),
      SimpleIdentifier() => _variableIsLiteralOnly(node.element, depth),
      _ => false,
    };
  }

  bool _variableIsLiteralOnly(Element? element, int depth) {
    final variable = switch (element) {
      GetterElement() => element.variable,
      VariableElement() => element,
      _ => null,
    };
    if (variable == null || !(variable.isFinal || variable.isConst)) {
      return false;
    }
    final declaration = _declarations()[variable];
    return declaration != null &&
        _isLiteralOnly(declaration.initializer, depth + 1);
  }

  /// `Duration(milliseconds: 200)` and similar reaching a Duration parameter.
  void _traceCreation(
    InstanceCreationExpression node,
    _Kind kind,
    List<_Leaf> leaves,
    Set<Element> seen,
    AstNode? via,
  ) {
    final type = node.staticType;
    if (type is! InterfaceType) return;
    final element = type.element;
    if (element.name != 'Duration' ||
        element.library.uri.scheme != 'dart' ||
        kind != _Kind.duration) {
      return; // A design-value constructor reports its own arguments.
    }
    for (final argument in node.argumentList.arguments) {
      _trace(argument.argumentExpression, kind, false, leaves, seen, via: via);
    }
  }

  void _follow(
    AstNode reference,
    Element? element,
    _Kind kind,
    bool geometry,
    List<_Leaf> leaves,
    Set<Element> seen,
  ) {
    final variable = switch (element) {
      GetterElement() => element.variable,
      VariableElement() => element,
      _ => null,
    };
    if (variable == null || !(variable.isFinal || variable.isConst)) return;
    if (!seen.add(variable)) return;
    reached.add(variable);
    final declaration = _declarations()[variable];
    if (declaration == null) return;
    // A const the board sets, marked with a reason, is accepted at its source.
    if (_declaredWithBoardMarker(declaration)) return;
    _trace(
      declaration.initializer,
      kind,
      geometry,
      leaves,
      seen,
      via: reference,
    );
  }

  bool _declaredWithBoardMarker(_Declaration declaration) {
    final markers = _markerLinesOf(declaration.unit);
    final node = declaration.node;
    final start = markers.lineOf((node.parent?.parent ?? node).offset);
    return markers.boardNear(start) ||
        markers.boardNear(markers.lineOf(node.name.offset));
  }

  Map<Element, _Declaration> _declarations() {
    final cached = _initializers;
    if (cached != null) return cached;
    final map = <Element, _Declaration>{};
    for (final u in context.allUnits) {
      u.unit.accept(_DeclarationCollector(map, u));
    }
    return _initializers = map;
  }

  // ---- reporting ----------------------------------------------------------

  void _report(List<_Leaf> leaves, AstNode argument) {
    // Several values can reach one place (a variable set in both branches of a
    // conditional). Report that place once and list the values.
    final groups = <(AstNode, _Kind), List<String>>{};
    for (final leaf in leaves) {
      if (_exempt(leaf)) continue;
      final values = groups.putIfAbsent((leaf.reportAt, leaf.kind), () => []);
      if (!values.contains(leaf.text)) values.add(leaf.text);
    }
    final target = rule;
    if (target == null) return;
    for (final entry in groups.entries) {
      final (node, kind) = entry.key;
      target.reportAtNode(
        node,
        arguments: [
          'Hand-written ${kind.noun} ${entry.value.join(' or ')}. '
              'Use ${kind.use}.',
        ],
      );
    }
  }

  /// `ds-geometry` exempts a radius or a curve. `ds-board` exempts a size, a
  /// spacing, a duration or a text size. Neither ever exempts a color.
  bool _exempt(_Leaf leaf) {
    if (leaf.geometry)
      return _hasMarker(leaf.reportAt, (m, l) => m.geometryOnLine(l));
    if (leaf.kind != _Kind.color && leaf.kind != _Kind.curve) {
      return _hasMarker(leaf.reportAt, (m, l) => m.boardOnLine(l));
    }
    return false;
  }

  bool _hasMarker(AstNode node, bool Function(MarkerLines, int) test) {
    final markers = _markerLines;
    bool at(int offset) => test(markers, markers.lineOf(offset));
    if (at(node.offset) || at(node.end - 1)) return true;
    // `dart format` can move the comment to the line that starts an enclosing
    // argument, so look at each argument up the chain of design values.
    AstNode? current = node;
    while (current != null) {
      final parent = current.parent;
      if (parent is ArgumentList) {
        if (at(current.offset)) return true;
        final owner = parent.parent;
        if (owner is InstanceCreationExpression && _isDesignCreation(owner)) {
          current = owner;
          continue;
        }
        return false;
      }
      if (parent is Statement || parent is Declaration) return false;
      current = parent;
    }
    return false;
  }

  bool _isDesignCreation(InstanceCreationExpression node) {
    final type = node.staticType;
    return type is InterfaceType &&
        _isFrameworkLibrary(type.element.library) &&
        _designTypes.containsKey(type.element.name);
  }
}

class _Declaration {
  const _Declaration(this.node, this.unit);

  final VariableDeclaration node;
  final RuleContextUnit unit;

  Expression get initializer => node.initializer!;
}

class _DeclarationCollector extends RecursiveAstVisitor<void> {
  _DeclarationCollector(this.map, this.unit);

  final Map<Element, _Declaration> map;
  final RuleContextUnit unit;

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final element = node.declaredFragment?.element;
    if (node.initializer != null && element != null) {
      map[element] = _Declaration(node, unit);
    }
    super.visitVariableDeclaration(node);
  }
}
