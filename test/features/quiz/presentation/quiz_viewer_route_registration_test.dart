import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/quiz_routes.dart';

void main() {
  test('completed and never-answered flag viewers have real distinct routes',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final paths = container
        .read(Provider(quizRoutes))
        .whereType<GoRoute>()
        .map((route) => route.path);
    expect(paths, contains('/quiz/viewer/:attemptId'));
    expect(paths, contains('/quiz/flagged/:examId/view/:questionId'));
    expect(paths, contains('/quiz/debrief/:attemptId'));
  });
}
