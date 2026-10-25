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
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/settings/settings.dart';

final settingsSessionLengthProvider = FutureProvider<int>((ref) async {
  return (await ref.watch(quizPreferencesRepositoryProvider).read())
      .sessionLength;
});

class SettingsHomePage extends ConsumerWidget {
  const SettingsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return PantasPage(
      title: 'Settings',
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
              icon: PantasIcons.proSettings,
              iconColor: const Color(0xFFD9A400),
              onTap: () => push('/settings/pro'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GroupedSection(
          children: [
            ListRow(
              title: 'Your exam',
              value: ref.watch(activeExamShortNameProvider),
              icon: PantasIcons.exam,
              divider: true,
              onTap: () => push('/settings/exam'),
            ),
            ListRow(
              title: 'Practice',
              value: length < 0 ? 'All questions' : '$length questions',
              icon: PantasIcons.practice,
              iconColor: const Color(0xFF2F6FEB),
              divider: true,
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
                icon: PantasIcons.reminders,
                iconColor: const Color(0xFFE8590C),
                divider: true,
                onTap: () => push('/settings/reminders'),
              ),
            ListRow(
              title: 'Appearance',
              value: switch (theme) {
                ThemePreference.light => 'Light',
                ThemePreference.dark => 'Dark',
                ThemePreference.system => 'Automatic'
              },
              leading: PantasIcons.appearance,
              onTap: () => push('/settings/appearance'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GroupedSection(
          children: [
            ListRow(
              title: 'About',
              leading: PantasIcons.about,
              onTap: () => push('/settings/about'),
            ),
          ],
        ),
      ],
    );
  }
}
