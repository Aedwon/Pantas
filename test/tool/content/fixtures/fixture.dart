import 'dart:io';

Directory createContentFixture() {
  final root = Directory.systemTemp.createTempSync('content-gate-');
  final file = File('${root.path}/questions/math/numbers/addition.yaml');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    File('test/tool/content/fixtures/questions.yaml').readAsStringSync(),
  );
  return root;
}
