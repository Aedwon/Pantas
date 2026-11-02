/// The two exams the tool reviews, by the code the content files use.
const examCodes = ['cse-pro', 'cse-sub'];

const examLabels = {'cse-pro': 'CSE Pro', 'cse-sub': 'CSE Subpro'};

/// The app's id for an exam code.
String examIdFor(String code) => 'exam_${code.replaceAll('-', '_')}';
