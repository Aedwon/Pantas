import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/accessibility.dart';

void main() {
  group('expectSurvivesTextScale', () {
    testWidgets('passes for a well-behaved text container at 1.0 and 2.0 text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const SingleChildScrollView(
          child: Column(
            children: [
              Text('Well-behaved text label'),
            ],
          ),
        ),
      );
    });
  });
}
