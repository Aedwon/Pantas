/// The Nov 3 motion preview's own curve solver, ported, so a motion is checked
/// against the page Aedwon approved and not against the app's own curve.
double previewBezier(double x1, double y1, double x2, double y2, double t) {
  if (t <= 0) return 0;
  if (t >= 1) return 1;
  var a = 0.0;
  var b = 1.0;
  var m = .5;
  for (var i = 0; i < 48; i++) {
    m = (a + b) / 2;
    final x =
        3 * x1 * m * (1 - m) * (1 - m) + 3 * x2 * m * m * (1 - m) + m * m * m;
    if ((x - t).abs() < 1e-6) break;
    if (x < t) {
      a = m;
    } else {
      b = m;
    }
  }
  return 3 * y1 * m * (1 - m) * (1 - m) + 3 * y2 * m * m * (1 - m) + m * m * m;
}

/// `cubic-bezier(.25,.1,.25,1)`, the preview's `ease`.
double previewEase(double t) => previewBezier(.25, .1, .25, 1, t);

/// `cubic-bezier(.32,.72,0,1)`, the preview's shared ease.
double previewShared(double t) => previewBezier(.32, .72, 0, 1, t);

/// Progress of a phase that runs from [fromMs] to [toMs], at [ms].
double previewPhase(double ms, double fromMs, double toMs) =>
    ((ms - fromMs) / (toMs - fromMs)).clamp(0.0, 1.0);

double previewLerp(double a, double b, double t) => a + (b - a) * t;
