class WrappedPayload {
  const WrappedPayload({
    required this.title,
    required this.slides,
    required this.archetypeId,
    required this.shareId,
  });

  final String title;
  final List<WrappedSlide> slides;
  final String archetypeId;
  final String shareId;
}

class WrappedSlide {
  const WrappedSlide({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
