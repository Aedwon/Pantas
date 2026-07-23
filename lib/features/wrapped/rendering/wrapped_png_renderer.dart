import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cse_cet_reviewer/features/wrapped/domain/wrapped_payload.dart';
import 'package:cse_cet_reviewer/features/wrapped/domain/wrapped_share_url.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// The light palette by value. A share card is rendered off screen and must
// not follow the reader's dark mode: what they post is a sheet of paper.
const Color _paper = Color(0xFFFBF9F4);
const Color _ink = Color(0xFF26221B);
const Color _inkMuted = Color(0xFF6E675C);

class WrappedPngRenderer {
  const WrappedPngRenderer();

  static const int width = 1080;
  static const int height = 1920;

  Future<Uint8List> render({
    required WrappedPayload payload,
    required bool includeArchetype,
    String? shareId,
  }) async {
    final shareUrl = shareId == null
        ? WrappedShareUrl.base
        : WrappedShareUrl.forShareId(shareId);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const rect = Rect.fromLTWH(0, 0, 1080, 1920);
    // Paper, not a gradient, and the same paper whatever the reader's theme
    // is set to. This is the artefact a student posts, so it is the one place
    // the identity is seen by people who have never opened the app.
    canvas
      ..drawRect(rect, Paint()..color = _paper)
      // The rule under the wordmark, as on every ruled surface in the app.
      ..drawRect(
        const Rect.fromLTWH(84, 190, 1080 - 168, 2),
        Paint()..color = _ink,
      );
    _drawText(
      canvas,
      'Pantas Wrapped',
      const Offset(84, 128),
      42,
      _inkMuted,
      FontWeight.w700,
      width - 168,
    );
    _drawText(
      canvas,
      payload.title,
      const Offset(84, 640),
      76,
      _ink,
      FontWeight.w700,
      width - 168,
    );
    if (payload.slides.isNotEmpty) {
      _drawText(
        canvas,
        payload.slides.first.body,
        const Offset(84, 880),
        46,
        _ink,
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
        _inkMuted,
        FontWeight.w700,
        width - 168,
      );
    }
    _drawText(
      canvas,
      shareUrl.replaceFirst('https://', ''),
      const Offset(84, 1700),
      34,
      _inkMuted,
      FontWeight.w500,
      width - 168,
    );
    _drawText(
      canvas,
      'Watermarked by Pantas',
      const Offset(84, 1764),
      30,
      _inkMuted,
      FontWeight.w500,
      width - 168,
    );
    _drawQrCode(canvas, shareUrl);

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Unable to render Wrapped PNG.');
    }
    return byteData.buffer.asUint8List();
  }

  void _drawQrCode(Canvas canvas, String data) {
    const qrSize = 240.0;
    const padding = 16.0;
    const left = width - 84 - qrSize;
    const top = 1480.0;
    // White quiet-zone background so the QR scans against the gradient.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          left - padding,
          top - padding,
          qrSize + padding * 2,
          qrSize + padding * 2,
        ),
        const Radius.circular(16),
      ),
      Paint()..color = Colors.white,
    );
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF16213E),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF16213E),
      ),
    );
    canvas
      ..save()
      ..translate(left, top);
    painter.paint(canvas, const Size(qrSize, qrSize));
    canvas.restore();
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
