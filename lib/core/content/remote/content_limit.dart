import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What every screen says when the server's daily content limit is the reason
/// content is missing.
const contentLimitMessage = 'Daily content limit reached. Try again tomorrow.';

/// True while the last content request was refused for the daily limit. The
/// content service sets it; a request that succeeds clears it, which is how
/// the app recovers on its own the next day.
final contentLimitReachedProvider = StateProvider<bool>((ref) => false);
