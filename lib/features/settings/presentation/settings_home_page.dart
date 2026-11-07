import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/icons/own/own_icons.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/motion/pantas_durations.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/widgets/beta_pro_row.dart';
import 'package:pantas/features/settings/settings.dart';
import 'package:url_launcher/url_launcher.dart';

final settingsSessionLengthProvider = FutureProvider<int>((ref) async {
  return (await ref.watch(quizPreferencesRepositoryProvider).read())
      .sessionLength;
});

/// "{n} of 5 days" for the Feedback row, or null while the days load. The
/// count stops at 5 even when more days were counted (lead ruling).
final feedbackRowValueProvider = Provider.autoDispose<String?>((ref) {
  if (!ref.watch(betaFeedbackVisibleProvider)) return null;
  final reward = ref.watch(betaRewardProvider).valueOrNull;
  if (reward == null) return null;
  return '${math.min(5, reward.days.length)} of 5 days';
});

/// The raised BETA mark after "Feedback" (FbSettingsB): 9 px, w700, 1 px down
/// and 4 px after the title.
class SettingsBetaMark extends StatelessWidget {
  const SettingsBetaMark({this.top = 1, super.key});
  final double top;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.only(top: top, left: 4),
          child: Text(
            'BETA',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .72,
              height: 1,
              color: context.colors.accent,
            ),
          ),
        ),
      );
}

/// The chat-bubble glyph of the Feedback row, stroked on a 24 unit grid.
class SettingsFeedbackGlyph extends StatelessWidget {
  const SettingsFeedbackGlyph({
    required this.size,
    required this.color,
    super.key,
  });
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: CustomPaint(
          size: Size.square(size),
          painter: _FeedbackGlyphPainter(color),
        ),
      );
}

class _FeedbackGlyphPainter extends CustomPainter {
  const _FeedbackGlyphPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    canvas
      ..drawPath(
        Path()
          ..moveTo(4 * k, 5.5 * k)
          ..lineTo(20 * k, 5.5 * k)
          ..lineTo(20 * k, 16.5 * k)
          ..lineTo(9 * k, 16.5 * k)
          ..lineTo(4 * k, 20.5 * k)
          ..close(),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(8.5 * k, 10 * k)
          ..lineTo(15.5 * k, 10 * k)
          ..moveTo(8.5 * k, 13 * k)
          ..lineTo(12.5 * k, 13 * k),
        paint,
      );
  }

  @override
  bool shouldRepaint(_FeedbackGlyphPainter old) => old.color != color;
}

/// The day count on the Feedback row. Nothing shows while the count loads;
/// when it arrives it fades in (quick, ease). On wide web the color follows
/// the row's selection.
class FeedbackRowValue extends StatelessWidget {
  const FeedbackRowValue({
    required this.value,
    required this.style,
    this.selectedColor,
    this.selected = false,
    super.key,
  });
  final String? value;
  final TextStyle style;
  final Color? selectedColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    if (value == null) return const SizedBox.shrink();
    final still = MediaQuery.disableAnimationsOf(context);
    final color = selected && selectedColor != null
        ? selectedColor!
        : style.color ?? context.colors.secondaryLabel;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: still ? 1 : 0, end: 1),
      duration: still ? Duration.zero : PantasDurations.quick,
      curve: PantasCurves.ease,
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: color),
        duration: still ? Duration.zero : PantasDurations.quick,
        curve: PantasCurves.ease,
        builder: (context, color, _) =>
            Text(value, style: style.copyWith(color: color)),
      ),
    );
  }
}

/// The phone's Feedback row (FbSettingsB): first in the first card.
class FeedbackSettingsRow extends ConsumerWidget {
  const FeedbackSettingsRow({required this.onTap, super.key});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return ListRow(
      title: 'Feedback',
      titleWidget: Semantics(
        label: 'Feedback, beta',
        excludeSemantics: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Feedback', style: context.type.body),
            const SettingsBetaMark(),
          ],
        ),
      ),
      valueWidget: FeedbackRowValue(
        value: ref.watch(feedbackRowValueProvider),
        style: context.type.rowValue,
      ),
      leading: SizedBox(
        width: 30,
        height: 30,
        child: Center(
          child: SettingsFeedbackGlyph(size: 24, color: c.accent),
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(14, 0, 16, 0),
      minimumHeight: 45,
      // G1: Tester Guide always follows Feedback.
      divider: true,
      dividerInset: 56,
      onTap: onTap,
    );
  }
}

/// Opens the tester guide. Tests replace it.
typedef TesterGuideOpener = Future<bool> Function(Uri uri);

final testerGuideOpenerProvider = Provider<TesterGuideOpener>(
  (ref) => (uri) => launchUrl(uri, webOnlyWindowName: '_blank'),
);

final testerGuideUrl = Uri.parse('https://www.pantas.study/beta/guide');

/// A glyph from the G1 board, drawn from its own 24 unit stroke paths.
class SettingsStrokeGlyph extends StatelessWidget {
  const SettingsStrokeGlyph._(
    this._paths, {
    required this.size,
    required this.color,
    this.strokeWidth = 1.8,
    super.key,
  });

  /// The open book of the Tester Guide row.
  const SettingsStrokeGlyph.guide({
    required double size,
    required Color color,
    Key? key,
  }) : this._(
          '<path d="M4 5.5c3-1 5.5-.5 8 1.5 2.5-2 5-2.5 8-1.5V19c-3-1-5.5-.5-8 '
          '1.5-2.5-2-5-2.5-8-1.5z"/><path d="M12 7v13"/>',
          size: size,
          color: color,
          key: key,
        );

  /// The up-right arrow that stands in for the chevron on a row that leaves
  /// the app.
  const SettingsStrokeGlyph.external({
    required Color color,
    Key? key,
  }) : this._(
          '<path d="M8 16L16 8M9.5 8H16v6.5"/>',
          size: 16,
          color: color,
          strokeWidth: 2.4,
          key: key,
        );

  final String _paths;
  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SvgPicture.string(
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
          'fill="none" stroke="#000" stroke-width="$strokeWidth" '
          'stroke-linecap="round" stroke-linejoin="round">$_paths</svg>',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      );
}

/// G1 (Pantas Design System canvas, "Tester guide after Nov 9"): the guide
/// row under Feedback. It opens the guide in a new tab.
class TesterGuideSettingsRow extends ConsumerWidget {
  const TesterGuideSettingsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return ListRow(
      title: 'Tester Guide',
      leading: SizedBox(
        width: 30,
        height: 30,
        child: Center(
          child: SettingsStrokeGlyph.guide(size: 24, color: c.accent),
        ),
      ),
      trailingWidget: SettingsStrokeGlyph.external(
        key: const ValueKey('tester-guide-arrow'),
        color: c.chevron,
      ),
      contentPadding: const EdgeInsets.fromLTRB(14, 0, 16, 0),
      minimumHeight: 45,
      onTap: () =>
          unawaited(ref.read(testerGuideOpenerProvider)(testerGuideUrl)),
    );
  }
}

class SettingsHomePage extends ConsumerWidget {
  const SettingsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.wideWeb) return const AccountPage();
    final settings =
        ref.watch(userSettingsProvider).valueOrNull ?? UserSettings.defaults();
    final user = ref.watch(currentUserProvider).valueOrNull;
    final anonymous = ref.watch(isAnonymousProvider).valueOrNull ?? true;
    final theme = ref.watch(themePreferenceProvider).valueOrNull ??
        ThemePreference.system;
    final length = ref.watch(settingsSessionLengthProvider).valueOrNull ?? 10;
    final tester = ref.watch(betaFeedbackVisibleProvider);
    void push(String path) {
      final router = GoRouter.maybeOf(context);
      if (router != null) unawaited(router.push<void>(path));
    }

    // ST_RootPro: a 24 px glyph in a 30 px box, 14 px from the card edge and
    // 12 px before the text. The row dividers start at the text (56 px).
    Widget glyph(IconData data, Color color) => SizedBox(
          width: 30,
          height: 30,
          child: Center(child: Icon(data, size: 24, color: color)),
        );
    Widget ownGlyph(Widget icon, Color color) => SizedBox(
          width: 30,
          height: 30,
          child: Center(
            child: IconTheme(
              data: IconThemeData(color: color, size: 24),
              child: icon,
            ),
          ),
        );
    const rowPadding = EdgeInsets.fromLTRB(14, 0, 16, 0);

    return PantasPage(
      title: 'Settings',
      // ST_RootPro: the title and the first card sit 12 and 21 px lower.
      titlePadding: const EdgeInsets.fromLTRB(4, 18, 4, 24),
      bottomInset: 104,
      children: [
        GroupedSection(
          children: [
            ListRow(
              title: settings.name?.trim().isNotEmpty ?? false
                  ? settings.name!
                  : 'Add your name',
              subtitle:
                  anonymous || user == null ? 'Not signed in' : user.email,
              leading: Avatar(
                name: settings.name ?? '',
                photo: user?.photoUrl == null
                    ? null
                    : NetworkImage(user!.photoUrl!),
              ),
              titleWidget: Text(
                settings.name?.trim().isNotEmpty ?? false
                    ? settings.name!
                    : 'Add your name',
                style: context.type.emphasized.copyWith(fontSize: 22),
              ),
              verticalPadding: 14,
              onTap: () => push('/settings/account'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (tester) ...[
          // FbSettingsB: Feedback and the Beta switch share the first card.
          GroupedSection(
            children: [
              FeedbackSettingsRow(
                onTap: () => push('/settings/beta-feedback'),
              ),
              const TesterGuideSettingsRow(),
              const BetaProRow(),
            ],
          ),
          const BetaProNote(),
          const SizedBox(height: 24),
        ],
        GroupedSection(
          children: [
            ListRow(
              title: 'Pantas Pro',
              value: ref.watch(proRowValueProvider),
              leading: glyph(PantasIcons.proSettings, const Color(0xFFD9A400)),
              contentPadding: rowPadding,
              minimumHeight: 45,
              onTap: () => push('/settings/pro'),
            ),
            if (!tester) const BetaProRow(),
          ],
        ),
        if (!tester) const BetaProNote(),
        const SizedBox(height: 24),
        GroupedSection(
          children: [
            ListRow(
              title: 'Your exam',
              value: ref.watch(activeExamShortNameProvider),
              leading: glyph(PantasIcons.exam, context.colors.accent),
              contentPadding: rowPadding,
              minimumHeight: 45,
              divider: true,
              dividerInset: 56,
              onTap: () => push('/settings/exam'),
            ),
            ListRow(
              title: 'Practice',
              value: length < 0 ? 'All questions' : '$length questions',
              leading: glyph(PantasIcons.practice, const Color(0xFF2F6FEB)),
              contentPadding: rowPadding,
              minimumHeight: 45,
              divider: true,
              dividerInset: 56,
              onTap: () => push('/settings/practice'),
            ),
            if (!kIsWeb)
              ListRow(
                title: 'Reminders',
                value: settings.dailyReminderTime == null
                    ? 'Off'
                    : TimeOfDay(
                        hour: settings.dailyReminderTime!.hour,
                        minute: settings.dailyReminderTime!.minute,
                      ).format(context),
                leading: glyph(PantasIcons.reminders, const Color(0xFFE8590C)),
                contentPadding: rowPadding,
                minimumHeight: 45,
                divider: true,
                dividerInset: 56,
                onTap: () => push('/settings/reminders'),
              ),
            ListRow(
              title: 'Appearance',
              value: switch (theme) {
                ThemePreference.light => 'Light',
                ThemePreference.dark => 'Dark',
                ThemePreference.system => 'Automatic'
              },
              leading: ownGlyph(
                const OwnIcon(OwnIconKind.appearance, fill: Color(0xFF1D1D1F)),
                const Color(0xFF5F3DC4),
              ),
              contentPadding: rowPadding,
              minimumHeight: 45,
              onTap: () => push('/settings/appearance'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GroupedSection(
          children: [
            ListRow(
              title: 'About',
              leading: ownGlyph(PantasIcons.about, const Color(0xFF6E6E73)),
              contentPadding: rowPadding,
              minimumHeight: 45,
              onTap: () => push('/settings/about'),
            ),
          ],
        ),
      ],
    );
  }
}
