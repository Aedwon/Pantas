import 'package:intl/intl.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/legal/legal.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    required this.documentId,
    required this.contact,
    this.backLabel = 'About',
    this.backFallback = '/settings/about',
    super.key,
  });
  final String documentId;
  final LegalContact contact;

  /// 'Back' during onboarding, where the student did not come from About.
  final String backLabel;

  /// Where Back goes when the page was opened directly and has nothing to
  /// pop to.
  final String backFallback;
  @override
  Widget build(BuildContext context) {
    final document = legalDocumentFallbacks[documentId];
    return PantasPage(
      title: documentId == 'privacy'
          ? 'Privacy Policy'
          : document?.title ?? 'Legal',
      backLabel: backLabel,
      onBack: () => leavePage(context, fallback: backFallback),
      // ST_Privacy: a 28 px title 6 px above the updated line.
      backPadding: context.wideWeb
          ? const EdgeInsets.fromLTRB(
              PantasSpace.s8,
              PantasSpace.s0,
              PantasSpace.s16,
              PantasSpace.s0,
            )
          : const EdgeInsets.fromLTRB(
              PantasSpace.s4,
              PantasSpace.s0,
              PantasSpace.s16,
              PantasSpace.s0,
            ),
      titleStyle: context.wideWeb
          ? null
          : context.type.pageTitleCompact.copyWith(height: 1.2),
      titlePadding: context.wideWeb
          ? const EdgeInsets.fromLTRB(
              PantasSpace.s4,
              PantasSpace.s0,
              PantasSpace.s4,
              PantasSpace.s20,
            )
          : const EdgeInsets.fromLTRB(
              PantasSpace.s4,
              PantasSpace.s6,
              PantasSpace.s4,
              PantasSpace.s6,
            ),
      children: _documentChildren(context, documentId, phone: !context.wideWeb),
    );
  }
}

/// Reading content can also be placed in the settings pane by the app router.
class LegalDocumentBody extends StatelessWidget {
  const LegalDocumentBody({required this.documentId, super.key});
  final String documentId;

  /// The line under the page title on wide web: "Updated Aug 3, 2026".
  static String? updatedLine(String documentId) {
    final document = legalDocumentFallbacks[documentId];
    return document == null
        ? null
        : 'Updated ${DateFormat.yMMMd().format(document.updatedAt)}';
  }

  @override
  Widget build(BuildContext context) {
    final document = legalDocumentFallbacks[documentId];
    if (context.wideWeb && document != null) {
      // Board `.card`: 28 px above, 32 px each side, 16 px below; 20 px
      // headings and 17 px text, 14 px apart.
      final t = context.webTokens;
      return WebCard(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s32,
          PantasSpace.s28,
          PantasSpace.s32,
          PantasSpace.s16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final section in document.sections) ...[
              Text(section.heading, style: t.h3),
              const SizedBox(height: PantasSpace.s14),
              Text(
                section.body,
                style: PantasType.webLead.copyWith(color: t.colors.textPrimary),
              ),
              const SizedBox(height: PantasSpace.s14),
            ],
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _documentChildren(context, documentId),
    );
  }
}

List<Widget> _documentChildren(
  BuildContext context,
  String documentId, {
  bool phone = false,
}) {
  final document = legalDocumentFallbacks[documentId];
  return [
    if (document == null)
      const StateView(message: 'Legal page not found')
    else if (phone) ...[
      // ST_Privacy: a 16 px updated line, 17 px headings, 26 px body lines.
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s4),
        child: Text(
          'Updated ${DateFormat.yMMMd().format(document.updatedAt)}',
          style: PantasType.phoneCallout
              .copyWith(color: context.colors.textSecondary),
        ),
      ),
      const SizedBox(height: PantasSpace.s20),
      for (final (index, section) in document.sections.indexed) ...[
        if (index > 0) const SizedBox(height: PantasSpace.s20),
        Text(
          section.heading,
          style: PantasType.phoneHeadline
              .copyWith(color: context.colors.textPrimary),
        ),
        const SizedBox(height: PantasSpace.s4),
        Text(
          section.body,
          style: PantasType.phoneReaderBody
              .copyWith(color: context.colors.textPrimary),
        ),
      ],
    ] else ...[
      Text(
        'Updated ${DateFormat.yMMMd().format(document.updatedAt)}',
        style: context.type.footnote,
      ),
      const SizedBox(height: PantasSpace.s24),
      for (final section in document.sections) ...[
        Text(section.heading, style: context.type.emphasized),
        const SizedBox(height: PantasSpace.s8),
        Text(section.body, style: context.type.body),
        const SizedBox(height: PantasSpace.s24),
      ],
    ],
  ];
}

/// Wide web: a legal page opened during onboarding. It has the onboarding top
/// bar and column, with Back and no main navigation around it.
class OnboardingLegalPage extends StatelessWidget {
  const OnboardingLegalPage({required this.documentId, super.key});
  final String documentId;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final document = legalDocumentFallbacks[documentId];
    return Material(
      color: t.colors.background,
      child: Column(
        children: [
          // The same 10 px logo inset as the onboarding frame's bar.
          const Padding(
            padding: EdgeInsets.only(left: PantasSpace.s10),
            child: WebTopBar(
              leading: PantasLogo(size: 28),
              title: Text(
                'Pantas',
                style: PantasType.webH3,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s40,
                PantasSpace.s40,
                PantasSpace.s40,
                PantasSpace.s56,
              ),
              child: Center(
                child: SizedBox(
                  width: PantasLayout.qcolNarrow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: WebBackLink(
                          label: 'Back',
                          onPressed: () =>
                              leavePage(context, fallback: '/onboarding'),
                        ),
                      ),
                      const SizedBox(height: PantasSpace.s28),
                      Text(
                        documentId == 'privacy'
                            ? 'Privacy Policy'
                            : document?.title ?? 'Legal',
                        style: PantasType.webH1
                            .copyWith(color: t.colors.textPrimary),
                      ),
                      if (LegalDocumentBody.updatedLine(documentId)
                          case final updated?) ...[
                        const SizedBox(height: PantasSpace.s8),
                        Text(
                          updated,
                          style: PantasType.webLead
                              .copyWith(color: t.colors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: PantasSpace.s28),
                      LegalDocumentBody(documentId: documentId),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
