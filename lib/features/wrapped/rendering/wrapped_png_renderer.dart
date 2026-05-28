import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cse_cet_reviewer/features/wrapped/domain/wrapped_payload.dart';
import 'package:flutter/material.dart';

class WrappedPngRenderer {
  const WrappedPngRenderer();

  static const int width = 1080;
  static const int height = 1920;

  Future<Uint8List> render({
    required WrappedPayload payload,
    required bool includeArchetype,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const rect = Rect.fromLTWH(0, 0, 1080, 1920);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF16213E), Color(0xFF533483), Color(0xFF0F3460)],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
    _drawText(
      canvas,
      'Pantas Wrapped',
      const Offset(84, 128),
      42,
      Colors.white70,
      FontWeight.w700,
      width - 168,
    );
    _drawText(
      canvas,
      payload.title,
      const Offset(84, 640),
      76,
      Colors.white,
      FontWeight.w800,
      width - 168,
    );
    if (payload.slides.isNotEmpty) {
      _drawText(
        canvas,
        payload.slides.first.body,
        const Offset(84, 880),
        46,
        Colors.white.withValues(alpha: 0.88),
        FontWeight.w500,
        width - 168,
      );
    }
    if (includeArchetype) {
      _drawText(
        canvas,
        payload.archetypeId.replaceAll('_', ' ').toUpperCase(),
        const Offset(84, 1260),
        34,
        Colors.white70,
        FontWeight.w700,
        width - 168,
      );
    }
    _drawText(
      canvas,
      'pantas.app/wrapped',
      const Offset(84, 1700),
      34,
      Colors.white70,
      FontWeight.w500,
      width - 168,
    );
    _drawText(
      canvas,
      'Watermarked by Pantas',
      const Offset(84, 1764),
      30,
      Colors.white54,
      FontWeight.w500,
      width - 168,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Unable to render Wrapped PNG.');
    }
    return byteData.buffer.asUint8List();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    double fontSize,
    Color color,
    FontWeight weight,
    double maxWidth,
  ) {
    TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          height: 1.18,
        ),
      ),
      maxLines: 6,
      textDirection: TextDirection.ltr,
    )
      ..layout(maxWidth: maxWidth)
      ..paint(canvas, offset);
  }
}
