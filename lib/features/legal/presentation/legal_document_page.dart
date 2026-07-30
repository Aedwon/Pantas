import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/board_button.dart';
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
    final styles = context.textStyles;
    final colors = context.colors;
    final document = legalDocumentFallbacks[documentId];
    if (document == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Legal')),
        body: Center(
          child: Text(
            'Legal page not found',
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text(document.title, style: styles.displaySmall),
          const SizedBox(height: 4),
          Text(
            _updatedLabel(document.updatedAt),
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 24),
          for (final section in document.sections) ...[
            Text(section.heading, style: styles.headlineSmall),
            const SizedBox(height: 8),
            Text(section.body, style: styles.bodyMedium),
            const SizedBox(height: 20),
          ],
          const Divider(),
          const SizedBox(height: 12),
          Text('Data Protection Officer', style: styles.headlineSmall),
          const SizedBox(height: 8),
          Text(contact.dpoEmail, style: styles.bodyMedium),
          if (document.id == 'privacy') ...[
            const SizedBox(height: 16),
            BoardButton(
              label: 'Manage account data',
              secondary: true,
              onPressed: () => _go(context, '/settings/account'),
            ),
          ],
        ],
      ),
    );
  }

  static String _updatedLabel(DateTime updatedAt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return 'Updated ${months[updatedAt.month - 1]} '
        '${updatedAt.day}, ${updatedAt.year}';
  }

  static void _go(BuildContext context, String location) {
    final router = GoRouter.maybeOf(context);
    // Push, never go: these destinations sit outside the tab shell and rely
    // on the AppBar's implicit back arrow, which only appears when the
    // stack can pop.
    if (router != null) unawaited(router.push<void>(location));
  }
}
