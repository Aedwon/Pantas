import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/features/home/application/home_notices.dart';

/// Date notices hide until the next visit: they live in memory only, so a
/// restart shows them again. Account notices are stored and stay gone.
final homeNoticeVisitHiddenProvider =
    StateProvider<Set<HomeNoticeKind>>((ref) => const {});

bool _storesDismissal(HomeNoticeKind kind) =>
    kind != HomeNoticeKind.noDate && kind != HomeNoticeKind.monthOnly;

/// One thin outlined strip under the week, one notice at a time. Priority and
/// dismissal tokens come from [homeNoticeProvider].
class HomeNoticeStrip extends ConsumerStatefulWidget {
  const HomeNoticeStrip({
    required this.onDate,
    required this.onRoute,
    super.key,
  });

  /// Opens Home's date sheet for the date notices.
  final ValueChanged<HomeNoticeKind> onDate;

  /// Pushes a destination outside the tab shell.
  final ValueChanged<String> onRoute;

  @override
  ConsumerState<HomeNoticeStrip> createState() => _HomeNoticeStripState();
}

class _HomeNoticeStripState extends ConsumerState<HomeNoticeStrip> {
  bool _expanded = false;

  Future<void> _dismiss(HomeNotice notice) async {
    if (_storesDismissal(notice.kind)) {
      await ref.read(appPreferencesRepositoryProvider).setDeviceValue(
            'home_notice_dismissed_${notice.kind.name}',
            notice.dismissalToken,
          );
      ref.invalidate(homeNoticeProvider);
    } else {
      ref.read(homeNoticeVisitHiddenProvider.notifier).update(
            (hidden) => {...hidden, notice.kind},
          );
    }
    if (mounted) setState(() => _expanded = false);
  }

  void _primary(HomeNotice notice) {
    switch (notice.kind) {
      case HomeNoticeKind.trial:
        widget.onRoute('/settings/pro');
      case HomeNoticeKind.welcome:
        // Topics and lessons are what Pro just opened.
        unawaited(_dismiss(notice));
        widget.onRoute('/performance');
      case HomeNoticeKind.noDate || HomeNoticeKind.monthOnly:
        widget.onDate(notice.kind);
      case HomeNoticeKind.service:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notice = ref.watch(homeNoticeProvider).valueOrNull;
    final hidden = ref.watch(homeNoticeVisitHiddenProvider);
    if (notice == null || hidden.contains(notice.kind)) {
      return const SizedBox.shrink();
    }
    return NoticeStrip(
      title: notice.title,
      detail: notice.detail,
      expanded: _expanded,
      icon: switch (notice.kind) {
        HomeNoticeKind.trial || HomeNoticeKind.welcome => PantasIcons.pro,
        _ => null,
      },
      onToggle: notice.detail == null
          ? null
          : () => setState(() => _expanded = !_expanded),
      onClose: () => unawaited(_dismiss(notice)),
      primaryLabel: notice.primaryLabel,
      onPrimary: () => _primary(notice),
      secondaryLabel: notice.secondaryLabel,
      onSecondary: () => unawaited(_dismiss(notice)),
    );
  }
}
