import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pantas/features/beta_feedback/data/picker_beta_image_source.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';

XFile _file(String name, {String? mime, int length = 3}) =>
    // Off the web a file's name comes from its path.
    XFile.fromData(Uint8List(length), name: name, path: name, mimeType: mime);

void main() {
  PickerBetaImageSource source(List<XFile> files, {List<int>? asked}) =>
      PickerBetaImageSource(
        pickFiles: (max) async {
          asked?.add(max);
          return files;
        },
      );

  group('pick', () {
    test('reads the bytes and takes the type the picker reports', () async {
      final picked = await source([
        _file('a.png', mime: 'image/png', length: 5),
        _file('b.webp', mime: 'image/webp'),
      ]).pick(max: 3);
      expect(picked.map((p) => p.contentType), ['image/png', 'image/webp']);
      expect(picked.first.bytes.length, 5);
      expect(picked.map((p) => p.name), ['a.png', 'b.webp']);
    });

    test('falls back to the extension when there is no type', () async {
      final picked = await source([
        _file('photo.JPG'),
        _file('shot.jpeg'),
        _file('art.PNG'),
        _file('web.webp'),
      ]).pick(max: 4);
      expect(picked.map((p) => p.contentType), [
        'image/jpeg',
        'image/jpeg',
        'image/png',
        'image/webp',
      ]);
    });

    test('writes image/jpg as image/jpeg', () async {
      final picked =
          await source([_file('a.jpg', mime: 'image/jpg')]).pick(max: 1);
      expect(picked.single.contentType, 'image/jpeg');
    });

    test('a type nobody can name stays refusable', () async {
      final picked =
          await source([_file('notes.txt'), _file('x.heic')]).pick(max: 2);
      expect(picked.map(problemWith), [
        PickedImageProblem.wrongType,
        PickedImageProblem.wrongType,
      ]);
    });

    test('keeps at most max when the platform ignores the limit', () async {
      final picked = await source([
        _file('1.png'),
        _file('2.png'),
        _file('3.png'),
        _file('4.png'),
      ]).pick(max: 2);
      expect(picked, hasLength(2));
    });

    test('passes max to the picker and gives nothing for a canceled pick',
        () async {
      final asked = <int>[];
      final picked = await source(const [], asked: asked).pick(max: 3);
      expect(picked, isEmpty);
      expect(asked, [3]);
    });

    test('asks for nothing when no room is left', () async {
      final asked = <int>[];
      final picked = await source([_file('a.png')], asked: asked).pick(max: 0);
      expect(picked, isEmpty);
      expect(asked, isEmpty);
    });
  });

  group('dropsAndPastes', () {
    test('uses the platform stream it is given', () async {
      final image = PickedImage(bytes: Uint8List(1), contentType: 'image/png');
      final stream = PickerBetaImageSource(
        pickFiles: (_) async => const [],
        drops: () => Stream.value([image]),
      ).dropsAndPastes();
      expect(await stream.first, [image]);
    });

    test('never emits outside the browser', () async {
      final events = <List<PickedImage>>[];
      final sub = PickerBetaImageSource(pickFiles: (_) async => const [])
          .dropsAndPastes()
          .listen(events.add);
      await pumpEventQueue();
      await sub.cancel();
      expect(events, isEmpty);
    });
  });
}
