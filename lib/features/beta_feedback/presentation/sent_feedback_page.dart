import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/legacy_theme_shim.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/presentation/exit_survey_page.dart';
import 'package:pantas/features/beta_feedback/presentation/fb_kit.dart';

/// A download URL for one of the tester's own images.
final _sentImageUrlProvider = FutureProvider.autoDispose.family<String, String>(
  (ref, path) => ref.watch(betaFeedbackApiProvider).imageUrl(path),
);

/// One sent feedback, whole: its date as the title, the full text, and each
/// image at its own shape. The boards do not draw it; this is the lead's
/// ruling for the page a Sent row opens.
class SentFeedbackPage extends ConsumerWidget {
  const SentFeedbackPage({required this.frame, required this.id, super.key});
  final FeedbackFrame frame;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sent = ref.watch(sentFeedbackProvider);
    final item = sent.valueOrNull?.where((s) => s.id == id).firstOrNull;
    final wide = context.fbWide;
    final c = context.fb;
    void back() => leavePage(context, fallback: feedbackPath);

    Widget shell(String title, List<Widget> children) => frame(
          title: title,
          backLabel: 'Feedback',
          onBack: back,
          children: children,
        );

    if (item == null) {
      if (sent.isLoading) {
        return shell(
          '',
          const [SkeletonPulse(child: SkeletonBlock(height: 96))],
        );
      }
      return shell('', [
        Text(
          'This feedback is not available.',
          style: context.fbText(15, color: c.secondaryLabel),
        ),
      ]);
    }
    final hasText = item.text.trim().isNotEmpty;
    return shell(stamp(item.createdAt), [
      if (hasText)
        FbCard(
          key: const ValueKey('sent-text-card'),
          padding:
              EdgeInsets.symmetric(horizontal: 16, vertical: wide ? 14 : 12),
          child: SelectableText(
            item.text.trim(),
            style: wide
                ? context.fbText(16, height: 1.4)
                : context.fbText(17, height: 1.35, spacing: -.204),
          ),
        ),
      for (var i = 0; i < item.attachments.length; i++) ...[
        SizedBox(height: hasText || i > 0 ? 10 : 0),
        _SentImage(
          key: ValueKey('sent-image-$i'),
          path: item.attachments[i].path,
          number: i + 1,
        ),
      ],
    ]);
  }
}

class _SentImage extends ConsumerWidget {
  const _SentImage({required this.path, required this.number, super.key});
  final String path;
  final int number;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.fb;
    final url = ref.watch(_sentImageUrlProvider(path));
    Widget placeholder([Widget? child]) => AspectRatio(
          aspectRatio: 16 / 10,
          child: ColoredBox(color: c.fill, child: child),
        );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: url.when(
        loading: placeholder,
        error: (_, __) => placeholder(
          Center(
            child: Text(
              'Could not load this image.',
              style: context.fbText(13, color: c.secondaryLabel),
            ),
          ),
        ),
        data: (u) => Semantics(
          image: true,
          label: 'Image $number',
          child: Image.network(
            u,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            // Storage download URLs carry no CORS headers unless the bucket
            // is configured for them; an <img> element shows them anyway.
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : placeholder(),
            errorBuilder: (_, __, ___) => placeholder(
              Center(
                child: Text(
                  'Could not load this image.',
                  style: context.fbText(13, color: c.secondaryLabel),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
