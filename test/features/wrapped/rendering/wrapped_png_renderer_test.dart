import 'dart:ui' as ui;

import 'package:cse_cet_reviewer/features/wrapped/domain/wrapped_payload.dart';
import 'package:cse_cet_reviewer/features/wrapped/rendering/wrapped_png_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('renders a single 9:16 watermarked PNG', () async {
    final bytes = await const WrappedPngRenderer().render(
      payload: const WrappedPayload(
        title: 'Mock 3 - Personal Best',
        slides: [WrappedSlide(title: 'Score', body: 'You beat your best.')],
        archetypeId: 'game_day_player',
        shareId: 'share_1',
      ),
      includeArchetype: false,
    );

    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    expect(frame.image.width, WrappedPngRenderer.width);
    expect(frame.image.height, WrappedPngRenderer.height);
    expect(bytes.length, greaterThan(1000));
  });

  test('renders a card with the share URL and QR baked in', () async {
    final bytes = await const WrappedPngRenderer().render(
      payload: const WrappedPayload(
        title: 'Day 30 Streak',
        slides: [WrappedSlide(title: 'Streak', body: 'Thirty days strong.')],
        archetypeId: 'steady_builder',
        shareId: 'deadbeefdeadbeefdeadbeefdeadbeef',
      ),
      includeArchetype: true,
      shareId: 'deadbeefdeadbeefdeadbeefdeadbeef',
    );

    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    expect(frame.image.width, WrappedPngRenderer.width);
    expect(frame.image.height, WrappedPngRenderer.height);
    expect(bytes.length, greaterThan(1000));
  });
}
