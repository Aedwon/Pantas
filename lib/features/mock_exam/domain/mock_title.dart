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
