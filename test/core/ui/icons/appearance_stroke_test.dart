import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/icons/own/own_icons.dart';

void main() {
  test('Appearance filled half retains the SVG dividing-edge stroke', () async {
    final recorder = ui.PictureRecorder();
    const AppearancePainter(Colors.black)
        .paint(Canvas(recorder), const Size.square(24));
    final picture = recorder.endRecording();
    final image = await picture.toImage(24, 24);
    final bytes = (await image.toByteData())!;
    // The path's stroke extends .75 left of x=12, inside the circular outline.
    expect(bytes.getUint8((12 * 24 + 11) * 4 + 3), greaterThan(0));
    image.dispose();
    picture.dispose();
  });
}
