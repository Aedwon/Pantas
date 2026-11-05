// Runs before Flutter. Keeps the browser's history when the page is reloaded.
//
// Flutter numbers every history entry it makes, in history.state
// ({serialCount, state}). When it starts on an entry with that number it
// assumes a past run left it, and puts the history back as it found it: it
// goes back to the first entry (history.go(-serialCount)) and writes the
// original state there. After a reload that deleted every earlier page, so
// browser Back left the app. Unwrapping the state here means Flutter sees an
// ordinary entry, leaves the earlier entries alone, and numbers this one again.
(function (root) {
  'use strict';

  function unwrap(win) {
    try {
      var state = win.history.state;
      if (
        state &&
        typeof state === 'object' &&
        state.serialCount != null &&
        'state' in state
      ) {
        win.history.replaceState(state.state, '', win.location.href);
        return true;
      }
    } catch (_) {
      // A browser that refuses history access keeps Flutter's own behavior.
    }
    return false;
  }

  if (typeof module === 'object' && module.exports) {
    module.exports = { unwrap: unwrap };
    return;
  }
  unwrap(root);
})(typeof window !== 'undefined' ? window : this);
