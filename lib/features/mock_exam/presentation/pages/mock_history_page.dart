import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_attempt.dart';
import 'package:flutter/material.dart';

class MockHistoryPage extends StatefulWidget {
  const MockHistoryPage({
    required this.attempts,
    super.key,
  });

  final List<MockAttempt> attempts;

  @override
  State<MockHistoryPage> createState() => _MockHistoryPageState();
}

class _MockHistoryPageState extends State<MockHistoryPage> {
  var _showAll = false;

  @override
  Widget build(BuildContext context) {
    final attempts = widget.attempts.toList()
      ..sort(
        (a, b) => (b.submittedAt ?? b.updatedAt).compareTo(
          a.submittedAt ?? a.updatedAt,
        ),
      );
    final visible = _showAll ? attempts : attempts.take(10).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Past mocks')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final attempt in visible)
              ListTile(
                title: Text(attempt.id),
                subtitle: Text(
                  '${attempt.scoreRaw ?? 0}/${attempt.scoreTotal ?? 0}',
                ),
              ),
            if (!_showAll && attempts.length > 10)
              AppButton(
                label: 'See all',
                onPressed: () => setState(() => _showAll = true),
              ),
          ],
        ),
      ),
    );
  }
}
