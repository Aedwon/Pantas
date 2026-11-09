import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button_parts.dart';
import 'package:pantas/core/ui/components/pantas_popover.dart';
import 'package:pantas/core/ui/components/pantas_select.dart';
import 'package:pantas/core/ui/components/search_field.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/ds_matrix.dart';

const _options = [
  PantasSelectOption('abra', 'Abra'),
  PantasSelectOption('batangas', 'Batangas'),
  PantasSelectOption('cebu', 'Cebu'),
  PantasSelectOption('davao', 'Davao'),
  PantasSelectOption('ilocos', 'Ilocos Norte'),
  PantasSelectOption('laguna', 'Laguna'),
];

Widget _select({
  String? value,
  ValueChanged<String>? onChanged,
  String? errorText,
  bool large = false,
  bool enabled = true,
  bool searchable = false,
  bool loading = false,
  String? loadingText,
  List<PantasSelectOption<String>> options = _options,
}) =>
    SizedBox(
      width: 340,
      child: PantasSelect<String>(
        searchable: searchable,
        loading: loading,
        loadingText: loadingText,
        label: 'Province',
        placeholder: 'Choose a province',
        options: options,
        value: value,
        onChanged: onChanged ?? (_) {},
        errorText: errorText,
        large: large,
        enabled: enabled,
      ),
    );

void main() {
  setUpAll(loadDsFonts);

  dsMatrix(
    'select: 48 button, ring, placeholder, large is 56',
    (context) => Column(
      children: [
        _select(),
        const SizedBox(height: 8),
        _select(large: true, value: 'cebu'),
      ],
    ),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      final buttons = find.byKey(const ValueKey('select-button'));
      expect(tester.getSize(buttons.first).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(buttons.last).height, greaterThanOrEqualTo(56));
      final placeholder = tester.widget<Text>(find.text('Choose a province'));
      expect(placeholder.style!.color, palette.textSecondary);
      final ring = tester.widget<Container>(buttons.first).foregroundDecoration!
          as BoxDecoration;
      expect((ring.border! as Border).top.color, palette.borderControl);
      expect(ring.borderRadius, BorderRadius.circular(12));
      // The large box has radius 14.
      final large = tester.widget<Container>(buttons.last).foregroundDecoration!
          as BoxDecoration;
      expect(large.borderRadius, BorderRadius.circular(14));
    },
  );

  testWidgets('opens on tap, shows the selected check, picks and closes',
      (tester) async {
    String? picked;
    await pumpDs(
      tester,
      dsCells.first,
      _select(value: 'batangas', onChanged: (v) => picked = v),
    );
    await tester.tap(find.byKey(const ValueKey('select-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('select-list')), findsOneWidget);
    // Open: a 2 px accent ring.
    final ring = tester
        .widget<Container>(find.byKey(const ValueKey('select-button')))
        .foregroundDecoration! as BoxDecoration;
    expect((ring.border! as Border).top.width, 2);
    expect((ring.border! as Border).top.color, PantasColors.light.accent);
    await tester.tap(find.text('Laguna'));
    await tester.pumpAndSettle();
    expect(picked, 'laguna');
    expect(find.byKey(const ValueKey('select-list')), findsNothing);
  });

  testWidgets('keyboard: arrows move, Enter picks, Esc closes', (tester) async {
    String? picked;
    await pumpDs(
      tester,
      dsCells.first,
      _select(value: 'abra', onChanged: (v) => picked = v),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('select-list')), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(picked, 'batangas');
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('select-list')), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('select-list')), findsNothing);
  });

  testWidgets('invalid draws a 2 px danger ring and the message',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      _select(errorText: 'Choose your province.'),
    );
    final ring = tester
        .widget<Container>(find.byKey(const ValueKey('select-button')))
        .foregroundDecoration! as BoxDecoration;
    expect((ring.border! as Border).top.color, PantasColors.light.danger);
    expect((ring.border! as Border).top.width, 2);
    expect(find.text('Choose your province.'), findsOneWidget);
  });

  testWidgets('disabled is a fill well with no ring and does not open',
      (tester) async {
    await pumpDs(tester, dsCells.first, _select(enabled: false));
    final button = tester.widget<Container>(
      find.byKey(const ValueKey('select-button')),
    );
    expect(button.foregroundDecoration, isNull);
    expect(
      (button.decoration! as BoxDecoration).color,
      PantasColors.light.fill,
    );
    await tester.tap(find.byKey(const ValueKey('select-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('select-list')), findsNothing);
  });

  group('search and loading (Select README)', () {
    Future<void> openSearch(WidgetTester tester, {DsCell? cell}) async {
      await pumpDs(
        tester,
        cell ?? dsCells.first,
        _select(searchable: true),
      );
      await tester.tap(find.byKey(const ValueKey('select-button')));
      await tester.pumpAndSettle();
    }

    int visibleOptions(WidgetTester tester) => [
          for (final o in _options)
            if (find
                .descendant(
                  of: find.byKey(const ValueKey('select-list')),
                  matching: find.text(o.label),
                )
                .evaluate()
                .isNotEmpty)
              o,
        ].length;

    Future<void> typeQuery(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pumpAndSettle();
    }

    String? statusText(WidgetTester tester) {
      final node = tester.getSemantics(
        find.byKey(const ValueKey('select-status')),
      );
      return node.label;
    }

    testWidgets('without searchable there is no search field', (tester) async {
      await pumpDs(tester, dsCells.first, _select());
      await tester.tap(find.byKey(const ValueKey('select-button')));
      await tester.pumpAndSettle();
      expect(find.byType(SearchField), findsNothing);
    });

    testWidgets('a search field sits at the top of the list and takes focus',
        (tester) async {
      await openSearch(tester);
      expect(find.byType(SearchField), findsOneWidget);
      final list = tester.getRect(find.byKey(const ValueKey('select-list')));
      final field = tester.getRect(find.byType(SearchField));
      expect(field.top, greaterThanOrEqualTo(list.top));
      expect(field.bottom, lessThan(tester.getRect(find.text('Abra')).top));
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<SearchField>(),
        isNotNull,
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('search-fill'))).height,
        greaterThanOrEqualTo(38),
      );
    });

    testWidgets('the search field shows no Cancel on a phone', (tester) async {
      // The phone width is where SearchField draws its Cancel.
      await openSearch(tester);
      await typeQuery(tester, 'a');
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('typing filters the options', (tester) async {
      await openSearch(tester);
      expect(visibleOptions(tester), 6);
      await typeQuery(tester, 'a');
      // Abra, Batangas, Cebu (no, no a), Davao, Ilocos Norte (no), Laguna.
      expect(find.text('Cebu'), findsNothing);
      expect(find.text('Ilocos Norte'), findsNothing);
      expect(find.text('Abra'), findsOneWidget);
      await typeQuery(tester, 'lag');
      expect(visibleOptions(tester), 1);
      expect(find.text('Laguna'), findsOneWidget);
    });

    testWidgets('matching ignores case', (tester) async {
      await openSearch(tester);
      await typeQuery(tester, 'CEB');
      expect(find.text('Cebu'), findsOneWidget);
      expect(visibleOptions(tester), 1);
    });

    testWidgets('No results shows only when nothing matches', (tester) async {
      await openSearch(tester);
      expect(find.text('No results'), findsNothing);
      await typeQuery(tester, 'zzz');
      expect(find.text('No results'), findsOneWidget);
      expect(find.byType(PantasPopoverEmpty), findsOneWidget);
      expect(visibleOptions(tester), 0);
      await typeQuery(tester, 'ceb');
      expect(find.text('No results'), findsNothing);
    });

    testWidgets('a live region announces the result count', (tester) async {
      await openSearch(tester);
      expect(statusText(tester), '6 results');
      await typeQuery(tester, 'a');
      expect(statusText(tester), '4 results');
      await typeQuery(tester, 'lag');
      expect(statusText(tester), '1 result');
      await typeQuery(tester, 'zzz');
      expect(statusText(tester), 'No results');
    });

    testWidgets('Down and Enter pick from the filtered list', (tester) async {
      String? picked;
      await pumpDs(
        tester,
        dsCells.first,
        _select(searchable: true, onChanged: (v) => picked = v),
      );
      await tester.tap(find.byKey(const ValueKey('select-button')));
      await tester.pumpAndSettle();
      await typeQuery(tester, 'a');
      // Matches: Abra, Batangas, Davao, Laguna. The first is active.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked, 'davao');
      expect(find.byKey(const ValueKey('select-list')), findsNothing);
    });

    testWidgets('Esc closes the list and returns focus to the button',
        (tester) async {
      await openSearch(tester);
      await typeQuery(tester, 'ab');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('select-list')), findsNothing);
      final focus = FocusManager.instance.primaryFocus;
      expect(
        focus?.context?.findAncestorWidgetOfExactType<PantasSelect<String>>(),
        isNotNull,
      );
    });

    testWidgets('Tab closes the list and returns focus to the button',
        (tester) async {
      // Another control follows, so a stray Tab would have somewhere to go.
      await pumpDs(
        tester,
        dsCells.first,
        Column(
          children: [
            _select(searchable: true),
            TextButton(onPressed: () {}, child: const Text('After')),
          ],
        ),
      );
      await tester.tap(find.byKey(const ValueKey('select-button')));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('select-list')), findsNothing);
      final focused = FocusManager.instance.primaryFocus!.context!;
      expect(
        find.descendant(
          of: find.byElementPredicate((e) => e == focused),
          matching: find.byKey(const ValueKey('select-button')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the search starts empty each time the list opens',
        (tester) async {
      await openSearch(tester);
      await typeQuery(tester, 'ceb');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('select-button')));
      await tester.pumpAndSettle();
      expect(visibleOptions(tester), 6);
    });

    testWidgets('loading shows the spinner and the text, not the options',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        dsCells.first,
        _select(
          searchable: true,
          loading: true,
          loadingText: 'Loading provinces',
          options: const [],
        ),
      );
      await tester.tap(find.byKey(const ValueKey('select-button')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(PantasSpinner), findsOneWidget);
      expect(find.text('Loading provinces'), findsOneWidget);
      expect(find.text('No results'), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(statusText(tester), 'Loading provinces');
      handle.dispose();
    });

    testWidgets('loading also opens a plain select with no options yet',
        (tester) async {
      await pumpDs(
        tester,
        dsCells.first,
        _select(
          loading: true,
          loadingText: 'Loading provinces',
          options: const [],
        ),
      );
      await tester.tap(find.byKey(const ValueKey('select-button')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(PantasSpinner), findsOneWidget);
      expect(find.text('Loading provinces'), findsOneWidget);
    });

    testWidgets('typeahead without search still jumps to a match',
        (tester) async {
      String? picked;
      await pumpDs(
        tester,
        dsCells.first,
        _select(value: 'abra', onChanged: (v) => picked = v),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyL, character: 'l');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyL);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked, 'laguna');
    });

    testWidgets('reduced motion: the list appears and disappears at once',
        (tester) async {
      await pumpDs(
        tester,
        dsCells.first,
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: _select(searchable: true),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('select-button')));
      await tester.pump();
      await tester.pump();
      final fade = tester.widget<Opacity>(
        find
            .ancestor(
              of: find.byKey(const ValueKey('select-list')),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(fade.opacity, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byKey(const ValueKey('select-list')), findsNothing);
    });
  });

  dsMatrix(
    'searchable select: open list with a filter and No results fits',
    (context) => _select(searchable: true),
    check: (tester, cell) async {
      await tester.tap(find.byKey(const ValueKey('select-button')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No results'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final list = tester.getRect(find.byKey(const ValueKey('select-list')));
      expect(list.right, lessThanOrEqualTo(cell.width));
    },
  );

  dsMatrix(
    'loading select: spinner row fits',
    (context) => _select(
      loading: true,
      loadingText: 'Loading provinces',
      options: const [],
    ),
    check: (tester, cell) async {
      await tester.tap(find.byKey(const ValueKey('select-button')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.text('Loading provinces'), findsOneWidget);
    },
  );
}
