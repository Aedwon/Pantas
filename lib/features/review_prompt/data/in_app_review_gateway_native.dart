import 'package:in_app_review/in_app_review.dart';
import 'package:pantas/features/review_prompt/domain/app_review_gateway.dart';

/// The real popup, from Play's own review API.
///
/// Play decides whether to draw anything. It has its own quota and it
/// silently does nothing once a student has been asked too often, so this
/// class never promises the popup appeared.
class InAppReviewGateway implements AppReviewGateway {
  InAppReviewGateway({InAppReview? plugin})
      : _plugin = plugin ?? InAppReview.instance;

  final InAppReview _plugin;

  @override
  Future<bool> isAvailable() => _plugin.isAvailable();

  @override
  Future<void> requestReview() => _plugin.requestReview();
}
