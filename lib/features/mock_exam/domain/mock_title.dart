/// The name every mock screen gives an exam's simulation: the Quiz tab card,
/// setup, the run and the results. [name] is the fallback for an exam with no
/// fixed name here.
String mockSimulationTitle(String examId, String name) => switch (examId) {
      'exam_upcat' => 'UPCAT simulation',
      'exam_dlsucet' => 'DCAT simulation',
      'exam_cse_pro' => 'CSE Professional simulation',
      'exam_cse_sub' => 'CSE Subprofessional simulation',
      'exam_acet' => 'ACET simulation',
      _ => '${name.replaceAll(' Practice Paper', '')} simulation',
    };

/// The title a results screen prints for a finished mock. A result from the
/// server carries only the exam's plain name, so it is run through
/// [mockSimulationTitle]. The unnamed fallback is not a name to build on.
String mockResultsTitle(String examId, String name) =>
    name == 'Mock exam' ? name : mockSimulationTitle(examId, name);

/// Label a blueprint carries in its name when its paper is Pantas-set or
/// built from reports, not the official format.
const String mockPracticeLabel =
    'Pantas practice exam, not the official format';

/// The label to show on setup, or null. Read from the blueprint name, so a
/// blueprint opts in by carrying the label and others stay unchanged.
String? mockPracticeLabelFor(String blueprintName) =>
    blueprintName.contains(mockPracticeLabel) ? mockPracticeLabel : null;
