import 'package:pantas/core/ui/components/notice_strip.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'notice',
    [
      GoldenState(
        'Info, collapsed',
        (_) => NoticeStrip(title: 'Service message', onClose: () {}),
        width: 340,
      ),
      GoldenState(
        'Info, expanded',
        (_) => NoticeStrip(
          title: 'Service message',
          detail: 'Sync is slower than usual today.',
          expanded: true,
          primaryLabel: 'Got It',
          onPrimary: () {},
          secondaryLabel: 'Manage',
          onSecondary: () {},
          onClose: () {},
        ),
        width: 340,
      ),
      GoldenState(
        'Success',
        (_) => NoticeStrip(
          title: 'Saved',
          detail: 'Your plan is up to date.',
          expanded: true,
          tone: NoticeTone.success,
          onClose: () {},
        ),
        width: 340,
      ),
      GoldenState(
        'Warning',
        (_) => NoticeStrip(
          title: 'Check your connection',
          detail: 'We will retry when you are back online.',
          expanded: true,
          tone: NoticeTone.warning,
          onClose: () {},
        ),
        width: 340,
      ),
    ],
    cellWidth: 340,
    columns: 2,
  );
}
