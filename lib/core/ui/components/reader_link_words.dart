/// The part of a figure label that a lesson would write about, for the figure
/// painters that light one label.
library;

/// The part of a figure label that a lesson would write about: the text
/// before " = " or ":", without "Center " or "Point ".
String labelCore(String label) {
  var core = label.split(RegExp(' = |:')).first.trim();
  for (final prefix in ['Center ', 'Point ']) {
    if (core.startsWith(prefix)) core = core.substring(prefix.length).trim();
  }
  return core;
}
