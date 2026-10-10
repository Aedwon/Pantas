import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/gallery/component_gallery_page.dart';

List<RouteBase> devRoutes({bool includeDebugGallery = true}) {
  if (!kDebugMode || !includeDebugGallery) return const [];
  return [
    GoRoute(
      path: '/settings/_gallery',
      builder: (context, state) => const ComponentGalleryPage(),
    ),
  ];
}
