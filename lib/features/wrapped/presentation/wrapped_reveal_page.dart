import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/wrapped/application/wrapped_providers.dart';
import 'package:cse_cet_reviewer/features/wrapped/application/wrapped_share_flow.dart';
import 'package:cse_cet_reviewer/features/wrapped/data/user_metrics_artifact_repository.dart';
import 'package:cse_cet_reviewer/features/wrapped/presentation/my_shared_cards_page.dart';
import 'package:cse_cet_reviewer/features/wrapped/presentation/share_privacy_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WrappedRevealPage extends ConsumerStatefulWidget {
  const WrappedRevealPage({required this.artifactId, super.key});

  final String artifactId;

  @override
  ConsumerState<WrappedRevealPage> createState() => _WrappedRevealPageState();
}

class _WrappedRevealPageState extends ConsumerState<WrappedRevealPage> {
  SharePrivacySelection _selection = const SharePrivacySelection(
    includeArchetype: false,
    includeScore: false,
  );
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    final asyncEntry = ref.watch(wrappedArtifactProvider(widget.artifactId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wrapped'),
        actions: [
          IconButton(
            icon: const Icon(Icons.collections_bookmark_outlined),
            tooltip: 'My shared cards',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MySharedCardsPage(),
              ),
            ),
          ),
        ],
      ),
      body: asyncEntry.when(
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: const [FaintBars()],
        ),
        error: (_, __) => Center(
          child: Text(
            'Wrapped is unavailable.',
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
        ),
        data: (entry) {
          if (entry == null) {
            return Center(
              child: Text(
                'Wrapped is unavailable.',
                style: styles.bodyMedium.copyWith(color: colors.inkMuted),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              Text(entry.payload.title, style: styles.headlineMedium),
              const SizedBox(height: 12),
              for (final slide in entry.payload.slides)
                InkTableRow(title: slide.title, subtitle: slide.body),
              const SizedBox(height: 18),
              SharePrivacySheet(
                selection: _selection,
                onChanged: (selection) =>
                    setState(() => _selection = selection),
              ),
              const SizedBox(height: 12),
              BoardButton(
                label: _sharing ? 'Rendering...' : 'Share PNG',
                onPressed: _sharing ? null : () => _share(entry),
              ),
              const SizedBox(height: 8),
              Text(
                'pantas.app/wrapped',
                style: styles.labelSmall.copyWith(color: colors.inkMuted),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _share(UserMetricsArtifactEntry entry) async {
    setState(() => _sharing = true);
    try {
      final flow = WrappedShareFlow(
        repository: ref.read(userMetricsArtifactRepositoryProvider),
        host: ref.read(wrappedShareHostProvider),
      );
      await flow.renderAndMarkShared(
        entry: entry,
        includeArchetype: _selection.includeArchetype,
      );
      ref.invalidate(wrappedArtifactProvider(widget.artifactId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PNG rendered for sharing.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}
