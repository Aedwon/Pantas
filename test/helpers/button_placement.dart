import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/web/web_components.dart';

// The wide button placement check (design/system/patterns.md, "Button
// placement", P2 approved Nov 7). Written Nov 25 after the wide Quiz tab
// paused card kept Resume at the bottom left for weeks: every review compared
// the card with its board, and the board predated the rule.
//
// It reads the laid-out screen, not the code, so it sees what the student
// sees. Every `WebButton` and `PantasButton` on the screen is found; buttons
// whose centers share a line and sit at most 32 px apart are one group. For
// each group of two or more:
//
// - order: when one button of the group is stronger than the rest (filled
//   over tonal or white, over neutral, over text), it is the main one and
//   comes last, at the right (secondary first, main last);
// - natural width: no button is stretched by an Expanded or Flexible (the
//   equal halves of the phone pair);
// - place: in its card, dialog, notice or panel (the nearest painted box
//   around it), the group's right edge keeps the same inset as the box's
//   text on the left (right end), or the group is centered. A group with no
//   one main button (Settings ghost rows) may sit at the left.
//
// Two lone buttons stacked one under the other (at most 16 px apart, one
// stronger than the other) are a phone-style pair, a row on a wide screen.
//
// A lone button is otherwise checked for natural width only: on a wide
// screen a button never spans its box (`btn--block` works only below 1024).
// Filter chips are choices, not actions, and are left out.
//
// - gap: 8 px between neighbors, except a pair listed in [boardGaps], where a
//   board he approved after the rule draws another gap.
//
// Known limit: a group with no painted box around it (a page-level row) is
// checked for order, gap and width, not place, because the page column's
// edges are not marked in the render tree.

/// Pairs whose approved board draws a gap other than 8 px, keyed by their
/// labels in visual order. His decision wins over the pattern; each entry
/// names the board and his approval.
const Map<(String, String), double> boardGaps = {
  // Board A, wide Quiz tab paused card: "Discard and Resume at the right of
  // the foot, 16 apart". Released by him Nov 25: "yes A lgtm, go ahead with
  // it".
  ('Discard this session', 'Resume'): 16,
};

/// One placement problem, in words a reviewer can act on.
typedef PlacementProblem = String;

class _Button {
  _Button(this.element, this.rect, this.label, {required this.weight});
  final Element element;
  final Rect rect;
  final String label;
  final int weight;
}

/// How strongly a button asks to be pressed: filled primary 3, tonal or white
/// 2, neutral 1, text 0. The main button of a group is its one strongest.
int _weight(Widget w) {
  PantasButtonKind kind;
  if (w is WebButton) {
    kind = w.kind ??
        switch (w.variant) {
          WebButtonVariant.primary ||
          WebButtonVariant.danger =>
            PantasButtonKind.primary,
          WebButtonVariant.secondary ||
          WebButtonVariant.dangerOutline =>
            PantasButtonKind.secondary,
          WebButtonVariant.tertiary => PantasButtonKind.tertiary,
          WebButtonVariant.white => PantasButtonKind.white,
        };
  } else if (w is PantasButton) {
    kind = w.kind ??
        switch (w.variant) {
          PantasButtonVariant.primary ||
          PantasButtonVariant.destructive =>
            PantasButtonKind.primary,
          PantasButtonVariant.secondary => PantasButtonKind.secondary,
          PantasButtonVariant.neutral => PantasButtonKind.neutral,
          PantasButtonVariant.tertiary => PantasButtonKind.tertiary,
        };
  } else {
    return 0;
  }
  return switch (kind) {
    PantasButtonKind.primary => 3,
    PantasButtonKind.secondary || PantasButtonKind.white => 2,
    PantasButtonKind.neutral => 1,
    PantasButtonKind.tertiary => 0,
  };
}

String _label(Widget w) => switch (w) {
      final WebButton b => b.label,
      final PantasButton b => b.label,
      _ => '?',
    };

/// Every button inside [within] (the whole screen when null) that is on
/// screen and laid out.
List<_Button> _buttons(WidgetTester tester, Finder? within) {
  final finder = find.byWidgetPredicate(
    (w) => w is WebButton || w is PantasButton && !w.isFilterChip,
  );
  final scoped =
      within == null ? finder : find.descendant(of: within, matching: finder);
  final found = <_Button>[];
  for (final element in scoped.evaluate()) {
    // A WebButton draws no PantasButton, but guard against a wrapper that
    // does: keep only the outermost button.
    var nested = false;
    element.visitAncestorElements((a) {
      if (a.widget is WebButton || a.widget is PantasButton) nested = true;
      return !nested;
    });
    if (nested) continue;
    final box = element.renderObject;
    if (box is! RenderBox || !box.hasSize || !box.attached) continue;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    if (rect.isEmpty) continue;
    found.add(
      _Button(
        element,
        rect,
        _label(element.widget),
        weight: _weight(element.widget),
      ),
    );
  }
  return found;
}

/// The nearest painted box around [element]: a decorated surface (card,
/// dialog, notice, sheet) clearly wider than [minWidth].
RenderBox? _container(Element element, double minWidth) {
  RenderBox? found;
  element.visitAncestorElements((a) {
    final r = a.renderObject;
    if (r is RenderDecoratedBox && r.hasSize) {
      final d = r.decoration;
      final painted = d is BoxDecoration &&
          (d.color != null || d.border != null || d.boxShadow != null);
      if (painted && r.size.width > minWidth + 32) {
        found = r;
        return false;
      }
    }
    return true;
  });
  return found;
}

bool _stretched(Element button) {
  var stretched = false;
  button.visitAncestorElements((a) {
    final w = a.widget;
    if (w is Flexible && w.fit == FlexFit.tight) {
      stretched = true;
      return false;
    }
    // Stop at the row that holds the group.
    return w is! Flex && w is! Wrap;
  });
  return stretched;
}

/// The left edge of the box's own text, measured from its left side: the
/// inset the right end of a button group should match.
double? _textInset(RenderBox box, Set<RenderObject> skip) {
  final origin = box.localToGlobal(Offset.zero).dx;
  double? least;
  void visit(RenderObject r) {
    if (skip.contains(r)) return;
    if (r is RenderParagraph && r.hasSize && r.attached) {
      final left = r.localToGlobal(Offset.zero).dx - origin;
      if (left >= 0 && (least == null || left < least!)) least = left;
    }
    r.visitChildren(visit);
  }

  box.visitChildren(visit);
  return least;
}

/// The placement problems on the current wide screen. Empty when every
/// button group follows the rule.
List<PlacementProblem> widePlacementProblems(
  WidgetTester tester, {
  Finder? within,
}) {
  final buttons = _buttons(tester, within)
    ..sort((a, b) => a.rect.left.compareTo(b.rect.left));
  final groups = <List<_Button>>[];
  for (final b in buttons) {
    List<_Button>? home;
    for (final g in groups) {
      final last = g.last;
      if ((last.rect.center.dy - b.rect.center.dy).abs() <= 4 &&
          b.rect.left - last.rect.right <= 32 &&
          b.rect.left >= last.rect.right - 0.5) {
        home = g;
        break;
      }
    }
    if (home == null) {
      groups.add([b]);
    } else {
      home.add(b);
    }
  }

  final problems = <PlacementProblem>[];
  // A phone-style pair, one button under the other, is one row on a wide
  // screen (patterns.md, uncovered cases).
  final singles = [
    for (final g in groups)
      if (g.length == 1) g.single,
  ];
  for (final a in singles) {
    for (final b in singles) {
      final gap = b.rect.top - a.rect.bottom;
      final overlap = a.rect.left < b.rect.right && b.rect.left < a.rect.right;
      if (overlap && gap >= -0.5 && gap <= 16 && a.weight != b.weight) {
        problems.add('"${b.label}" is stacked under "${a.label}"; on a wide '
            'screen a pair is one row at the right end, secondary first');
      }
    }
  }
  for (final g in groups) {
    final names = g.map((b) => '"${b.label}"').join(' then ');
    final span = g.first.rect.expandToInclude(g.last.rect);
    final box = _container(g.first.element, span.width);

    if (g.length == 1) {
      final b = g.single;
      if (box != null) {
        final inset = _textInset(box, {b.element.renderObject!});
        if (inset != null &&
            b.rect.width >= box.size.width - 2 * inset - 1 &&
            b.rect.width > 200) {
          problems.add('$names spans its box (${b.rect.width.round()} px); '
              'a wide button is at natural width');
        }
      }
      continue;
    }

    final top = g.map((b) => b.weight).reduce((a, b) => a > b ? a : b);
    final mains = g.where((b) => b.weight == top).toList();
    final hasMain = mains.length == 1;
    if (hasMain && mains.single != g.last) {
      problems.add('$names: the main button "${mains.single.label}" '
          'is not last (secondary first, main last)');
    }
    for (var i = 1; i < g.length; i++) {
      final gap = g[i].rect.left - g[i - 1].rect.right;
      final want = boardGaps[(g[i - 1].label, g[i].label)] ?? 8;
      if ((gap - want).abs() > 0.5) {
        problems.add('$names: ${gap.toStringAsFixed(1)} px between '
            '"${g[i - 1].label}" and "${g[i].label}" (${want.round()} px)');
      }
    }
    for (final b in g) {
      if (_stretched(b.element)) {
        problems.add('$names: "${b.label}" is stretched to fill its row '
            '(natural width on wide screens)');
      }
    }
    if (box == null || !hasMain) continue;
    final origin = box.localToGlobal(Offset.zero).dx;
    final left = span.left - origin;
    final right = origin + box.size.width - span.right;
    final inset = _textInset(box, {
      for (final b in g) b.element.renderObject!,
    });
    // A box with no text of its own (a card's foot band) has only its
    // padding to go by: the group is at the end when it hugs the right side.
    final atEnd = inset == null
        ? right <= 32 && right < left
        : (right - inset).abs() <= 2;
    final centered = (right - left).abs() <= 2;
    if (!atEnd && !centered) {
      problems.add('$names sits ${left.round()} px from the left and '
          '${right.round()} px from the right of its box; it belongs at the '
          'right end${inset == null ? '' : ' (${inset.round()} px in)'}');
    }
  }
  return problems;
}

/// Fails when a wide button group breaks the placement rule.
void expectWidePlacement(WidgetTester tester, {Finder? within}) {
  final problems = widePlacementProblems(tester, within: within);
  expect(
    problems,
    isEmpty,
    reason: 'Wide button placement (design/system/patterns.md, '
        '"Button placement"):\n${problems.join('\n')}',
  );
}
