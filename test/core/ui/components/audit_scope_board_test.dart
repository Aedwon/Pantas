import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

const subjects = [
  ScopeSubject(title: 'Math', topics: [
    ScopeTopic(id: 't', title: 'Geometry', lessons: [
      ScopeLesson(id: 'l', title: 'Circles', unread: true),
      ScopeLesson(id: 'l2', title: 'Measurement')
    ]),
    ScopeTopic(id: 'empty', title: 'Algebra', hasQuestions: false)
  ])
];
void main() {
  for (final brightness in Brightness.values) {
    testWidgets('QZ_Picker layout and real status colors $brightness',
        (tester) async {
      final picker = ScopePicker(
          subjects: subjects, selectedIds: const {'l'}, onChanged: (_) {});
      await pumpAccessibilitySurface(tester, picker,
          brightness: brightness,
          viewportSize: const Size(390, 844),
          disableAnimations: true);
      await tester.tap(find.byKey(const ValueKey('scope-expand-t')));
      await tester.pumpAndSettle();
      final lesson = find.byKey(const ValueKey('scope-select-l'));
      final padding = tester.widget<Padding>(
          find.descendant(of: lesson, matching: find.byType(Padding)).first);
      expect((padding.padding as EdgeInsets).left, 42);
      final material = tester.widget<Material>(
          find.ancestor(of: lesson, matching: find.byType(Material)).first);
      final c = brightness == Brightness.light
          ? PantasColors.light
          : PantasColors.dark;
      expect(material.color, c.pickerBackground);
      for (final entry
          in {'Circles': 'Unread', 'Algebra': 'No questions yet'}.entries) {
        expect(tester.getCenter(find.text(entry.key)).dy,
            tester.getCenter(find.text(entry.value)).dy);
        expect(tester.getRect(find.text(entry.value)).left,
            greaterThan(tester.getRect(find.text(entry.key)).right));
      }
      expectContrast(tester.widget<Text>(find.text('Unread')).style!.color!,
          material.color!);
      expect(find.byKey(const ValueKey('scope-rule-t')), findsOneWidget);
      expect(tester.getSize(find.byKey(const ValueKey('scope-rule-t'))).height,
          .5);
      await expectSurvivesTextScale(tester, picker,
          brightness: brightness,
          viewportSize: const Size(390, 844),
          disableAnimations: true);
    });
    testWidgets('QZ_Picker separate expansion and caret timelines $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
          tester,
          ScopePicker(
              subjects: subjects, selectedIds: const {}, onChanged: (_) {}),
          brightness: brightness);
      await tester.tap(find.byKey(const ValueKey('scope-expand-t')));
      await tester.pump();
      final expansion = find.byKey(const ValueKey('scope-lessons-t'));
      final animated = tester.widget<AnimatedSize>(expansion);
      expect(animated.duration, const Duration(milliseconds: 600));
      final caret = find.byKey(const ValueKey('scope-caret-t'));
      final rotation = tester.widget<AnimatedRotation>(caret);
      expect(rotation.turns, .5);
      expect(rotation.curve, PantasCurves.houseOut);
      await tester.pump(const Duration(milliseconds: 150));
      final transform = tester.widget<RotationTransition>(find.descendant(
          of: caret, matching: find.byType(RotationTransition)));
      expect(transform.turns.value, closeTo(.4709586, .002));
      await tester.pump(const Duration(milliseconds: 150));
      final middleHeight = tester.getSize(expansion).height;
      await tester.pump(const Duration(milliseconds: 300));
      expect(middleHeight / tester.getSize(expansion).height,
          closeTo(.9419172, .003));
      final base = tester
          .widget<Transform>(find.byKey(const ValueKey('scope-caret-base-t')));
      expect(base.transform.storage[0], closeTo(math.cos(math.pi / 2), .001));
    });
    testWidgets('QZ_Picker selection mark pops at 110ms $brightness',
        (tester) async {
      var selection = <String>{};
      final picker = StatefulBuilder(
          builder: (context, setState) => ScopePicker(
              subjects: subjects,
              selectedIds: selection,
              atLeastOne: false,
              onChanged: (v) => setState(() => selection = v)));
      await pumpAccessibilitySurface(tester, picker, brightness: brightness);
      await tester.tap(find.byKey(const ValueKey('scope-select-t')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 110));
      final scale = tester
          .widget<Transform>(find.byKey(const ValueKey('scope-mark-scale-t')));
      final opacity = tester
          .widget<Opacity>(find.byKey(const ValueKey('scope-mark-opacity-t')));
      expect(scale.transform.storage[0],
          closeTo(.5 + .5 * PantasCurves.popB.transform(.5), .002));
      expect(opacity.opacity, 1);
      await tester.pump(const Duration(milliseconds: 110));
      expect(
          tester
              .widget<Transform>(
                  find.byKey(const ValueKey('scope-mark-scale-t')))
              .transform
              .storage[0],
          1);
    });
  }
}
