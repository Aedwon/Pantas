import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/lesson_svg.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final root = Platform.environment['B9_SVG_ROOT'] ?? 'content/illustrations';
  final files = File(root).existsSync()
      ? [File(root)]
      : Directory(root)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.svg'))
          .toList();
  for (final file in files) {
    for (final colors in [PantasColors.light, PantasColors.dark]) {
      test(
          'draw ${file.path} '
          '${colors == PantasColors.light ? 'light' : 'dark'}', () async {
        final url =
            Uri.dataFromBytes(file.readAsBytesSync(), mimeType: 'image/svg+xml')
                .toString();
        final picture =
            await vg.loadPicture(lessonSvgLoader(url, colors), null);
        try {
          expect(picture.size.isEmpty, isFalse, reason: file.path);
          final image = await picture.picture.toImage(320, 240);
          try {
            expect(await image.toByteData(), isNotNull, reason: file.path);
          } finally {
            image.dispose();
          }
        } finally {
          picture.picture.dispose();
        }
      });
    }
  }
  test(
    'SVG root exists',
    () => expect(
      File(root).existsSync() || Directory(root).existsSync(),
      isTrue,
    ),
  );
}
