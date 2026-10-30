import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/wrapped/application/wrapped_providers.dart';
import 'package:pantas/features/wrapped/application/wrapped_share_flow.dart';
import 'package:pantas/features/wrapped/data/user_metrics_artifact_repository.dart';
import 'package:pantas/features/wrapped/presentation/my_shared_cards_page.dart';
import 'package:pantas/features/wrapped/presentation/share_privacy_sheet.dart';

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
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final styles = context.type;
    final colors = context.colors;
    final asyncEntry = ref.watch(wrappedArtifactProvider(widget.artifactId));
    firstScreenReady(context, ref, ready: !asyncEntry.isLoading);
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
          children: const [LoadingShapes()],
        ),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "Your Wrapped needs a connection. It'll be here when you're "
              'back.',
              style: styles.subhead.copyWith(color: colors.secondaryLabel),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (entry) {
          if (entry == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "Your Wrapped needs a connection. It'll be here when you're "
                  'back.',
                  style: styles.subhead.copyWith(color: colors.secondaryLabel),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              Text(entry.payload.title, style: styles.sectionHero),
              const SizedBox(height: 12),
              for (final slide in entry.payload.slides)
                ListRow(
                  title: slide.title,
                  subtitle: slide.body,
                  variant: ListRowVariant.value,
                  divider: true,
                ),
              const SizedBox(height: 18),
              SharePrivacySheet(
                selection: _selection,
                onChanged: (selection) =>
                    setState(() => _selection = selection),
              ),
              const SizedBox(height: 12),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: styles.subhead.copyWith(color: colors.destructive),
                ),
                const SizedBox(height: 8),
              ],
              PantasButton(
                label: _sharing ? 'Rendering...' : 'Share PNG',
                onPressed: _sharing ? null : () => _share(entry),
              ),
              const SizedBox(height: 8),
              Text(
                'pantas.study/wrapped',
                style: styles.footnote.copyWith(color: colors.secondaryLabel),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _share(UserMetricsArtifactEntry entry) async {
    setState(() {
      _sharing = true;
      _errorMessage = null;
    });
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
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage =
              "Your Wrapped needs a connection. It'll be here when you're "
                  'back.',
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}
