import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/own/own_icons.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/settings.dart';

final settingsSessionLengthProvider = FutureProvider<int>((ref) async {
  return (await ref.watch(quizPreferencesRepositoryProvider).read())
      .sessionLength;
});

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

/// The phone's Beta Reward row: shown only while a reward is earned and not
/// turned on.
class BetaRewardSettingsRow extends StatelessWidget {
  const BetaRewardSettingsRow({required this.onTap, super.key});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListRow(
        title: 'Beta Reward',
        leading: SizedBox(
          width: PantasSpace.s28,
          height: 30,
          child: Center(
            child: SettingsFeedbackGlyph(
              size: 24,
              color: context.colors.accent,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          PantasSpace.s14,
          PantasSpace.s0,
          PantasSpace.s16,
          PantasSpace.s0,
        ),
        onTap: onTap,
      );
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
    void push(String path) {
      final router = GoRouter.maybeOf(context);
      if (router != null) unawaited(router.push<void>(path));
    }

    // ST_RootPro: a 24 px glyph in a 30 px box, 14 px from the card edge and
    // 12 px before the text. The row dividers start at the text (56 px).
    Widget glyph(IconData data, Color color) => SizedBox(
          width: PantasSpace.s28,
          height: 30,
          child: Center(child: Icon(data, size: 24, color: color)),
        );
    Widget ownGlyph(Widget icon, Color color) => SizedBox(
          width: PantasSpace.s28,
          height: 30,
          child: Center(
            child: IconTheme(
              data: IconThemeData(color: color, size: 24),
              child: icon,
            ),
          ),
        );
    const rowPadding = EdgeInsets.fromLTRB(
      PantasSpace.s14,
      PantasSpace.s0,
      PantasSpace.s16,
      PantasSpace.s0,
    );

    return PantasPage(
      title: 'Settings',
      // ST_RootPro: the title and the first card sit 12 and 21 px lower. The
      // title top is the one shared with Study and Quiz.
      titlePadding: const EdgeInsets.fromLTRB(
        PantasSpace.s4,
        PantasPage.tabTitleTop - PantasSpace.s2,
        PantasSpace.s4,
        PantasSpace.s24,
      ),
      bottomInset: PantasLayout.reserveTabbar,
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
                // Board ST_Root: the name is 22/600.
                style: PantasType.phoneTitle2.copyWith(
                  color: context.colors.label,
                  fontWeight: FontWeight.w600,
                ),
              ),
              verticalPadding: 14,
              onTap: () => push('/settings/account'),
            ),
          ],
        ),
        const SizedBox(height: PantasSpace.s24),
        if (ref.watch(betaRewardRowVisibleProvider)) ...[
          GroupedSection(
            children: [
              BetaRewardSettingsRow(
                onTap: () => push('/settings/beta-feedback'),
              ),
            ],
          ),
          const SizedBox(height: PantasSpace.s24),
        ],
        GroupedSection(
          children: [
            ListRow(
              title: 'Pantas Pro',
              value: ref.watch(proRowValueProvider),
              leading: glyph(PantasIcons.proSettings, context.colors.pro),
              contentPadding: rowPadding,
              onTap: () => push('/settings/pro'),
            ),
          ],
        ),
        const SizedBox(height: PantasSpace.s24),
        GroupedSection(
          children: [
            ListRow(
              title: 'Your exam',
              value: ref.watch(activeExamShortNameProvider),
              leading: glyph(PantasIcons.exam, context.colors.accent),
              contentPadding: rowPadding,
              divider: true,
              dividerInset: 56,
              onTap: () => push('/settings/exam'),
            ),
            ListRow(
              title: 'Practice',
              value: length < 0 ? 'All questions' : '$length questions',
              leading: glyph(PantasIcons.practice, context.colors.accent),
              contentPadding: rowPadding,
              divider: true,
              dividerInset: 56,
              onTap: () => push('/settings/practice'),
            ),
            // Reminders are parked for the native release; the page has no
            // route yet, so the row stays out until it ships.
            ListRow(
              title: 'Appearance',
              value: switch (theme) {
                ThemePreference.light => 'Light',
                ThemePreference.dark => 'Dark',
                ThemePreference.system => 'Automatic'
              },
              leading: ownGlyph(
                OwnIcon(OwnIconKind.appearance, fill: context.colors.label),
                context.colors.textSecondary,
              ),
              contentPadding: rowPadding,
              onTap: () => push('/settings/appearance'),
            ),
          ],
        ),
        const SizedBox(height: PantasSpace.s24),
        GroupedSection(
          children: [
            ListRow(
              title: 'About',
              leading:
                  ownGlyph(PantasIcons.about, context.colors.textSecondary),
              contentPadding: rowPadding,
              onTap: () => push('/settings/about'),
            ),
          ],
        ),
      ],
    );
  }
}
