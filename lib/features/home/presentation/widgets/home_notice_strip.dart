import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/home_notices.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

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
  DateTime? _pickedDay;
  bool _saving = false;
  bool _failed = false;

  Future<void> _saveDay() async {
    final day = _pickedDay;
    if (day == null || _saving) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    final telemetry = ref.read(telemetryProvider);
    try {
      await ref.read(settingsActionsProvider).saveExamDate(
            ExamDate.onDay(day),
            today: ref.read(nowProvider)(),
          );
      if (!mounted) return;
      ref.invalidate(homeNoticeProvider);
      setState(() {
        _expanded = false;
        _pickedDay = null;
      });
    } on Object catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _days(HomeNotice notice) {
    final month = DateTime.parse(notice.dismissalToken);
    final now = ref.read(nowProvider)();
    final today = DateTime(now.year, now.month, now.day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var day = 1;
                  day <= DateTime(month.year, month.month + 1, 0).day;
                  day++)
                if (!DateTime(month.year, month.month, day).isBefore(today))
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: SizedBox(
                      width: 44,
                      child: TextButton(
                        key: ValueKey('notice-day-$day'),
                        onPressed: _saving
                            ? null
                            : () => setState(
                                  () => _pickedDay =
                                      DateTime(month.year, month.month, day),
                                ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(44, 52),
                          backgroundColor: _pickedDay?.day == day
                              ? context.colors.accentFill
                              : context.colors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: context.colors.separator),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('EEE', 'en_US').format(
                                DateTime(month.year, month.month, day),
                              ),
                              style: context.type.caption.copyWith(
                                fontSize: 10,
                                color: _pickedDay?.day == day
                                    ? context.colors.onAccent
                                    : context.colors.secondaryLabel,
                              ),
                            ),
                            Text(
                              '$day',
                              style: context.type.body.copyWith(
                                fontWeight: _pickedDay?.day == day
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: _pickedDay?.day == day
                                    ? context.colors.onAccent
                                    : context.colors.label,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
        if (_failed) saveFailureLine(() => unawaited(_saveDay())),
      ],
    );
  }

  Future<void> _dismiss(HomeNotice notice) async {
    await ref.read(appPreferencesRepositoryProvider).setDeviceValue(
          'home_notice_dismissed_${notice.kind.name}',
          notice.dismissalToken,
        );
    if (!mounted) return;
    ref.invalidate(homeNoticeProvider);
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
      case HomeNoticeKind.monthOnly:
        unawaited(_saveDay());
      case HomeNoticeKind.noDate:
        widget.onDate(notice.kind);
      case HomeNoticeKind.service:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notice = ref.watch(homeNoticeProvider).valueOrNull;
    if (notice == null) {
      return const SizedBox.shrink();
    }
    if (context.wideWeb) {
      return HomeWebNotice(
        title: notice.title,
        icon: switch (notice.kind) {
          HomeNoticeKind.trial => PantasIcons.timer,
          HomeNoticeKind.welcome => PantasIcons.pro,
          HomeNoticeKind.service =>
            const IconData(0xe2ce, fontFamily: 'Phosphor'),
          HomeNoticeKind.noDate ||
          HomeNoticeKind.monthOnly =>
            PantasIcons.addDate,
        },
        iconColor: notice.kind == HomeNoticeKind.welcome
            ? context.colors.accent
            : null,
        detail: notice.detail,
        expanded: _expanded,
        onToggle: notice.detail == null
            ? null
            : () => setState(() => _expanded = !_expanded),
        onClose: () => unawaited(_dismiss(notice)),
        primaryLabel: notice.kind == HomeNoticeKind.monthOnly
            ? (_pickedDay == null ? 'Pick the Day' : 'Save')
            : notice.primaryLabel,
        editor: notice.kind == HomeNoticeKind.monthOnly ? _days(notice) : null,
        onPrimary: notice.kind == HomeNoticeKind.monthOnly
            ? _saving
                ? null
                : _pickedDay == null
                    ? () => widget.onDate(notice.kind)
                    : () => unawaited(_saveDay())
            : () => _primary(notice),
        secondaryLabel: notice.secondaryLabel,
        onSecondary: () => unawaited(_dismiss(notice)),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: NoticeStrip(
        title: notice.title,
        detail: notice.detail,
        expanded: _expanded,
        icon: switch (notice.kind) {
          HomeNoticeKind.trial => PantasIcons.timer,
          HomeNoticeKind.welcome => PantasIcons.pro,
          HomeNoticeKind.service =>
            const IconData(0xe2ce, fontFamily: 'Phosphor'),
          HomeNoticeKind.noDate ||
          HomeNoticeKind.monthOnly =>
            PantasIcons.addDate,
        },
        iconColor: notice.kind == HomeNoticeKind.welcome
            ? context.colors.accent
            : null,
        onToggle: notice.detail == null
            ? null
            : () => setState(() => _expanded = !_expanded),
        onClose: () => unawaited(_dismiss(notice)),
        primaryLabel: notice.primaryLabel,
        editor: notice.kind == HomeNoticeKind.monthOnly ? _days(notice) : null,
        onPrimary: notice.kind == HomeNoticeKind.monthOnly &&
                (_pickedDay == null || _saving)
            ? null
            : () => _primary(notice),
        secondaryLabel: notice.secondaryLabel,
        onSecondary: () => unawaited(_dismiss(notice)),
      ),
    );
  }
}
