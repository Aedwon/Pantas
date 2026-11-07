import 'package:flutter/foundation.dart';

/// Outside the browser there is no user agent, so the platform names the
/// device.
String betaUserAgent() => defaultTargetPlatform.name;
