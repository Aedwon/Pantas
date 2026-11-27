// Route /performance.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/presentation/performance_page.dart';

import 'screen_harness.dart';

PerformanceRow _row(
  String id,
  int right,
  int total, {
  String subtext = 'Subject',
}) =>
    PerformanceRow(
      id: id,
      title: id,
      subtext: subtext,
      correct: right,
      answered: total,
      secondsPerQuestion: null,
    );

// The worst case on each tab is the longest real name and a 3 digit count
// (process-improvement, Nov 26). Names are from content/ on main:
// - subject: "Reading Comprehension (English & Filipino)", the longest in
//   content/exams/custom_subject_tiers.json (the longest of the CSE paper's
//   own four sections is "General Information")
// - topic: "Logical & Verbal Reasoning", the longest CSE topic in
//   content/mock/cse-pro.yaml
// - lesson: "Types of Functions (...)", the longest lesson title in the CSE
//   topics' folders under content/lessons
const _longSubject = 'Reading Comprehension (English & Filipino)';
const _longTopic = 'Logical & Verbal Reasoning';
const _longLesson = 'Types of Functions (Linear, Quadratic, Rational, '
    'Absolute Value, Exponential, Logarithmic, Piecewise)';

final _data = PerformanceViewData(
  subjects: [
    _row('Math', 8, 10),
    _row('Science', 3, 9),
    _row(_longSubject, 96, 120),
  ],
  topics: [
    _row('Algebra', 1, 2, subtext: 'Math'),
    _row('Geometry', 1, 4, subtext: 'Math'),
    _row(_longTopic, 96, 120, subtext: _longSubject),
  ],
  lessons: [
    _row('Circles', 1, 3, subtext: 'Geometry'),
    _row(_longLesson, 96, 120, subtext: 'Algebra'),
  ],
  subjectCounts: {'Math': 2, _longSubject: 1},
  lessonLevelAvailable: true,
  parentSubjectIds: {
    'Algebra': 'Math',
    'Geometry': 'Math',
    _longTopic: _longSubject,
    'Circles': 'Math',
    _longLesson: 'Math',
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final (name, level) in [
    ('performance', 0),
    ('performance_topics', 1),
    ('performance_lessons', 2),
  ]) {
    goldenScreen(
      name,
      (tester, width) => pumpScreen(
        tester,
        width,
        scaffolded(
          PerformancePage(
            data: _data,
            pro: true,
            paused: false,
            initialLevel: level,
            onTopic: (_) {},
            onPro: () {},
            onBack: () {},
          ),
        ),
      ),
    );
  }
}
