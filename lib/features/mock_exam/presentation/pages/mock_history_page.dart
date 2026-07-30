import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/ink_table_row.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          for (final attempt in visible)
            InkTableRow(
              title: attempt.id,
              meta: '${attempt.scoreRaw ?? 0}/${attempt.scoreTotal ?? 0}',
            ),
          if (!_showAll && attempts.length > 10) ...[
            const SizedBox(height: 16),
            BoardButton(
              label: 'See all',
              secondary: true,
              onPressed: () => setState(() => _showAll = true),
            ),
          ],
        ],
      ),
    );
  }
}
