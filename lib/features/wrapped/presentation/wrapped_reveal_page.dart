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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Wrapped is unavailable.')),
        data: (entry) {
          if (entry == null) {
            return const Center(child: Text('Wrapped is unavailable.'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                entry.payload.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 18),
              for (final slide in entry.payload.slides)
                Card(
                  child: ListTile(
                    title: Text(slide.title),
                    subtitle: Text(slide.body),
                  ),
                ),
              const SizedBox(height: 18),
              SharePrivacySheet(
                selection: _selection,
                onChanged: (selection) =>
                    setState(() => _selection = selection),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _sharing ? null : () => _share(entry),
                child: Text(_sharing ? 'Rendering...' : 'Share PNG'),
              ),
              const SizedBox(height: 8),
              const Text('pantas.app/wrapped'),
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
