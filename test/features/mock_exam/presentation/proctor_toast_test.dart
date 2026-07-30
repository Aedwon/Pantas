import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/presentation/proctor_toast.dart';

void main() {
  Widget buildToast(int minutes) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: ProctorToast(minutes: minutes),
      ),
    );
  }

  Future<void> pumpToast(WidgetTester tester, {required int minutes}) async {
    await tester.pumpWidget(buildToast(minutes));
  }

  Color amberOf(WidgetTester tester) {
    final context = tester.element(find.byType(ProctorToast));
    return context.colors.amber;
  }

  test('the copy says subject, not part, and pluralizes one minute', () {
    expect(proctorCopyFor(20), '20 minutes left in this subject.');
    expect(proctorCopyFor(10), '10 minutes left in this subject.');
    expect(proctorCopyFor(5), '5 minutes left in this subject.');
    expect(proctorCopyFor(1), '1 minute left in this subject.');
  });

  testWidgets('it is not dismissible and carries no action or icon',
      (tester) async {
    await pumpToast(tester, minutes: 20);
    expect(find.byType(IconButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('the final call is amber', (tester) async {
    await pumpToast(tester, minutes: 1);
    final text =
        tester.widget<Text>(find.text('1 minute left in this subject.'));
    expect(text.style!.color, amberOf(tester));
  });

  testWidgets('every other call is ink', (tester) async {
    await pumpToast(tester, minutes: 5);
    final text =
        tester.widget<Text>(find.text('5 minutes left in this subject.'));
    expect(text.style!.color, isNot(amberOf(tester)));
  });

  testWidgets('it fires the haptic once per call', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') calls.add(call);
        return null;
      },
    );
    await pumpToast(tester, minutes: 20);
    await tester.pump(const Duration(milliseconds: 200));
    expect(calls.length, 3);
  });
}
