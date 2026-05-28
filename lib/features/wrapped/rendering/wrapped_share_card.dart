import 'package:cse_cet_reviewer/features/wrapped/domain/wrapped_payload.dart';
import 'package:flutter/material.dart';

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
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF16213E), Color(0xFF533483), Color(0xFF0F3460)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pantas Wrapped',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                payload.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              if (primarySlide != null)
                Text(
                  primarySlide.body,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              if (includeArchetype) ...[
                const SizedBox(height: 24),
                Text(
                  payload.archetypeId.replaceAll('_', ' ').toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const Spacer(),
              const Text(
                'pantas.app/wrapped',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              const Text(
                'Watermarked by Pantas',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
