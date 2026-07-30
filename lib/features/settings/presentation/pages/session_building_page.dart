import 'dart:async';

import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _explain(SessionOrdering ordering) => switch (ordering) {
      SessionOrdering.blocked => 'Every question from the chosen topic',
      SessionOrdering.interleavedTail =>
        'Seven from the topic, three from elsewhere',
      SessionOrdering.fullyMixed =>
        'No two consecutive questions from the same topic',
    };

String _name(SessionOrdering ordering) => switch (ordering) {
      SessionOrdering.blocked => 'Blocked',
      SessionOrdering.interleavedTail => 'Interleaved tail',
      SessionOrdering.fullyMixed => 'Fully mixed',
    };

/// Opened by the session panel's "Change how sessions are built".
class SessionBuildingPage extends ConsumerWidget {
  const SessionBuildingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(userSettingsProvider).valueOrNull ?? UserSettings.defaults();
    final actions = ref.read(settingsActionsProvider);
    final styles = context.textStyles;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('How sessions are built')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          for (final ordering in SessionOrdering.values)
            InkWell(
              onTap: () => unawaited(actions.setSessionOrdering(ordering)),
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colors.ruleFaint,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _name(ordering),
                                style: styles.headlineSmall,
                              ),
                              if (ordering.isRecommended) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'Recommended',
                                  style: styles.bodySmall.copyWith(
                                    color: colors.board,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _explain(ordering),
                            style: styles.bodySmall
                                .copyWith(color: colors.inkMuted),
                          ),
                        ],
                      ),
                    ),
                    if (settings.sessionOrdering == ordering)
                      Icon(Icons.check, size: 18, color: colors.ink),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
