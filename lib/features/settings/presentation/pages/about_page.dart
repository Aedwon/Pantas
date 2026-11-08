import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/build_info.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/legal/application/legal_providers.dart';
import 'package:pantas/features/settings/presentation/feedback_intent.dart';
import 'package:pantas/features/settings/presentation/pages/debug_settings_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_row.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';
import 'package:pantas/features/settings/settings.dart';
import 'package:url_launcher/url_launcher.dart';

const _helpImproveTitle = 'Help improve Pantas by sharing usage data';

class AboutPage extends ConsumerWidget {
  const AboutPage({
    super.key,
    this.debugEnabled = DebugSettingsPage.enabled,
    this.version = '0.1.0',
    this.buildNumber,
    this.opener,
    this.sharedLinksRow,
  });
  final bool debugEnabled;
  final String version;
  final String? buildNumber;
  final LinkOpener? opener;

  /// W4g supplies its account-bound SharedLinksRow here.
  final Widget? sharedLinksRow;

  /// The board's 18 px external-link glyph.
  Widget _externalIcon(BuildContext context) => ExcludeSemantics(
        child: SvgPicture.string(
          '<svg viewBox="0 0 256 256"><path d="M224,104a8,8,0,0,1-16,0V59.32l '
          '-66.33,66.34a8,8,0,0,1-11.32-11.32L196.68,48H152a8,8,0,0,1,0-16h '
          '64a8,8,0,0,1,8,8Zm-40,24a8,8,0,0,0-8,8v72H48V80h72a8,8,0,0,0,0-16H '
          '48A16,16,0,0,0,32,80V208a16,16,0,0,0,16,16H176a16,16,0,0,0,16-16V '
          '136A8,8,0,0,0,184,128Z"/></svg>',
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(
            context.colors.chevron,
            BlendMode.srcIn,
          ),
        ),
      );

  Widget _identity(BuildContext context) => Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.wideWeb
                    ? context.webTokens.colors.accentFill
                    : context.colors.accentFill,
                borderRadius: BorderRadius.circular(PantasRadius.lg),
              ),
              child: Text(
                'P',
                style: PantasType.webH2.copyWith(
                  color: context.wideWeb
                      ? context.webTokens.colors.onAccent
                      : context.colors.onAccent,
                ),
              ),
            ),
          ),
          const SizedBox(width: PantasSpace.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pantas',
                  style: (context.wideWeb
                          ? PantasType.webH3
                          : PantasType.phoneTitle2)
                      .copyWith(color: context.colors.textPrimary),
                ),
                Text(
                  // One format on every width, as the boards draw it.
                  'Version $version (${buildNumber ?? kBuildNumber})',
                  style: context.wideWeb
                      ? context.webTokens.sm
                      : PantasType.phoneExplanation
                          .copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(userSettingsProvider).valueOrNull ?? UserSettings.defaults();
    final contact = ref.watch(legalContactProvider);
    void push(String path) {
      final router = GoRouter.maybeOf(context);
      if (router != null) unawaited(router.push<void>(path));
    }

    return SettingsPanePage(
      section: 'About',
      title: context.wideWeb ? 'About' : '',
      noHeading: true,
      backLabel: 'Settings',
      onBack: () => leavePage(context, fallback: '/settings'),
      children: [
        if (context.wideWeb)
          WebCard(
            padding: const EdgeInsets.all(PantasSpace.s18),
            child: _identity(context),
          )
        else
          // ST_About: a white 18 px card with the 48 px "P" tile.
          Padding(
            padding: const EdgeInsets.only(top: PantasSpace.s6),
            child: Container(
              padding: const EdgeInsets.all(PantasSpace.s18),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(PantasRadius.xl),
              ),
              child: _identity(context),
            ),
          ),
        SizedBox(height: context.wideWeb ? 24 : 21),
        SettingsSection(
          header: 'Legal',
          children: [
            SettingsRow(
              title: 'Privacy Policy',
              divider: true,
              onTap: () => push('/legal/privacy'),
            ),
            SettingsRow(
              title: 'Terms of Service',
              onTap: () => push('/legal/terms'),
            ),
          ],
        ),
        const SizedBox(height: PantasSpace.s24),
        SettingsSection(
          header: 'Your data',
          children: [
            SettingsRow(
              // The copy Aedwon approved on Nov 2, the same as the Terms step.
              title: _helpImproveTitle,
              // The phone row is narrower than the sentence, so it wraps.
              titleWidget: context.wideWeb
                  ? null
                  : Text(
                      _helpImproveTitle,
                      style: context.type.body.copyWith(
                        color: context.colors.label,
                      ),
                    ),
              variant: ListRowVariant.switchControl,
              selected: settings.helpImproveApp,
              divider: true,
              // ST_About: the divider starts at the text.
              dividerInset: context.wideWeb ? 0 : 16,
              onTap: () => unawaited(
                ref
                    .read(settingsActionsProvider)
                    .setHelpImproveApp(enabled: !settings.helpImproveApp),
              ),
            ),
            if (!context.wideWeb && sharedLinksRow != null) sharedLinksRow!,
            SettingsRow(
              title: 'Contact our data protection officer',
              trailingWidget: context.wideWeb ? null : _externalIcon(context),
              onTap: () => unawaited(
                openDpoMail(
                  contact.dpoEmail,
                  open: opener ?? launchUrl,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s16,
                PantasSpace.s0,
                PantasSpace.s16,
                PantasSpace.s12,
              ),
              child: SelectableText(
                contact.dpoEmail,
                style: context.type.footnote,
              ),
            ),
          ],
        ),
        const SizedBox(height: PantasSpace.s24),
        SettingsSection(
          header: 'Get in touch',
          children: [
            SettingsRow(
              title: 'Send feedback',
              value: context.wideWeb ? 'Facebook group ↗' : 'Facebook group',
              variant: ListRowVariant.value,
              trailingWidget: context.wideWeb ? null : _externalIcon(context),
              onTap: () => unawaited(
                openCommunityGroup(
                  contact.communityGroupUrl,
                  open: opener ?? launchUrl,
                ),
              ),
            ),
          ],
        ),
        if (debugEnabled) ...[
          const SizedBox(height: PantasSpace.s24),
          SettingsSection(
            header: 'Debug',
            children: [
              SettingsRow(
                title: 'Debug',
                onTap: () => push('/settings/_debug'),
              ),
              SettingsRow(
                title: 'Component gallery',
                onTap: () => push('/settings/_gallery'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
