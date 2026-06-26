import 'package:cse_cet_reviewer/core/ui/components/settings_group.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_value_row.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the heading is serif 17 at weight 700, sentence case',
      (tester) async {
    await tester.pumpApp(
      const SettingsGroup(
        title: 'How you practice',
        isFirst: true,
        children: [SettingsValueRow(title: 'Strict mock mode', value: 'Off')],
      ),
    );

    final heading = tester.widget<Text>(find.text('How you practice'));
    expect(heading.style!.fontFamily, 'SourceSerif4');
    expect(heading.style!.fontSize, SettingsGroup.headingSize);
    expect(heading.style!.fontWeight, FontWeight.w700);
    // Sentence case is a copy rule, asserted here so an all-caps heading
    // cannot pass review.
    expect(heading.data, isNot('HOW YOU PRACTICE'));
  });

  testWidgets('the rule under the heading is ink, not rule and not ruleFaint',
      (tester) async {
    await tester.pumpApp(
      const SettingsGroup(
        title: 'You',
        isFirst: true,
        children: [SettingsValueRow(title: 'Name', value: 'Aedwon')],
      ),
    );

    final divider = tester.widget<Container>(
      find.byKey(const Key('settingsGroupRule')),
    );
    final decoration = divider.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.light.ink);
    expect(
        tester.getSize(find.byKey(const Key('settingsGroupRule'))).height, 1);
  });

  testWidgets('a group after the first leads with 24 of space', (tester) async {
    await tester.pumpApp(
      const Column(
        children: [
          SettingsGroup(
            title: 'You',
            isFirst: true,
            children: [SettingsValueRow(title: 'Name', value: 'Aedwon')],
          ),
          SettingsGroup(
            title: 'What you see',
            children: [SettingsValueRow(title: 'Theme', value: 'System')],
          ),
        ],
      ),
    );

    final first = tester.getRect(find.text('You'));
    final second = tester.getRect(find.text('What you see'));
    expect(second.top, greaterThan(first.bottom));
    expect(find.byType(SettingsGroup), findsNWidgets(2));
  });
}
