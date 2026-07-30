import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/passage.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/answer_reveal.dart';
import 'package:pantas/core/ui/components/answer_row.dart';
import 'package:pantas/core/ui/components/app_error_view.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/bookmark_ribbon.dart';
import 'package:pantas/core/ui/components/contents_glyph.dart';
import 'package:pantas/core/ui/components/data_row_tile.dart';
import 'package:pantas/core/ui/components/empty_state.dart';
import 'package:pantas/core/ui/components/error_banner.dart';
import 'package:pantas/core/ui/components/exam_selection_row.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/ink_checkbox.dart';
import 'package:pantas/core/ui/components/ink_chevron.dart';
import 'package:pantas/core/ui/components/ink_magnifier.dart';
import 'package:pantas/core/ui/components/ink_plate_rule.dart';
import 'package:pantas/core/ui/components/ink_table_row.dart';
import 'package:pantas/core/ui/components/ink_wheel.dart';
import 'package:pantas/core/ui/components/inline_meter.dart';
import 'package:pantas/core/ui/components/nav_glyph.dart';
import 'package:pantas/core/ui/components/page_scaffold.dart';
import 'package:pantas/core/ui/components/passage_card.dart';
import 'package:pantas/core/ui/components/pennant_mark.dart';
import 'package:pantas/core/ui/components/portable_text_renderer.dart';
import 'package:pantas/core/ui/components/progress_rule.dart';
import 'package:pantas/core/ui/components/question_card.dart';
import 'package:pantas/core/ui/components/question_grid_sheet.dart';
import 'package:pantas/core/ui/components/quiz_progress_bar.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/core/ui/components/ruled_panel.dart';
import 'package:pantas/core/ui/components/ruled_section.dart';
import 'package:pantas/core/ui/components/section_header.dart';
import 'package:pantas/core/ui/components/settings_bar.dart';
import 'package:pantas/core/ui/components/settings_group.dart';
import 'package:pantas/core/ui/components/settings_switch.dart';
import 'package:pantas/core/ui/components/settings_value_row.dart';
import 'package:pantas/core/ui/components/stats_band.dart';
import 'package:pantas/core/ui/components/theme_control.dart';
import 'package:pantas/core/ui/theme/theme_preference.dart';

import '../../../helpers/accessibility.dart';

void main() {
  const sampleQuestion = Question(
    id: 'q1',
    version: 1,
    examIds: ['cse'],
    topicId: 't1',
    language: 'en',
    stem: 'Sample Question Stem text for testing text scaling in components',
    choices: [
      Choice(
        id: 'c_a',
        label: 'A',
        text: 'Option A long text description for choice',
        isCorrect: false,
      ),
      Choice(
        id: 'c_b',
        label: 'B',
        text: 'Option B long text description for choice',
        isCorrect: true,
        rationale: 'Long rationale text explaining correct choice',
      ),
    ],
    explanation: 'Detailed explanation text for the question review',
  );

  const sampleExam = Exam(
    id: 'e1',
    code: 'CSE_PROF',
    name: 'Civil Service Examination Professional Level',
    shortName: 'CSE Prof',
    language: 'en',
    isActive: true,
    subjects: [],
  );

  const samplePassage = Passage(
    id: 'pass_1',
    topicId: 't1',
    language: 'en',
    wordCount: 20,
    title: 'Reading Comprehension Passage Title on Philippine History',
    body: 'The history of the Philippines from 1521 to 1898 spans over '
        'three centuries of colonial rule.',
  );

  const sampleEntry = ReviewEntry(
    number: 1,
    question: sampleQuestion,
    isFlagged: false,
    subjectName: 'Numerical Ability',
    label: 'Word Problem on Age and Work Ratios',
    labelIsStem: false,
  );

  group('UI Kit components survival under text scale 2.0', () {
    testWidgets('AnswerReveal survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const SingleChildScrollView(
          child: AnswerReveal(
            question: sampleQuestion,
            chosenChoiceId: 'c_a',
            proIsActive: true,
            nextReviewIntervalDays: 3,
          ),
        ),
      );
    });

    testWidgets('AnswerRow survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        AnswerRow(
          letter: 'A',
          text: 'Long choice text that wraps when text scale is increased '
              'to 200% scale factor',
          onTap: () {},
        ),
      );
    });

    testWidgets('AppErrorView survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const AppErrorView(),
      );
    });

    testWidgets('BoardButton survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        BoardButton(
          label: 'Submit Answer and Proceed to Next Question',
          onPressed: () {},
        ),
      );
    });

    testWidgets('BookmarkRibbon survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        BookmarkRibbon(
          isBookmarked: true,
          onTap: () {},
        ),
      );
    });

    testWidgets('ContentsGlyph survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const ContentsGlyph(),
      );
    });

    testWidgets('DataRowTile survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const DataRowTile(
          title: 'Total Completed Practice Questions Count',
          primaryFigure: '1,248 points',
        ),
      );
    });

    testWidgets('EmptyState survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        EmptyState(
          headline: 'No practice sessions available yet',
          body: 'Select an exam and subtopic to begin your preparation for '
              'the exam.',
          ctaLabel: 'Select Exam Subtopic',
          onCta: () {},
        ),
      );
    });

    testWidgets('ErrorBanner survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        ErrorBanner(
          variant: ErrorBannerVariant.error,
          message: 'Failed to synchronize user data with remote server. '
              'Please check internet connection.',
          actionLabel: 'Retry Sync',
          onAction: () {},
        ),
      );
    });

    testWidgets('ExamSelectionRow survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        ExamSelectionRow(
          exam: sampleExam,
          selected: true,
          onTap: () {},
        ),
      );
    });

    testWidgets('FaintBars survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const FaintBars(),
      );
    });

    testWidgets('InkCheckbox survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const InkCheckbox(state: InkCheckState.on),
      );
    });

    testWidgets('InkChevron survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const InkChevron(pointsDown: true),
      );
    });

    testWidgets('InkMagnifier survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const InkMagnifier(),
      );
    });

    testWidgets('InkPlateRule survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const InkPlateRule(),
      );
    });

    testWidgets('InkTableRow survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        InkTableRow(
          title: 'Numerical Reasoning Ability Practice Drill',
          subtitle: 'Subtopic 3: Ratios, Proportions and Percentages',
          category: 'Mathematics',
          meta: '85 points',
          state: InkRowState.done,
          chevron: InkRowChevron.link,
          onTap: () {},
        ),
      );
    });

    testWidgets('InkWheel survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        SizedBox(
          height: 150,
          child: InkWheel<int>(
            values: const [1, 2, 3, 4, 5],
            selectedIndex: 2,
            onSelected: (_) {},
            labelBuilder: (v) => 'Item $v option label',
          ),
        ),
      );
    });

    testWidgets('InlineMeter survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const InlineMeter(value: 0.75, color: Colors.green),
      );
    });

    testWidgets('NavGlyph survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const NavGlyph(kind: NavGlyphKind.home, fill: 0.5, color: Colors.black),
      );
    });

    testWidgets('a linking row survives 200% text scale', (tester) async {
      // Was NavigationalRow, which is gone: it respelled its title style in
      // full and drew Material's filled chevron. InkTableRow does this job
      // everywhere now, so the coverage follows it.
      await expectSurvivesTextScale(
        tester,
        InkTableRow(
          title: 'General Information & Philippine Constitution',
          subtitle: 'Constitutional Commissions and Rights',
          chevron: InkRowChevron.link,
          onTap: () {},
        ),
      );
    });

    testWidgets('PageScaffold survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const PageScaffold(
          body: Text('Page Scaffold Content Body Text'),
        ),
      );
    });

    testWidgets('PassageCard survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const SingleChildScrollView(
          child: PassageCard(passage: samplePassage),
        ),
      );
    });

    testWidgets('PennantMark survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const PennantMark(isSet: true),
      );
    });

    testWidgets('PortableTextRenderer survives 200% text scale',
        (tester) async {
      await expectSurvivesTextScale(
        tester,
        const SingleChildScrollView(
          child: PortableTextRenderer(
            text: r'Mathematical equation $x^2 + y^2 = z^2$ and explanation '
                'text for exam review.',
          ),
        ),
      );
    });

    testWidgets('ProgressRule survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const ProgressRule(value: 0.6),
      );
    });

    testWidgets('QuestionCard survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        SingleChildScrollView(
          child: QuestionCard(
            question: sampleQuestion,
            onAnswer: (_) {},
          ),
        ),
      );
    });

    testWidgets('QuestionGridSheet survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        QuestionGridSheet(
          cells: List.generate(10, (i) => GridCell(number: i + 1)),
          columns: 5,
          onTap: (_) {},
        ),
      );
    });

    testWidgets('QuizProgressBar survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const QuizProgressBar(current: 5, total: 20),
      );
    });

    testWidgets('ReviewRow survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        SingleChildScrollView(
          child: ReviewRow(
            entry: sampleEntry,
            isExpanded: false,
            proIsActive: true,
            onToggleExpanded: () {},
            onToggleFlag: (_) {},
          ),
        ),
      );
    });

    testWidgets('RuledPanel survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const RuledPanel(
          heading: 'Performance Overview Panel',
          count: '150 points',
          child:
              Text('Content inside ruled panel for practice drill overview.'),
        ),
      );
    });

    testWidgets('RuledSection survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const RuledSection(
          child: Text('Content inside ruled section component'),
        ),
      );
    });

    testWidgets('SectionHeader survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        SectionHeader(
          title: 'Recent Assessment Results and Performance Summary',
          action: 'View All Results',
          onAction: () {},
        ),
      );
    });

    testWidgets('SettingsBar survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const SettingsBar(title: 'Account & Preferences'),
      );
    });

    testWidgets('SettingsGroup survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const SettingsGroup(
          title: 'Practice & Exam Configuration',
          children: [Text('Settings row item content text')],
        ),
      );
    });

    testWidgets('SettingsSwitch survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const SettingsSwitch(value: true),
      );
    });

    testWidgets('SettingsValueRow survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        SettingsValueRow(
          title: 'Daily Practice Reminder Schedule Time',
          value: '08:00 AM Every Morning',
          showChevron: true,
          onTap: () {},
        ),
      );
    });

    testWidgets('StatsBand survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const StatsBand(
          figures: [
            StatFigure(value: '1,250', label: 'Total Questions Answered'),
            StatFigure(value: '88%', label: 'Overall Accuracy Rate'),
            StatFigure(value: '42', label: 'Consecutive Days Streak'),
          ],
        ),
      );
    });

    testWidgets('ThemeControl survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        ThemeControl(
          value: ThemePreference.system,
          onChanged: (_) {},
        ),
      );
    });
  });
}
