import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:pantas/core/time/date_entry_validator.dart';
import 'package:pantas/core/ui/components/date_grid_focus.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/selected_pop.dart';
import 'package:pantas/core/ui/components/typed_date_field.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';

@immutable
class MonthFirstDate {
  const MonthFirstDate({required this.year, this.month, this.day});
  final int year;
  final int? month;
  final int? day;
}

/// Swaps a keyed child with the date picker's year motion: 320 ms on
/// `riseIn`, drifting 40 px in from [direction] (1 from the right, -1 from
/// the left). The old child leaves at once. The wide calendar reuses it for
/// a month change.
class MonthRiseSwitcher extends StatelessWidget {
  const MonthRiseSwitcher({
    required this.direction,
    required this.child,
    this.switcherKey,
    super.key,
  });
  final int direction;
  final Widget child;
  final Key? switcherKey;
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        key: switcherKey,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : PantasDurations.medium2,
        reverseDuration: Duration.zero,
        transitionBuilder: (child, animation) => AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) {
            final p = PantasCurves.enter.transform(animation.value);
            return Opacity(
              opacity: p,
              child: Transform.translate(
                offset: Offset((1 - p) * PantasSpace.s40 * direction, 0),
                child: child,
              ),
            );
          },
        ),
        child: child,
      );
}

/// The phone exam-date picker (Option A, chosen Nov 10, 2026): one
/// MM/DD/YYYY field with a calendar button at its end, above one month
/// calendar with Previous and Next month buttons.
///
/// The calendar shows when the picker opens. A tap on the field closes it and
/// opens the keyboard; the calendar button closes the keyboard and opens it
/// again. A typed date moves the calendar and a tapped day fills the field.
///
/// The value stays month-first: a month alone is a valid answer, and a day
/// can be added. Picking another month with the buttons, or "Not sure of the
/// day", keeps the month only and drops any day, so the line under the
/// calendar says "No day yet?". The calendar shows
/// the month of [value], or the month of [today] while [value] has none. It
/// starts at the month of [today] and has no end, as the old phone picker had
/// none; the typed field takes the same range. The wide calendar keeps its own
/// end.
class MonthFirstDatePicker extends StatefulWidget {
  const MonthFirstDatePicker({
    required this.value,
    required this.today,
    required this.onChanged,
    this.onUnresolvedChanged,
    super.key,
  });

  /// The onboarding step's picker. It draws the same calendar.
  const MonthFirstDatePicker.onboarding({
    required MonthFirstDate value,
    required DateTime today,
    required ValueChanged<MonthFirstDate> onChanged,
    ValueChanged<bool>? onUnresolvedChanged,
    Key? key,
  }) : this(
          value: value,
          today: today,
          onChanged: onChanged,
          onUnresolvedChanged: onUnresolvedChanged,
          key: key,
        );

  final MonthFirstDate value;
  final DateTime today;
  final ValueChanged<MonthFirstDate> onChanged;

  /// True while the field holds text that is not a valid date (half typed,
  /// not a real date, or before the first allowed day). The screen holds its
  /// Continue or Save button then, so it never saves a date the field
  /// disagrees with.
  final ValueChanged<bool>? onUnresolvedChanged;

  @override
  State<MonthFirstDatePicker> createState() => _MonthFirstDatePickerState();
}

class _MonthFirstDatePickerState extends State<MonthFirstDatePicker> {
  /// Focus and keys for the day cells, shared with the wide date grids.
  final DateGridFocus _grid = DateGridFocus();

  /// The typed field's focus, so the calendar button can drop the keyboard.
  final FocusNode _fieldFocus = FocusNode();

  /// The calendar shows when the step opens.
  bool _calendarOpen = true;

  /// Bumped by "Not sure of the day" to empty the field, half-typed or not.
  int _resetToken = 0;

  @override
  void dispose() {
    _grid.dispose();
    _fieldFocus.dispose();
    super.dispose();
  }

  void _typeMode() {
    if (_calendarOpen) setState(() => _calendarOpen = false);
  }

  void _toggleCalendar() {
    if (_calendarOpen && !_fieldFocus.hasFocus) {
      setState(() => _calendarOpen = false);
      return;
    }
    _fieldFocus.unfocus();
    setState(() => _calendarOpen = true);
  }

  MonthFirstDate get value => widget.value;
  DateTime get today => DateUtils.dateOnly(widget.today);
  ValueChanged<MonthFirstDate> get onChanged => widget.onChanged;

  /// Months counted from year zero, so a later month is a larger number.
  static int _ordinal(int year, int month) => year * 12 + month - 1;

  int get _firstOrdinal => _ordinal(today.year, today.month);

  /// The month on show, held inside the allowed range.
  int get _viewOrdinal {
    final month = value.month;
    final shown = month == null ? _firstOrdinal : _ordinal(value.year, month);
    return shown < _firstOrdinal ? _firstOrdinal : shown;
  }

  void _go(int ordinal) => onChanged(
        MonthFirstDate(
          year: ordinal ~/ DateTime.monthsPerYear,
          month: ordinal % DateTime.monthsPerYear + 1,
        ),
      );

  bool _allowed(DateTime day) => DateEntryValidator.isAllowed(
        day,
        firstAllowed: today,
      );

  /// One row of seven columns with the grid's gap.
  Widget _week(List<Widget> cells, {double? height}) {
    final row = Row(
      children: [
        for (var i = 0; i < cells.length; i++) ...[
          if (i > 0) const SizedBox(width: PantasSpace.s4),
          Expanded(child: cells[i]),
        ],
      ],
    );
    return height == null ? row : SizedBox(height: height, child: row);
  }

  /// "Sun" to "Sat", or one letter each when any of the seven would not fit
  /// its column (large text).
  Widget _weekdays(BuildContext context, double width) {
    final c = context.colors;
    const gaps = (DateTime.daysPerWeek - 1) * PantasSpace.s4;
    final column = (width - gaps) / DateTime.daysPerWeek;
    final names = [
      for (var d = 0; d < DateTime.daysPerWeek; d++)
        DateFormat('EEE', 'en_US').format(DateTime(2026, 11, 1 + d)),
    ];
    final style = DefaultTextStyle.of(context)
        .style
        .merge(PantasType.webKeyHintSm.copyWith(color: c.textSecondary));
    final scaler = MediaQuery.textScalerOf(context);
    final fits = names.every((name) {
      final painter = TextPainter(
        text: TextSpan(text: name, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final ok = painter.width <= column;
      painter.dispose();
      return ok;
    });
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(bottom: PantasSpace.s4),
        child: _week([
          for (final name in names)
            Text(
              fits ? name : name.substring(0, 1),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: style,
            ),
        ]),
      ),
    );
  }

  Widget _cell(BuildContext context, DateTime date) {
    final c = context.colors;
    final allowed = _allowed(date);
    final selected = value.day == date.day &&
        value.month == date.month &&
        value.year == date.year;
    final isToday = date == today;
    final still = MediaQuery.disableAnimationsOf(context);
    final radius = BorderRadius.circular(PantasRadius.md);
    final color = !allowed
        ? c.textSecondary
        : selected
            ? c.onAccent
            : isToday
                ? c.accent
                : c.textPrimary;
    final weight = selected || isToday
        ? FontWeight.w700
        : allowed
            ? FontWeight.w500
            : FontWeight.w400;
    final button = TextButton(
      key: ValueKey('date-day-${date.day}'),
      focusNode: _grid.nodeFor(date.day),
      onPressed: allowed
          ? () => onChanged(
                MonthFirstDate(
                  year: date.year,
                  month: date.month,
                  day: date.day,
                ),
              )
          : null,
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: const WidgetStatePropertyAll(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        animationDuration: still ? Duration.zero : PantasDurations.short2,
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => selected
              ? c.accentFill
              : states.contains(WidgetState.hovered) &&
                      !states.contains(WidgetState.disabled)
                  ? c.surfaceHover
                  : Colors.transparent,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      child: Text(
        '${date.day}',
        style: PantasType.webNav.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          fontWeight: weight,
          color: color,
        ),
      ),
    );
    return Semantics(
      label: DateFormat('MMMM d, y', 'en_US').format(date),
      hint: isToday ? 'Today' : null,
      button: true,
      selected: selected,
      enabled: allowed,
      onTap: allowed ? button.onPressed : null,
      excludeSemantics: true,
      child: SelectedPop(
        key: ValueKey('date-cell-pop-${date.day}'),
        selected: selected,
        child: OffsetFocusRing(
          borderRadius: radius,
          color: selected ? c.textPrimary : null,
          child: SizedBox.expand(child: button),
        ),
      ),
    );
  }

  Widget _grid7(BuildContext context, int year, int month) {
    final monthName =
        DateFormat('MMMM y', 'en_US').format(DateTime(year, month));
    final first = DateTime(year, month).weekday % DateTime.daysPerWeek;
    final last = DateTime(year, month + 1, 0).day;
    final extent = MediaQuery.textScalerOf(context).scale(PantasSize.dateCell);
    // One Tab stop: the chosen day, else the first allowed one.
    final chosen = value.year == year &&
            value.month == month &&
            value.day != null &&
            _allowed(DateTime(year, month, value.day!))
        ? value.day
        : null;
    _grid.setTabStop(
      chosen ??
          DateGridFocus.firstAllowedDay(
            year,
            month,
            firstAllowed: today,
          ),
    );
    final cells = <Widget>[
      for (var n = 0; n < first; n++) const SizedBox.shrink(),
      for (var d = 1; d <= last; d++) _cell(context, DateTime(year, month, d)),
    ];
    while (cells.length % DateTime.daysPerWeek != 0) {
      cells.add(const SizedBox.shrink());
    }
    return LayoutBuilder(
      builder: (context, box) => Semantics(
        label: monthName,
        container: true,
        explicitChildNodes: true,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: (node, event) => _grid.onKey(
            event,
            year: year,
            month: month,
            firstAllowed: today,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _weekdays(context, box.maxWidth),
              for (var i = 0; i < cells.length; i += DateTime.daysPerWeek) ...[
                if (i > 0) const SizedBox(height: PantasSpace.s4),
                _week(
                  cells.sublist(i, i + DateTime.daysPerWeek),
                  height: extent,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final view = _viewOrdinal;
    final year = view ~/ DateTime.monthsPerYear;
    final month = view % DateTime.monthsPerYear + 1;
    final monthName =
        DateFormat('MMMM y', 'en_US').format(DateTime(year, month));
    final picked = value.month == null
        ? null
        : value.day == null
            ? null
            : DateTime(value.year, value.month!, value.day!);
    final typed = TypedDateField(
      label: 'Exam date',
      value: picked,
      firstAllowed: today,
      focusNode: _fieldFocus,
      showHelp: false,
      liveErrors: true,
      resetToken: _resetToken,
      onFieldPointer: _typeMode,
      onUnresolvedChanged: widget.onUnresolvedChanged,
      action: MergeSemantics(
        child: Semantics(
          expanded: _calendarOpen,
          child: PantasIconButton(
            tooltip: 'Choose a date',
            glyph: PantasIcons.calendarBlank,
            size: PantasIconButtonSize.sm,
            accent: _calendarOpen,
            onPressed: _toggleCalendar,
          ),
        ),
      ),
      onChanged: (date) => onChanged(
        MonthFirstDate(year: date.year, month: date.month, day: date.day),
      ),
    );
    final planningStart = year == today.year && month == today.month
        ? 'today'
        : '1 ${DateFormat('MMMM', 'en_US').format(DateTime(year, month))}';
    final line = value.month == null
        ? null
        : picked == null
            ? "No day yet? We'll plan from $planningStart and ask later."
            : null;
    final calendar = <Widget>[
      const SizedBox(height: PantasSpace.s16),
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: PantasSpace.s8,
        runSpacing: PantasSpace.s8,
        children: [
          Semantics(
            header: true,
            child: Text(
              monthName,
              style: PantasType.phoneTitle2.copyWith(color: c.textPrimary),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PantasIconButton(
                tooltip: 'Previous month',
                glyph: PantasIcons.back,
                onPressed: view <= _firstOrdinal ? null : () => _go(view - 1),
              ),
              PantasIconButton(
                tooltip: 'Next month',
                glyph: PantasIcons.next,
                accent: true,
                onPressed: () => _go(view + 1),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: PantasSpace.s16),
      _grid7(context, year, month),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: WebTextLink(
          label: 'Not sure of the day',
          arrow: false,
          onPressed: () {
            setState(() => _resetToken++);
            onChanged(MonthFirstDate(year: year, month: month));
          },
        ),
      ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        typed,
        if (_calendarOpen) ...calendar,
        if (line != null) ...[
          const SizedBox(height: PantasSpace.s16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s4),
            child: Semantics(
              liveRegion: true,
              child: Text(
                line,
                style: PantasType.phoneFootnote.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
