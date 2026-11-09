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

/// The smallest hit area a control may have (`size-target-touch`).
const Size minHitArea = Size.square(44);

/// Asserts [control] (its outermost widget, so any touch padding counts) is at
/// least [min] in both directions. A control whose README sets a smaller size
/// passes its own [min] and says why in [reason].
void expectHitArea(
  WidgetTester tester,
  Finder control, {
  Size min = minHitArea,
  String? reason,
}) {
  final size = tester.getSize(control.first);
  final why = reason ?? 'the hit area is at least ${min.width}x${min.height}';
  expect(size.width, greaterThanOrEqualTo(min.width), reason: why);
  expect(size.height, greaterThanOrEqualTo(min.height), reason: why);
}

/// Asserts a disabled Material button (a `ButtonStyleButton` or `IconButton`)
/// has no press handler, shows no hover or press wash, and ignores a tap.
Future<void> expectDisabledInert(WidgetTester tester, Finder button) async {
  final widget = tester.widget(button.first);
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  if (widget is ButtonStyleButton) {
    onPressed = widget.onPressed;
    style = widget.style;
  } else if (widget is IconButton) {
    onPressed = widget.onPressed;
    style = widget.style;
  } else {
    fail('${widget.runtimeType} is not a Material button');
  }
  expect(onPressed, isNull, reason: 'a disabled control has no handler');
  // Hovering must change nothing: every color a disabled button draws is the
  // same with or without the pointer on it.
  const resting = <WidgetState>{WidgetState.disabled};
  const hovered = <WidgetState>{WidgetState.disabled, WidgetState.hovered};
  final colors = <String, WidgetStateProperty<Color?>?>{
    'background': style?.backgroundColor,
    'foreground': style?.foregroundColor,
    'overlay': style?.overlayColor,
  };
  for (final MapEntry(:key, :value) in colors.entries) {
    expect(
      value?.resolve(hovered),
      value?.resolve(resting),
      reason: 'the disabled $key does not change on hover',
    );
  }
  final overlay = style?.overlayColor?.resolve(hovered);
  expect(
    overlay == null || overlay.a == 0,
    isTrue,
    reason: 'no overlay when disabled, got $overlay',
  );
  await hoverOver(tester, button);
  final wash = find.descendant(
    of: button,
    matching: find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          w.position == DecorationPosition.foreground &&
          w.decoration is BoxDecoration &&
          ((w.decoration as BoxDecoration).color?.a ?? 0) > 0,
    ),
  );
  expect(wash, findsNothing, reason: 'no wash drawn on hover when disabled');
  await tester.tap(button.first, warnIfMissed: false);
  await tester.pump();
}

/// Asserts a `PantasTapArea`-style area does nothing when disabled: no wash
/// on hover and no tap reaches the counter that [taps] reads.
Future<void> expectTapAreaInert(
  WidgetTester tester,
  Finder area,
  int Function() taps,
) async {
  await hoverOver(tester, area);
  expect(
    find.descendant(
      of: area,
      matching: find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.position == DecorationPosition.foreground &&
            w.decoration is BoxDecoration &&
            ((w.decoration as BoxDecoration).color?.a ?? 0) > 0,
      ),
    ),
    findsNothing,
  );
  await tester.tap(area, warnIfMissed: false);
  await tester.pump();
  expect(taps(), 0);
}
