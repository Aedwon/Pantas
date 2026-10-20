import 'package:flutter/foundation.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';

enum MockFinaleOutcome { correct, wrong, blank }

@immutable
class MockFinaleQuestion {
  const MockFinaleQuestion({required this.id, required this.outcome});
  final String id;
  final MockFinaleOutcome outcome;
}

@immutable
class MockFinalePart {
  MockFinalePart({
    required this.name,
    required List<MockFinaleQuestion> questions,
  }) : questions = List.unmodifiable(questions);
  final String name;
  final List<MockFinaleQuestion> questions;
}

/// A submission-only view snapshot. History never reconstructs this input.
/// Retired questions are omitted; the cursor counts retained questions only.
/// Keep empty original parts. When every question retired, omit the finale.
@immutable
class MockFinaleInput {
  MockFinaleInput({
    required this.reason,
    required this.currentPartIndex,
    required this.currentQuestionIndex,
    required List<MockFinalePart> parts,
  }) : parts = List.unmodifiable(parts);
  final MockSubmitReason reason;
  final int currentPartIndex;
  final int currentQuestionIndex;
  final List<MockFinalePart> parts;
}
