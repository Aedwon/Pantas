import 'package:cse_cet_reviewer/features/settings/presentation/widgets/settings_row.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({
    required this.version,
    required this.buildNumber,
    required this.dpoEmail,
    required this.physicalAddress,
    super.key,
  });

  final String version;
  final String buildNumber;
  final String dpoEmail;
  final String physicalAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: Icon(Icons.menu_book_outlined, size: 48)),
          const SizedBox(height: 8),
          const Center(child: Text('CSE Reviewer')),
          Center(child: Text('Version $version (build $buildNumber)')),
          const SizedBox(height: 24),
          const Text('LEGAL'),
          SettingsRow(
            title: 'Privacy Policy',
            onTap: () => _go(context, '/legal/privacy'),
          ),
          SettingsRow(
            title: 'Terms of Service',
            onTap: () => _go(context, '/legal/terms'),
          ),
          const SizedBox(height: 16),
          const Text('DATA & PRIVACY'),
          SettingsRow(
            title: 'Contact our DPO',
            subtitle: dpoEmail,
            onTap: () {},
          ),
          const SizedBox(height: 8),
          Text(
            'For data export, correction, or other privacy requests, email '
            'our Data Protection Officer at $dpoEmail. '
            'Controller address: $physicalAddress.',
          ),
        ],
      ),
    );
  }

  static void _go(BuildContext context, String location) {
    final router = GoRouter.maybeOf(context);
    if (router != null) router.go(location);
  }
}
