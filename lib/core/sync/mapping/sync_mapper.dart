abstract interface class SyncMapper {
  String get name;
}

class PlaceholderSyncMapper implements SyncMapper {
  const PlaceholderSyncMapper(this.name);

  @override
  final String name;
}
