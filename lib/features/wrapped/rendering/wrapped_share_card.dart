import 'package:flutter/material.dart';
import 'package:pantas/features/wrapped/domain/wrapped_payload.dart';

// The light palette by value, not by theme lookup. A share card is rendered
// off screen to a PNG and must not follow the reader's dark mode: what they
// post is a sheet of paper whatever their phone is set to.
const Color _paper = Color(0xFFFBF9F4);
const Color _ink = Color(0xFF26221B);
const Color _inkMuted = Color(0xFF6E675C);

class WrappedShareCard extends StatelessWidget {
  const WrappedShareCard({
    required this.payload,
    required this.includeArchetype,
    super.key,
  });

  final WrappedPayload payload;
  final bool includeArchetype;

  static const Size outputSize = Size(1080, 1920);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primarySlide = payload.slides.isEmpty ? null : payload.slides.first;
    return AspectRatio(
      aspectRatio: 9 / 16,
      // Paper and ink, not a gradient.
      //
      // This was purple and navy over white, which is pre-redesign styling and
      // specifically a gradient, the first thing the identity lists among the
      // patterns it exists to remove. **It is also the most public thing the
      // app makes**: the one artefact a student posts, seen by people who have
      // never opened Pantas.
      child: DecoratedBox(
        decoration: const BoxDecoration(color: _paper),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pantas Wrapped',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: _inkMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              // The rule under the wordmark, which is the device every ruled
              // surface in the app opens with.
              const SizedBox(
                width: double.infinity,
                height: 1.6,
                child: ColoredBox(color: _ink),
              ),
              const Spacer(),
              Text(
                payload.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              if (primarySlide != null)
                Text(
                  primarySlide.body,
                  style: theme.textTheme.titleMedium?.copyWith(color: _ink),
                ),
              if (includeArchetype) ...[
                const SizedBox(height: 24),
                Text(
                  payload.archetypeId.replaceAll('_', ' ').toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: _inkMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const Spacer(),
              const Text(
                'pantas.app/wrapped',
                style: TextStyle(color: _inkMuted),
              ),
              const SizedBox(height: 8),
              const Text(
                'Watermarked by Pantas',
                style: TextStyle(color: _inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
