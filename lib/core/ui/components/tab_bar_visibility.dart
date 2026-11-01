import 'package:flutter/foundation.dart';

/// True while a sheet that covers the phone tab bar is open. The Bookmarks
/// sheet on Study hides the bar, as the BM_Open board does.
final ValueNotifier<bool> phoneTabBarHidden = ValueNotifier<bool>(false);
