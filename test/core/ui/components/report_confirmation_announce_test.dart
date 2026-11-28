// P12: the report confirmation is announced to screen readers. The sent and
// saved-offline lines appear already worded, so a live region alone never
// changes and Flutter web says nothing. Each line is announced once.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/ui/components/report_bar.dart';
import 'package:pantas/core/ui/components/report_form.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const lines = {
    ReportDelivery.sent: "Thank you. We'll take a look.",
    ReportDelivery.saved: "Saved. It sends when you're back online.",
  };

  for (final entry in lines.entries) {
    testWidgets('bar notice announces ${entry.key.name} once', (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpApp(ReportNotice(delivery: entry.key));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        expect(
          tester.takeAnnouncements().map((a) => a.message).toList(),
          [entry.value],
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('wide soft line announces ${entry.key.name} once',
        (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpApp(
          ReportSoftLine(delivery: entry.key, style: const TextStyle()),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        expect(
          tester.takeAnnouncements().map((a) => a.message).toList(),
          [entry.value],
        );
      } finally {
        semantics.dispose();
      }
    });
  }
}
