import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
          ? const EdgeInsets.fromLTRB(8, 0, 16, 0)
          : const EdgeInsets.fromLTRB(4, 0, 16, 0),
      titleStyle: context.wideWeb
          ? null
          : context.type.pageTitleCompact.copyWith(height: 1.2),
      titlePadding: context.wideWeb
          ? const EdgeInsets.fromLTRB(4, 0, 4, 20)
          : const EdgeInsets.fromLTRB(4, 6, 4, 6),
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
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final section in document.sections) ...[
              Text(section.heading, style: t.h3),
              const SizedBox(height: 14),
              Text(section.body, style: t.style(17, height: 1.6)),
              const SizedBox(height: 14),
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
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'Updated ${DateFormat.yMMMd().format(document.updatedAt)}',
          style: context.type.body.copyWith(
            fontSize: 16,
            color: context.colors.secondaryLabel,
          ),
        ),
      ),
      const SizedBox(height: 22),
      for (final (index, section) in document.sections.indexed) ...[
        if (index > 0) const SizedBox(height: 22),
        Text(
          section.heading,
          style: context.type.emphasized.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          section.body,
          style: context.type.body.copyWith(
            fontSize: 16,
            height: 1.55,
            letterSpacing: 0,
          ),
        ),
      ],
    ] else ...[
      Text(
        'Updated ${DateFormat.yMMMd().format(document.updatedAt)}',
        style: context.type.footnote,
      ),
      const SizedBox(height: 24),
      for (final section in document.sections) ...[
        Text(section.heading, style: context.type.emphasized),
        const SizedBox(height: 8),
        Text(section.body, style: context.type.body),
        const SizedBox(height: 24),
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
            padding: EdgeInsets.only(left: 10),
            child: WebTopBar(
              leading: PantasLogo(size: 28),
              title: Text(
                'Pantas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 60),
              child: Center(
                child: SizedBox(
                  width: 580,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () =>
                              leavePage(context, fallback: '/onboarding'),
                          // The chevron the onboarding steps draw, so Back
                          // looks the same on a step and on this page.
                          icon: SvgPicture.string(
                            '<svg viewBox="0 0 24 24" fill="none" '
                            'stroke="currentColor" stroke-width="2.2" '
                            'stroke-linecap="round" '
                            'stroke-linejoin="round"> '
                            '<path d="M15 4.5 7.5 12l7.5 7.5"/></svg>',
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              t.colors.accent,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: const Text('Back'),
                          style: TextButton.styleFrom(
                            foregroundColor: t.colors.accent,
                            minimumSize: const Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                            textStyle: t.style(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        documentId == 'privacy'
                            ? 'Privacy Policy'
                            : document?.title ?? 'Legal',
                        style: t
                            .style(36, weight: FontWeight.w700, height: 1.12)
                            .copyWith(letterSpacing: -.864),
                      ),
                      if (LegalDocumentBody.updatedLine(documentId)
                          case final updated?) ...[
                        const SizedBox(height: 8),
                        Text(
                          updated,
                          style: t.style(
                            17,
                            height: 1.45,
                            color: t.colors.secondaryLabel,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
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
