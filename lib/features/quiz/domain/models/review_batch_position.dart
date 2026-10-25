import 'package:meta/meta.dart';

/// Captured from actual stored chunks; retained after terminal metadata
/// cleanup.
@immutable
class ReviewBatchPosition {
  const ReviewBatchPosition({
    required this.batchId,
    required this.userId,
    required this.ordinal,
    required this.total,
  });
  final String batchId;
  final String userId;
  final int ordinal;
  final int total;
}
