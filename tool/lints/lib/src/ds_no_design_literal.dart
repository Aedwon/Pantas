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
  'HSLColor': _Kind.color,
  'HSVColor': _Kind.color,
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
    if (parameterType is InterfaceType &&
        parameterType.element.name == 'Curve' &&
        _isFrameworkLibrary(parameterType.element.library)) {
      return _Kind.curve;
    }
    final owner = parameter.enclosingElement;
    final cls = switch (owner) {
      ConstructorElement() => owner.enclosingElement,
      MethodElement() => owner.enclosingElement,
      _ => null,
    };
    if (cls == null) return null;
    final framework = _isFrameworkLibrary(cls.library);
    if (_isAnimationDuration(parameter, name, framework: framework)) {
      return _Kind.duration;
    }
    if (!framework) return null;
    final className = cls.name;
    if (className == 'TextStyle' &&
        (name == 'fontSize' || name == 'letterSpacing' || name == 'height')) {
      return _Kind.text;
    }
    if ((className == 'SizedBox' || className == 'Container') &&
        (name == 'width' || name == 'height' || name == 'dimension')) {
      return _Kind.size;
    }
    if (className == 'Icon' && name == 'size') return _Kind.size;
    return null;
  }

  /// A Duration is an animation duration when the framework declares the
  /// parameter (any name ending in `uration`), or when a project or package
  /// widget names it exactly `duration` or `reverseDuration`. A parameter such
  /// as `sessionDuration` on a project class is data, not motion.
  bool _isAnimationDuration(
    FormalParameterElement parameter,
    String name, {
    required bool framework,
  }) {
    final type = parameter.type;
    if (type is! InterfaceType || type.element.name != 'Duration') {
      return false;
    }
    if (framework) return name.endsWith('uration');
    return name == 'duration' || name == 'reverseDuration';
  }

  /// `Curves.<name>` other than `linear` reaching a Curve parameter.
  bool _curvesName(
    SimpleIdentifier name,
    AstNode reportAt,
    _Kind kind,
    List<_Leaf> leaves,
  ) {
    if (kind != _Kind.curve) return false;
    final element = name.element;
    if (element is! GetterElement) return false;
    final owner = element.enclosingElement;
    if (owner is! ClassElement || owner.name != 'Curves') return false;
    if (!_isFrameworkLibrary(owner.library)) return false;
    if (name.name != 'linear') {
      leaves.add(_Leaf(reportAt, 'Curves.${name.name}', kind));
    }
    return true;
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
      case SwitchExpression():
        for (final arm in node.cases) {
          _trace(arm.expression, kind, geometry, leaves, seen, via: via);
        }
      case InstanceCreationExpression():
        _traceCreation(node, kind, leaves, seen, via);
      case SimpleIdentifier():
        _follow(via ?? node, node.element, kind, geometry, leaves, seen);
      case PrefixedIdentifier():
        if (_curvesName(node.identifier, via ?? node, kind, leaves)) break;
        _follow(
          via ?? node,
          node.identifier.element,
          kind,
          geometry,
          leaves,
          seen,
        );
      case PropertyAccess():
        if (_curvesName(node.propertyName, via ?? node, kind, leaves)) break;
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
    // A getter written out in this library (`double get _gap => 13`) is read
    // like a const. A field's own getter is the field.
    final Element? variable = switch (element) {
      GetterElement() when _declarations().containsKey(element) => element,
      GetterElement() => element.variable,
      VariableElement() => element,
      _ => null,
    };
    if (variable == null) return;
    if (variable is VariableElement &&
        !(variable.isFinal || variable.isConst)) {
      return;
    }
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
    return markers.boardNear(markers.lineOf(declaration.startOffset)) ||
        markers.boardNear(markers.lineOf(declaration.nameOffset));
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

/// What a library reads a name as: the expression it holds or returns.
///
/// Limit: only variables and getters with an expression body are followed.
/// Function returns, parameter defaults and forwarding helpers
/// (`double gap(bool b) => b ? 8 : 12`) are out of scope; a value that goes
/// through them is not seen.
class _Declaration {
  const _Declaration(
    this.initializer,
    this.unit,
    this.nameOffset,
    this.startOffset,
  );

  final Expression initializer;
  final RuleContextUnit unit;
  final int nameOffset;

  /// Where the declaration starts, after its doc comment and annotations.
  final int startOffset;
}

class _DeclarationCollector extends RecursiveAstVisitor<void> {
  _DeclarationCollector(this.map, this.unit);

  final Map<Element, _Declaration> map;
  final RuleContextUnit unit;

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final initializer = node.initializer;
    final element = node.declaredFragment?.element;
    if (initializer != null && element != null) {
      final owner = node.parent?.parent;
      map[element] = _Declaration(
        initializer,
        unit,
        node.name.offset,
        owner is AnnotatedNode
            ? owner.firstTokenAfterCommentAndMetadata.offset
            : node.offset,
      );
    }
    super.visitVariableDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final body = node.body;
    final element = node.declaredFragment?.element;
    if (node.isGetter && body is ExpressionFunctionBody && element != null) {
      map[element] = _Declaration(
        body.expression,
        unit,
        node.name.offset,
        node.firstTokenAfterCommentAndMetadata.offset,
      );
    }
    super.visitMethodDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final body = node.functionExpression.body;
    final element = node.declaredFragment?.element;
    if (node.isGetter && body is ExpressionFunctionBody && element != null) {
      map[element] = _Declaration(
        body.expression,
        unit,
        node.name.offset,
        node.firstTokenAfterCommentAndMetadata.offset,
      );
    }
    super.visitFunctionDeclaration(node);
  }
}
