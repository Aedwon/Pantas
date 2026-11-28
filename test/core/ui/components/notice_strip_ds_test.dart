import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

import '../../../helpers/ds_matrix.dart';

Widget _notice({
  NoticeTone tone = NoticeTone.info,
  bool expanded = true,
  VoidCallback? onClose,
}) =>
    NoticeStrip(
      title: 'Add your exam date',
      detail: 'Pantas plans your weeks backward from the day you sit the exam.',
      expanded: expanded,
      tone: tone,
      onToggle: () {},
      onClose: onClose ?? () {},
      primaryLabel: 'Add Exam Date',
      onPrimary: () {},
      secondaryLabel: 'Later',
      onSecondary: () {},
    );

void main() {
  dsMatrix(
    'Notice expanded fits every width, theme and text scale',
    (context) => _notice(),
    check: (tester, cell) async {
      final colors = tester.element(find.byType(NoticeStrip)).colors;
      final surface = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(NoticeStrip),
              matching: find.byType(Container),
            ),
          )
          .first;
      final box = surface.decoration! as BoxDecoration;
      // Surface `surface-card`, radius `radius-lg`, a 1px `divider` ring.
      expect(box.color, colors.surfaceCard);
      expect(box.borderRadius, BorderRadius.circular(PantasRadius.lg));
      final ring = surface.foregroundDecoration! as BoxDecoration;
      expect(ring.border, Border.all(color: colors.divider));
      expect(PantasBorder.ring, 1);
      // The head is at least 52 high; the dismiss control has a 44 target.
      expect(
        tester.getSize(find.byKey(const ValueKey('notice-row'))).height,
        greaterThanOrEqualTo(52),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('notice-close'))),
        const Size(44, 44),
      );
      final title = tester.widget<Text>(find.text('Add your exam date'));
      expect(title.style!.fontSize, PantasType.webTitleSm.fontSize);
      expect(title.style!.fontWeight, FontWeight.w600);
      // Actions sit at the right end on a wide screen, side by side on the
      // phone, and stack when the text is large.
      final later = tester.getRect(find.text('Later'));
      final add = tester.getRect(find.text('Add Exam Date'));
      if (cell.width >= 1024) {
        expect(add.left, greaterThan(later.right));
        final notice = tester.getRect(find.byType(NoticeStrip));
        expect(notice.right - add.right, lessThan(60));
      } else if (cell.scale == 1) {
        expect(later.left, lessThan(add.left));
      }
    },
  );

  for (final tone in NoticeTone.values) {
    dsMatrix(
      'Notice $tone has its own icon color',
      (context) => _notice(tone: tone),
      check: (tester, cell) async {
        final colors = tester.element(find.byType(NoticeStrip)).colors;
        final icon = tester.widget<Icon>(
          find
              .descendant(
                of: find.byKey(const ValueKey('notice-row')),
                matching: find.byType(Icon),
              )
              .first,
        );
        expect(
          icon.color,
          tone == NoticeTone.warning ? colors.warningText : colors.accent,
        );
        // Tone is never color alone: the icon and the title are always there.
        expect(find.text('Add your exam date'), findsOneWidget);
        expect(icon.icon, isNotNull);
      },
    );
  }

  dsMatrix(
    'Notice collapsed shows the head only',
    (context) => _notice(expanded: false),
    check: (tester, cell) async {
      expect(find.text('Later').hitTestable(), findsNothing);
      expect(
        tester.getSize(find.byType(NoticeStrip)).height,
        tester.getSize(find.byKey(const ValueKey('notice-row'))).height,
      );
    },
  );

  testWidgets('Notice dismiss control is reachable and fires', (tester) async {
    var closed = 0;
    await pumpDs(tester, dsCells.first, _notice(onClose: () => closed++));
    await tester.tap(find.byKey(const ValueKey('notice-close')));
    expect(closed, 1);
  });

  dsMatrix(
    'Questions sheet with its own paused session fits every cell (board A)',
    (context) => Material(
      child: TodayQuestionsSheet(
        title: 'Reviews',
        done: 1,
        total: 11,
        rows: const [],
        startLabel: 'Resume',
        onStart: () {},
        onDiscard: () {},
      ),
    ),
    check: (tester, cell) async {
      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Discard this session'), findsOneWidget);
      expect(find.textContaining('You paused'), findsNothing);
    },
  );

  dsMatrix(
    'Questions sheet while another quiz is paused fits every cell',
    (context) => Material(
      child: TodayQuestionsSheet(
        title: 'Reviews',
        done: 0,
        total: 11,
        rows: const [],
        startLabel: 'Start Reviews',
        onStart: () {},
        blocked: true,
      ),
    ),
    check: (tester, cell) async {
      final colors = tester.element(find.byType(TodayQuestionsSheet)).colors;
      final line = tester.widget<Text>(find.text(pausedQuizBlockLine));
      expect(line.style!.color, colors.textSecondary);
      expect(find.text('Discard this session'), findsNothing);
      expect(
        tester
            .widget<PantasButton>(
              find.widgetWithText(PantasButton, 'Start Reviews'),
            )
            .onPressed,
        isNull,
      );
    },
  );
}
