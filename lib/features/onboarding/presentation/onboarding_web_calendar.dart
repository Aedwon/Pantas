import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/time/date_entry_validator.dart';
import 'package:pantas/core/ui/components/date_grid_focus.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/selected_pop.dart';
import 'package:pantas/core/ui/components/typed_date_field.dart';
import 'package:pantas/core/ui/ds.dart';
// ds-raw: calendar day cells with tint and today label
import 'package:pantas/core/ui/raw_controls.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Desktop month and day panels share the existing date value and save path.
///
/// Aedwon overrode the board's wider calendar on Nov 2, 2026: both panels now
/// fit the 580 column that every onboarding step uses.
/// The month panel's width: three month cells and their gaps inside the card
/// (board OB_Date).
const double _monthPanelWidth = 236;

class OnboardingWebCalendar extends StatefulWidget {
  const OnboardingWebCalendar({
    required this.value,
    required this.today,
    required this.onChanged,
    super.key,
  });
  final MonthFirstDate value;
  final DateTime today;
  final ValueChanged<MonthFirstDate> onChanged;

  @override
  State<OnboardingWebCalendar> createState() => _OnboardingWebCalendarState();
}

class _OnboardingWebCalendarState extends State<OnboardingWebCalendar> {
  /// Focus and keys for the day cells, shared with the other wide date grids.
  final DateGridFocus _grid = DateGridFocus();

  @override
  void dispose() {
    _grid.dispose();
    super.dispose();
  }

  /// The last day of the range this calendar shows: the end of next year.
  DateTime get _lastAllowed => DateTime(widget.today.year + 1, 12, 31);

  bool _allowed(int year, int month, int day) => DateEntryValidator.isAllowed(
        DateTime(year, month, day),
        firstAllowed: widget.today,
        lastAllowed: _lastAllowed,
      );

  int? _firstAllowedDay(int year, int month) => DateGridFocus.firstAllowedDay(
        year,
        month,
        firstAllowed: widget.today,
        lastAllowed: _lastAllowed,
      );

  MonthFirstDate get value => widget.value;
  DateTime get today => widget.today;
  ValueChanged<MonthFirstDate> get onChanged => widget.onChanged;
  int _direction = 1;

  /// Months counted from year zero, so a later month is a larger number.
  int _ordinal(MonthFirstDate date) => date.year * 12 + (date.month ?? 0);

  @override
  void didUpdateWidget(OnboardingWebCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = _ordinal(oldWidget.value);
    final after = _ordinal(value);
    if (before != after) _direction = after > before ? 1 : -1;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    String monthName(int year, int month) =>
        DateFormat.MMMM('en_US').format(DateTime(year, month));
    final month = value.month;
    final selected =
        month == null ? null : DateTime(value.year, month, value.day ?? 1);
    final planningStart = selected != null &&
            selected.year == today.year &&
            selected.month == today.month
        ? 'today'
        : selected == null
            ? ''
            : DateFormat('MMMM 1', 'en_US').format(selected);
    // Built from rows, not a GridView, so the panels can size to each other.
    Widget grid(List<Widget> children, int columns) {
      final gap = columns == 7 ? PantasSpace.s4 : PantasSpace.s6;
      // The cells are sized in rem, so they grow with the text.
      final extent = MediaQuery.textScalerOf(context).scale(
        columns == 3 ? PantasSize.monthCell : PantasSize.dateCell,
      );
      return Column(
        children: [
          for (var i = 0; i < children.length; i += columns) ...[
            if (i > 0) SizedBox(height: gap),
            SizedBox(
              height: extent,
              child: Row(
                children: [
                  for (var j = i; j < i + columns; j++) ...[
                    if (j > i) SizedBox(width: gap),
                    Expanded(
                      child: j < children.length
                          ? children[j]
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    }

    Widget choice(
      String label,
      VoidCallback? action, {
      required bool picked,
      bool isToday = false,
      String? semantics,
      FocusNode? focusNode,
      String? name,
    }) {
      final button = TextButton(
        // ds-raw: calendar day cell, tint and today label
        focusNode: focusNode,
        onPressed: action,
        style: TextButton.styleFrom(
          // ds-raw: same button, calendar day cell
          padding: EdgeInsets.zero,
          backgroundColor: picked
              ? t.colors.accentFill
              : semantics == null
                  ? Colors.transparent
                  : t.colors.background,
          foregroundColor: picked
              ? t.colors.onAccent
              : isToday
                  ? t.colors.accent
                  : t.colors.textPrimary,
          disabledForegroundColor: t.disabledText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PantasRadius.md),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isToday)
              Text(
                'Today',
                style: PantasType.webKeyHintSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: picked ? t.colors.onAccent : t.colors.accent,
                ),
              ),
            Text(
              label,
              style:
                  (semantics == null ? PantasType.webBody : PantasType.webSub)
                      .copyWith(
                fontWeight: picked || isToday
                    ? FontWeight.w700
                    : semantics == null
                        ? FontWeight.w400
                        : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
      if (name == null) {
        return Semantics(selected: picked, label: semantics, child: button);
      }
      // A date cell is named in full ("November 28, 2026"), and the chosen
      // one pops (DatePicker, States).
      return Semantics(
        label: name,
        button: true,
        selected: picked,
        enabled: action != null,
        onTap: action,
        excludeSemantics: true,
        child: SelectedPop(
          key: ValueKey('date-cell-pop-$label'),
          selected: picked,
          child: button,
        ),
      );
    }

    // The day panel always draws six week rows.
    Widget monthBody(int year, int monthNumber) {
      final first = DateTime(year, monthNumber).weekday % 7;
      final last = DateTime(year, monthNumber + 1, 0).day;
      // One Tab stop: the chosen day, else the first allowed one.
      final chosenDay = value.year == year &&
              value.month == monthNumber &&
              value.day != null &&
              _allowed(year, monthNumber, value.day!)
          ? value.day
          : null;
      final tabStop = chosenDay ?? _firstAllowedDay(year, monthNumber);
      _grid.setTabStop(tabStop);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                DateFormat('MMMM y', 'en_US')
                    .format(DateTime(year, monthNumber)),
                style:
                    PantasType.webTitleSm.copyWith(color: t.colors.textPrimary),
              ),
              Text('Know the exact day? Optional', style: t.sm),
            ],
          ),
          const SizedBox(height: PantasSpace.s12),
          Row(
            children: [
              for (final d in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'])
                Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: PantasType.webTag
                        .copyWith(color: t.colors.textSecondary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: PantasSpace.s12),
          Semantics(
            label: DateFormat('MMMM y', 'en_US')
                .format(DateTime(year, monthNumber)),
            container: true,
            explicitChildNodes: true,
            child: Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onKeyEvent: (node, event) => _grid.onKey(
                event,
                year: year,
                month: monthNumber,
                firstAllowed: widget.today,
                lastAllowed: _lastAllowed,
              ),
              child: grid(
                [
                  for (var n = 0; n < first; n++) const SizedBox.shrink(),
                  for (var d = 1; d <= last; d++)
                    choice(
                      '$d',
                      !_allowed(year, monthNumber, d)
                          ? null
                          : () => onChanged(
                                MonthFirstDate(
                                  year: year,
                                  month: monthNumber,
                                  day: d,
                                ),
                              ),
                      picked: value.day == d,
                      isToday: DateTime(year, monthNumber, d) == today,
                      focusNode: _grid.nodeFor(d),
                      name: DateFormat('MMMM d, y', 'en_US')
                          .format(DateTime(year, monthNumber, d)),
                    ),
                  for (var n = first + last; n < 42; n++)
                    const SizedBox.shrink(),
                ],
                7,
              ),
            ),
          ),
        ],
      );
    }

    // The panel is as tall as the tallest a month can make it, so its height
    // does not depend on the month or on the placeholder: the cards and
    // buttons below no longer move when a month is picked (7W-3). That is six
    // week rows under a title that wraps above its hint, which only the long
    // month names do. Every month's header is laid out unseen to size it. They
    // are RichText, not Text, so nothing else finds them as content.
    final base = DefaultTextStyle.of(context).style;
    final scaler = MediaQuery.textScalerOf(context);
    Widget ghostText(String text, TextStyle style) => RichText(
          text: TextSpan(text: text, style: base.merge(style)),
          textScaler: scaler,
        );
    Widget ghost(int monthNumber) => Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ghostText(
                    DateFormat('MMMM y', 'en_US')
                        .format(DateTime(today.year + 1, monthNumber)),
                    PantasType.webTitleSm,
                  ),
                  ghostText('Know the exact day? Optional', t.sm),
                ],
              ),
              const SizedBox(height: PantasSpace.s12),
              ghostText('Sun', PantasType.webTag),
              const SizedBox(height: PantasSpace.s12),
              grid([for (var n = 0; n < 42; n++) const SizedBox.shrink()], 7),
            ],
          ),
        );
    Widget panel(Key key, Widget content) => Stack(
          key: key,
          children: [for (var m = 1; m <= 12; m++) ghost(m), content],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The typed field sits with the grid (DatePicker, Placement). A full
        // valid date selects the day; the grid and the field share one rule.
        TypedDateField(
          value: value.month == null || value.day == null
              ? null
              : DateTime(value.year, value.month!, value.day!),
          firstAllowed: today,
          lastAllowed: _lastAllowed,
          onChanged: (date) => onChanged(
            MonthFirstDate(year: date.year, month: date.month, day: date.day),
          ),
        ),
        const SizedBox(height: PantasSpace.s16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _monthPanelWidth,
                child: WebCard(
                  padding: const EdgeInsets.all(PantasSpace.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final year in [today.year, today.year + 1]) ...[
                        Text(
                          '$year',
                          style: PantasType.webChipName
                              .copyWith(color: t.colors.textSecondary),
                        ),
                        const SizedBox(height: PantasSpace.s8),
                        grid(
                          [
                            for (var m = year == today.year
                                    ? ((today.month - 1) ~/ 3) * 3 + 1
                                    : 1;
                                m <= 12;
                                m++)
                              choice(
                                DateFormat('MMM', 'en_US')
                                    .format(DateTime(year, m)),
                                year == today.year && m < today.month
                                    ? null
                                    : () => onChanged(
                                          MonthFirstDate(year: year, month: m),
                                        ),
                                picked: value.year == year && month == m,
                                semantics: '${monthName(year, m)} $year',
                              ),
                          ],
                          3,
                        ),
                        if (year == today.year)
                          const SizedBox(height: PantasSpace.s18),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: PantasSpace.s12),
              Expanded(
                child: WebCard(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s16,
                    PantasSpace.s18,
                    PantasSpace.s16,
                    PantasSpace.s20,
                  ),
                  child: MonthRiseSwitcher(
                    direction: _direction,
                    child: month == null
                        ? panel(
                            const ValueKey('calendar-month-none'),
                            Positioned.fill(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.string(
                                      '<svg viewBox="0 0 24 24" fill="none" '
                                      'stroke="currentColor" '
                                      'stroke-width="1.5" '
                                      'stroke-linecap="round" '
                                      'stroke-linejoin="round"> '
                                      '<rect x="3.5" y="5" width="17" '
                                      'height="15.5" rx="2.5"/> '
                                      '<path d="M3.5 9.5h17M8 3v4M16 3v4"/></svg>',
                                      width: PantasSpace.s40,
                                      height: PantasSpace.s40,
                                      colorFilter: ColorFilter.mode(
                                        t.colors.iconMuted,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(height: PantasSpace.s10),
                                    Text(
                                      'Pick a month first.\n'
                                      'Then add the day here if you know it.',
                                      textAlign: TextAlign.center,
                                      style: PantasType.webSub.copyWith(
                                        color: t.colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : panel(
                            ValueKey('calendar-month-${value.year}-$month'),
                            monthBody(value.year, month),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PantasSpace.s24),
        ConstrainedBox(
          key: const ValueKey('calendar-status'),
          constraints: const BoxConstraints(minHeight: PantasSize.field),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (selected != null) ...[
                if (value.day != null)
                  Text(
                    DateFormat(
                      selected.year == today.year
                          ? 'EEEE, MMMM d'
                          : 'EEEE, MMMM d, y',
                      'en_US',
                    ).format(selected),
                    style: PantasType.webTitleSm
                        .copyWith(color: t.colors.textPrimary),
                  ),
                Text(
                  value.day != null
                      ? selected == today
                          ? 'Today'
                          : '${selected.difference(today).inDays} '
                              'days from today'
                      : "No day yet? We'll plan from $planningStart "
                          'and ask later.',
                  style: t.sub,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
