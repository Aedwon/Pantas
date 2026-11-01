import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/icons/own/own_icons.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/widgets/beta_pro_row.dart';
import 'package:pantas/features/settings/settings.dart';

final settingsSessionLengthProvider = FutureProvider<int>((ref) async {
  return (await ref.watch(quizPreferencesRepositoryProvider).read())
      .sessionLength;
});

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
            const BetaProRow(),
          ],
        ),
        const BetaProNote(),
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
