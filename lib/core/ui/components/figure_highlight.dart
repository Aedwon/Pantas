/// The reader's shared ease-out curve. The figure highlighting and linked words
/// that once lived here went with the two-column reader (Nov 29, Immersion).
library;

import 'package:flutter/animation.dart';

/// The spec's ease-out for the section line: the CSS ease-out, (0, 0, .58, 1).
/// The design system has no ease-out token.
const ease = Cubic(0, 0, 0.58, 1); // ds-geometry: spec motion table, ease-out
