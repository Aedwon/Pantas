import 'package:pantas/features/review_prompt/domain/app_review_gateway.dart';

class InAppReviewGateway implements AppReviewGateway {
  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<void> requestReview() async {}
}
