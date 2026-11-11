import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/features/wrapped/application/wrapped_providers.dart';
import 'package:pantas/features/wrapped/data/user_metrics_artifact_repository.dart';
import 'package:pantas/features/wrapped/domain/wrapped_payload.dart';
import 'package:pantas/features/wrapped/presentation/my_shared_cards_page.dart';
import 'package:pantas/features/wrapped/presentation/share_privacy_sheet.dart';
import 'package:pantas/features/wrapped/presentation/wrapped_reveal_page.dart';
import 'package:pantas/features/wrapped/rendering/wrapped_share_card.dart';

import '../../helpers/ds_matrix.dart';

const _payload = WrappedPayload(
  title: 'Mock 3 - Personal Best',
  slides: [WrappedSlide(title: 'Score', body: 'You beat your best.')],
  archetypeId: 'game_day_player',
  shareId: 'share_1',
);

final _entry = UserMetricsArtifactEntry(
  userId: 'user_1',
  examId: 'exam_cse',
  artifactId: 'artifact_1',
  payload: _payload,
  firedAt: DateTime(2026, 6, 10),
);

final _card = HostedWrappedCard(
  userId: 'user_1',
  examId: 'exam_cse',
  artifactId: 'artifact_1',
  shareId: 'abc123',
  archetypeId: 'game_day_player',
  title: 'Day 7 Streak',
  sharedAt: DateTime(2026, 6, 10),
);

void main() {
  setUpAll(loadDsFonts);

  dsMatrix(
    'share card is the share gradient, hero start to share end',
    (context) => const SizedBox(
      width: 300,
      child: WrappedShareCard(payload: _payload, includeArchetype: true),
    ),
    check: (tester, cell) async {
      final boxes = tester.widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(WrappedShareCard),
          matching: find.byType(DecoratedBox),
        ),
      );
      final gradient = boxes
          .map((box) => (box.decoration as BoxDecoration).gradient)
          .whereType<LinearGradient>()
          .single;
      // The card never follows the reader's theme.
      expect(gradient.colors, [
        PantasColors.light.heroStart,
        PantasColors.light.shareEnd,
      ]);
    },
  );

  dsMatrix(
    'share privacy sheet',
    (context) => SharePrivacySheet(
      selection: const SharePrivacySelection(
        includeArchetype: false,
        includeScore: false,
      ),
      onChanged: (_) {},
    ),
  );

  dsMatrix(
    'wrapped reveal page',
    (context) => ProviderScope(
      overrides: [
        wrappedArtifactProvider.overrideWith((ref, id) async => _entry),
      ],
      child: const SizedBox(
        height: 800,
        child: WrappedRevealPage(artifactId: 'artifact_1'),
      ),
    ),
    scroll: false,
    check: (tester, cell) async {
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(find.text('Share PNG'), findsOneWidget);
    },
  );

  dsMatrix(
    'my shared cards page',
    (context) => ProviderScope(
      overrides: [
        sharedWrappedCardsProvider.overrideWith((ref) async => [_card]),
      ],
      child: const SizedBox(height: 800, child: MySharedCardsPage()),
    ),
    scroll: false,
    check: (tester, cell) async {
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(find.text('Revoke'), findsOneWidget);
    },
  );
}
