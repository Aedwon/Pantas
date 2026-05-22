enum SyncApplyAction {
  upsert,
  delete,
  adoptTimestamp,
  ignore,
}

SyncApplyAction resolveIncomingChange({
  required DateTime? incomingUpdatedAt,
  required DateTime? localUpdatedAt,
  required bool isEcho,
  required bool hasPendingUpsert,
  required bool isDelete,
}) {
  if (isDelete) {
    return hasPendingUpsert ? SyncApplyAction.ignore : SyncApplyAction.delete;
  }

  if (isEcho) return SyncApplyAction.adoptTimestamp;

  if (localUpdatedAt == null) return SyncApplyAction.upsert;
  if (incomingUpdatedAt == null) return SyncApplyAction.ignore;

  return incomingUpdatedAt.isAfter(localUpdatedAt)
      ? SyncApplyAction.upsert
      : SyncApplyAction.ignore;
}
