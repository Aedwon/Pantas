import 'package:flutter/animation.dart';

/// The reader's shared ease, from the approved motion board (item 5). A curve
/// by name lives here, in the motion folder, because the design lint allows
/// raw curves only where motion is defined.
const Curve readerEaseOut = Curves.easeOutCubic;

/// The ease the reader uses on the way back.
const Curve readerEaseIn = Curves.easeInCubic;
