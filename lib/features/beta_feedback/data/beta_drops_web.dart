import 'dart:async';
import 'dart:js_interop';

import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
// The browser API package is already locked through Flutter's web plugins.
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

/// Files dropped on the page, and images pasted into it. The listeners exist
/// only while something listens to the stream.
///
/// A paste carries only its images, so pasting text still works. A drop
/// carries every file, so a refused type gets a message instead of silence.
/// Either way the browser's own handling is stopped, or a dropped file would
/// open in this tab and replace the page.
Stream<List<PickedImage>> webDropsAndPastes() {
  late final StreamController<List<PickedImage>> controller;

  late final JSFunction onPaste = ((web.Event event) {
    final data = (event as web.ClipboardEvent).clipboardData;
    if (data == null) return;
    final files = _files(data).where((f) => f.type.startsWith('image/'));
    if (files.isEmpty) return;
    event.preventDefault();
    unawaited(_emit(controller, files.toList()));
  }).toJS;

  late final JSFunction onDragOver = ((web.Event event) {
    final data = (event as web.DragEvent).dataTransfer;
    if (data != null && _hasFiles(data)) event.preventDefault();
  }).toJS;

  late final JSFunction onDrop = ((web.Event event) {
    final data = (event as web.DragEvent).dataTransfer;
    if (data == null || !_hasFiles(data)) return;
    event.preventDefault();
    final files = _files(data);
    if (files.isNotEmpty) unawaited(_emit(controller, files));
  }).toJS;

  controller = StreamController<List<PickedImage>>(
    onListen: () {
      web.document
        ..addEventListener('paste', onPaste)
        ..addEventListener('dragover', onDragOver)
        ..addEventListener('drop', onDrop);
    },
    onCancel: () {
      web.document
        ..removeEventListener('paste', onPaste)
        ..removeEventListener('dragover', onDragOver)
        ..removeEventListener('drop', onDrop);
    },
  );
  return controller.stream;
}

bool _hasFiles(web.DataTransfer data) =>
    data.types.toDart.any((type) => type.toDart == 'Files');

List<web.File> _files(web.DataTransfer data) {
  final list = data.files;
  return [
    for (var i = 0; i < list.length; i++)
      if (list.item(i) case final web.File file) file,
  ];
}

Future<void> _emit(
  StreamController<List<PickedImage>> controller,
  List<web.File> files,
) async {
  final images = <PickedImage>[];
  for (final file in files) {
    try {
      final buffer = (await file.arrayBuffer().toDart).toDart;
      images.add(
        PickedImage(
          bytes: buffer.asUint8List(),
          contentType: file.type.toLowerCase(),
          name: file.name,
        ),
      );
    } on Object {
      // A file the browser cannot read is skipped; the rest still arrive.
    }
  }
  if (images.isNotEmpty && !controller.isClosed && controller.hasListener) {
    controller.add(images);
  }
}
