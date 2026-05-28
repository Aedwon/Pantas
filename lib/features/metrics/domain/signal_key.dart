enum SignalKey {
  timeOfDay('T1'),
  sessionShape('T2'),
  consistency('T3'),
  perQuestionSpeed('P1'),
  mockPacing('P2'),
  mockStamina('P4'),
  flagRevisit('S1'),
  subjectAffinity('U1'),
  testModeDelta('X1'),
  difficultyCalibration('X2'),
  readThenQuiz('D1'),
  retentionShape('D2'),
  coverageBreadth('D3');

  const SignalKey(this.code);

  final String code;
}
