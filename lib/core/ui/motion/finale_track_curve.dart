import 'package:flutter/animation.dart';

/// The curve of one stop in a finale track. The finale boards (MK_Finale,
/// MK_FinaleUPCAT) draw a curve per stop, kept as data beside the tracks, so
/// the control points arrive as numbers. This is their one owner; every other
/// curve in the app is a `PantasCurves` token.
Curve finaleTrackCurve(double x1, double y1, double x2, double y2) =>
    Cubic(x1, y1, x2, y2);
