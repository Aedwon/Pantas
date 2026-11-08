import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/figures/figure_registry.dart';
import 'package:pantas/core/ui/gallery/component_gallery_page.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/web/web_page_heading.dart';
import 'package:pantas/features/notifications/presentation/permission_rationale_page.dart';

import '../../helpers/ds_matrix.dart';

const _bondTypes = <String, Object?>{
  'kind': 'chemistry-diagram',
  'type': 'bond-types',
  'illustrationKey': 'science/chemistry/chemical-bonding#1',
  'bondTypes': <Object?>[
    <String, Object?>{
      'label': 'ionic',
      'participants': <String>['metal', 'nonmetal'],
      'electronAction': 'transfer',
      'result': 'positive and negative ions',
    },
    <String, Object?>{
      'label': 'covalent',
      'participants': <String>['nonmetal', 'nonmetal'],
      'electronAction': 'share a pair of electrons',
    },
    <String, Object?>{
      'label': 'metallic',
      'participants': <String>['metal atoms'],
      'electronAction': 'sea of free-moving electrons',
    },
  ],
};

const _series = <String, Object?>{
  'kind': 'figure-series',
  'items': <Object?>[
    <String, Object?>{'form': 'square', 'line': 0},
    <String, Object?>{'form': 'square', 'line': 45},
    <String, Object?>{'form': 'square', 'line': 90},
  ],
  'blank': true,
};

final _drawing = find.byWidgetPredicate(
  (widget) => widget is CustomPaint && widget.painter != null,
);

void main() {
  setUpAll(loadDsFonts);

  dsMatrix(
    'chemistry bond types figure keeps its 210 drawing height',
    (context) => SizedBox(
      width: 340,
      child: FigureRegistry.build(_bondTypes),
    ),
    check: (tester, cell) async {
      expect(
        tester.getSize(_drawing.first).height,
        210,
      );
    },
  );

  dsMatrix(
    'figure series keeps its 110 drawing height',
    (context) => SizedBox(
      width: 340,
      child: FigureRegistry.build(_series),
    ),
    check: (tester, cell) async {
      expect(tester.getSize(_drawing.first).height, 110);
    },
  );

  dsMatrix(
    'web page heading',
    (context) => SizedBox(
      width: 600,
      child: WebPageHeading(
        title: 'Your record',
        subtitle: 'Since you started',
        onBack: () {},
      ),
    ),
  );

  dsMatrix(
    'save failure line',
    (context) => SizedBox(
      width: 340,
      child: saveFailureLine(() {}),
    ),
    check: (tester, cell) async {
      final retry = find.text('Try Again');
      expect(retry, findsOneWidget);
      final size = tester.getSize(
        find.ancestor(of: retry, matching: find.byType(Material)).first,
      );
      expect(size.height, greaterThanOrEqualTo(PantasSize.btn));
    },
  );

  dsMatrix(
    'pantas page',
    (context) => SizedBox(
      height: 800,
      child: PantasPage(
        title: 'Title',
        backLabel: 'Home',
        onBack: () {},
        children: const [Text('Body')],
      ),
    ),
    scroll: false,
  );

  dsMatrix(
    'notification permission rationale',
    (context) => const ProviderScope(
      child: SizedBox(
        height: 800,
        child: PermissionRationalePage(),
      ),
    ),
    scroll: false,
    check: (tester, cell) async {
      expect(find.text('Sounds good'), findsOneWidget);
      expect(find.text('Not right now'), findsOneWidget);
    },
  );

  dsMatrix(
    'component gallery',
    (context) => const SizedBox(height: 800, child: ComponentGalleryPage()),
    scroll: false,
  );
}
