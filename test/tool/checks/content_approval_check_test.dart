import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/content_approval_check.dart';
import '../content/fixtures/fixture.dart';

void main() {
  test('registered check reports questions from project content root', () {
    final content = createContentFixture();
    final project = Directory.systemTemp.createTempSync('approval-check-');
    addTearDown(() {
      project.deleteSync(recursive: true);
    });
    content.renameSync('${project.path}/content');
    expect(
      File('tool/checks/run_checks.dart').readAsStringSync(),
      contains('ContentApprovalCheck(),'),
    );
    final findings = const ContentApprovalCheck().run(project.path);
    expect(findings.map((f) => f.where), contains('q-one'));
  });
}
