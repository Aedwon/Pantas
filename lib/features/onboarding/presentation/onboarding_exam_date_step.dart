import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/error_banner.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

class OnboardingExamDateStep extends ConsumerStatefulWidget {
  const OnboardingExamDateStep({
    required this.onCompleted,
    this.now,
    super.key,
  });

  final VoidCallback onCompleted;
  final DateTime? now;

  @override
  ConsumerState<OnboardingExamDateStep> createState() =>
      _OnboardingExamDateStepState();
}

class _OnboardingExamDateStepState
    extends ConsumerState<OnboardingExamDateStep> {
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late final DateTime _today = widget.now ?? DateTime.now();
  late final List<int> _years = List.generate(5, (i) => _today.year + i);

  int _selectedDayIndex = 0; // 0 means dash, 1..31
  late int _selectedMonthIndex = _today.month - 1;
  int _selectedYearIndex = 0;

  bool _saving = false;
  String? _errorMessage;

  Future<void> _onContinue() async {
    final year = _years[_selectedYearIndex];
    final month = _selectedMonthIndex + 1;
    final day = _selectedDayIndex == 0 ? null : _selectedDayIndex;

    final ExamDate examDate;
    if (day == null) {
      examDate = ExamDate.inMonth(year: year, month: month);
    } else {
      examDate = ExamDate.onDay(DateTime(year, month, day));
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(settingsRepositoryProvider)
          .updateExamDate(examDate, today: _today);
      widget.onCompleted();
    } on InvalidExamDateException catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Please choose a date in the future.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text('When is your exam?', style: styles.displaySmall),
            const SizedBox(height: 10),
            Text(
              "We'll count down the days on your home screen.",
              style: styles.bodyLarge.copyWith(color: colors.inkMuted),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              ErrorBanner(
                variant: ErrorBannerVariant.error,
                message: _errorMessage!,
              ),
            ],
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      key: const ValueKey('day_picker'),
                      itemExtent: 32,
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedDayIndex,
                      ),
                      onSelectedItemChanged: (i) =>
                          setState(() => _selectedDayIndex = i),
                      children: [
                        // The month-only option. Not an em dash: the project
                        // bans them by name, and a student reading a wheel
                        // should see a word rather than a mark they have to
                        // interpret.
                        Center(
                          child: Text(
                            'Any',
                            style: TextStyle(color: colors.inkMuted),
                          ),
                        ),
                        for (var d = 1; d <= 31; d++) Center(child: Text('$d')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      key: const ValueKey('month_picker'),
                      itemExtent: 32,
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedMonthIndex,
                      ),
                      onSelectedItemChanged: (i) =>
                          setState(() => _selectedMonthIndex = i),
                      children: [
                        for (final m in _months) Center(child: Text(m)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      key: const ValueKey('year_picker'),
                      itemExtent: 32,
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedYearIndex,
                      ),
                      onSelectedItemChanged: (i) =>
                          setState(() => _selectedYearIndex = i),
                      children: [
                        for (final y in _years) Center(child: Text('$y')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BoardButton(
              label: 'Continue',
              onPressed: _saving ? null : _onContinue,
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _saving ? null : widget.onCompleted,
              child: Text(
                "I don't know yet",
                textAlign: TextAlign.center,
                style: styles.bodyMedium.copyWith(color: colors.board),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
