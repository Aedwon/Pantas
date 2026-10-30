import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
      children: _documentChildren(context, documentId),
    );
  }
}

/// Reading content can also be placed in the settings pane by the app router.
class LegalDocumentBody extends StatelessWidget {
  const LegalDocumentBody({required this.documentId, super.key});
  final String documentId;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _documentChildren(context, documentId),
      );
}

List<Widget> _documentChildren(BuildContext context, String documentId) {
  final document = legalDocumentFallbacks[documentId];
  return [
    if (document == null)
      const StateView(message: 'Legal page not found')
    else ...[
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
