import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/legal/legal.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    required this.documentId,
    required this.contact,
    super.key,
  });
  final String documentId;
  final LegalContact contact;
  @override
  Widget build(BuildContext context) {
    final document = legalDocumentFallbacks[documentId];
    return PantasPage(
      title: documentId == 'privacy'
          ? 'Privacy policy'
          : document?.title ?? 'Legal',
      backLabel: 'About',
      onBack: () => Navigator.of(context).maybePop(),
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
