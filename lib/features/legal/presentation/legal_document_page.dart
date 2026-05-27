import 'package:cse_cet_reviewer/features/legal/legal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    if (document == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Legal')),
        body: const Center(child: Text('Legal page not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            document.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(_updatedLabel(document.updatedAt)),
          const SizedBox(height: 24),
          for (final section in document.sections) ...[
            Text(
              section.heading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(section.body),
            const SizedBox(height: 20),
          ],
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Data Protection Officer',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(contact.dpoEmail),
          const SizedBox(height: 4),
          Text(contact.physicalAddress),
          if (document.id == 'privacy') ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _go(context, '/settings/account'),
              child: const Text('Manage account data'),
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
    if (router != null) router.go(location);
  }
}
