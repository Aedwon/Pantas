/// The supplied calendar date at local midnight.
DateTime localDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Calendar days from [from] to [to], independent of daylight saving changes.
int localDaysBetween(DateTime from, DateTime to) {
  final fromDay = DateTime.utc(from.year, from.month, from.day);
  final toDay = DateTime.utc(to.year, to.month, to.day);
  return toDay.difference(fromDay).inDays;
}
