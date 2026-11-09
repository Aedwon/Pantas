import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Moves a mouse over [target] and settles.
Future<TestGesture> hoverOver(WidgetTester tester, Finder target) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(mouse.removePointer);
  await mouse.addPointer(location: Offset.zero);
  await mouse.moveTo(tester.getCenter(target));
  await tester.pumpAndSettle();
  return mouse;
}

/// The corner radius of [shape], or null when it is not a rounded rectangle
/// (a stadium or a circle).
double? cornerOf(OutlinedBorder? shape) {
  if (shape is! RoundedRectangleBorder) return null;
  final radius = shape.borderRadius;
  if (radius is! BorderRadius) return null;
  return radius.topLeft.x;
}

/// Asserts the [button] draws a rounded rectangle on hover, not a
/// stadium: the corner is less than half the shorter side.
void expectRoundedButtonHover(
  WidgetTester tester,
  Finder button,
  ButtonStyle style,
) {
  final shape = style.shape!.resolve({WidgetState.hovered});
  final corner = cornerOf(shape);
  expect(corner, isNotNull, reason: 'a rounded rectangle, not a pill');
  final size = tester.getSize(button);
  expect(corner, lessThan(size.shortestSide / 2));
}

/// Asserts a tap area washed on hover with a rounded rectangle: the wash is a
/// foreground [DecoratedBox] under [area] with a non-transparent color and a
/// border radius that is not a stadium.
void expectRoundedWash(WidgetTester tester, Finder area) {
  final wash = find.descendant(
    of: area,
    matching: find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          w.position == DecorationPosition.foreground &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).color != null &&
          (w.decoration as BoxDecoration).color != Colors.transparent,
    ),
  );
  expect(wash, findsOneWidget);
  final decoration =
      tester.widget<DecoratedBox>(wash).decoration as BoxDecoration;
  expect(decoration.shape, BoxShape.rectangle);
  final radius = decoration.borderRadius! as BorderRadius;
  expect(radius.topLeft.x, lessThan(tester.getSize(wash).shortestSide / 2));
}

/// Asserts a tap area washed on hover with a circle: a full radius on a
/// square, for the number chips the QuestionNavigator draws as circles.
void expectCircleWash(WidgetTester tester, Finder area) {
  final wash = find.descendant(
    of: area,
    matching: find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          w.position == DecorationPosition.foreground &&
          (w.decoration as BoxDecoration).color != Colors.transparent,
    ),
  );
  expect(wash, findsOneWidget);
  final size = tester.getSize(wash);
  expect(size.width, size.height);
  final decoration =
      tester.widget<DecoratedBox>(wash).decoration as BoxDecoration;
  final radius = decoration.borderRadius! as BorderRadius;
  expect(radius.topLeft.x, greaterThanOrEqualTo(size.shortestSide / 2));
}
