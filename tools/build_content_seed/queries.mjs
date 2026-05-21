export const queries = {
  exam: '*[_type == "exam" && language == "en"]',
  subject: '*[_type == "subject"]',
  topic: '*[_type == "topic"]',
  question: '*[_type == "question" && language == "en"]',
  lesson: '*[_type == "lesson"]',
  mockExam: '*[_type == "mockExam"]',
  mockBlueprint: '*[_type == "mockBlueprint"]',
  diagnosticSet: '*[_type == "diagnosticSet"]',
};
