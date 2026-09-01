abstract interface class CustomTrackProjection {
  Future<void> upsert({required String examId, required String name});

  Future<void> delete(String examId);
}
