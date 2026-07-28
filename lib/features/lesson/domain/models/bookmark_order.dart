/// How the bookmark list is arranged. All four are visible on one row in the
/// sheet rather than hidden behind a picker: Custom is the feature, and nobody
/// finds a feature inside a menu they never open.
enum BookmarkOrder {
  recent('recent', 'Recent'),
  bySubject('by_subject', 'By subject'),
  oldest('oldest', 'Oldest'),
  custom('custom', 'Custom');

  const BookmarkOrder(this.storageValue, this.label);

  final String storageValue;

  /// The word the order control prints. "By subject" replaced "Index", which
  /// implied a lesson ordering that did not exist at the time.
  final String label;

  static const defaultOrder = BookmarkOrder.recent;

  static BookmarkOrder fromStorage(String? raw) {
    for (final order in BookmarkOrder.values) {
      if (order.storageValue == raw) return order;
    }
    return defaultOrder;
  }
}
