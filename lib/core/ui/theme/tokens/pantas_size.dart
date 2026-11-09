// GENERATED, do not edit.
// Source: design/system/tokens.json
// Generator: tool/design_system/generate_tokens.dart
// Regenerate: dart run tool/design_system/generate_tokens.dart

/// Component sizes (logical px, rem x 16).
abstract final class PantasSize {
  /// Default button height on desktop.
  static const double btn = 44;

  /// Large button: the one action a page exists for.
  static const double btnLg = 50;

  /// Tonal, ghost and white buttons in rows, notices and dialogs on wide
  /// screens (boards 42).
  static const double btnSm = 42;

  /// Header button: the mock exam Flag with its F hint, top right of the
  /// question (MK question boards: 36 high, 14px). New (R3-O04).
  static const double btnXs = 36;

  /// Floating-bar buttons, the phone dialog pair and the counter (pills,
  /// radius-full, D187).
  static const double btnBar = 46;

  /// Full-width phone button.
  static const double btnPhone = 52;

  /// Default icon button.
  static const double iconBtn = 44;

  /// Medium icon button.
  static const double iconBtnMd = 40;

  /// Small icon button. Hit area is padded to 44px.
  static const double iconBtnSm = 32;

  /// Minimum target on touch input (phone, tablet, any coarse pointer).
  /// Smaller controls get a padded hit area.
  static const double targetTouch = 44;

  /// Text field height.
  static const double field = 48;

  /// Sidebar search height (38). Pointer only: the sidebar exists from
  /// 1024px.
  static const double search = 38;

  /// Sidebar item height (40). Pointer only.
  static const double navItem = 40;

  /// Back link height (40). A coarse pointer pads the hit area to 44.
  static const double back = 40;

  /// Minimum phone row height.
  static const double rowMinPhone = 44;

  /// Minimum answer option height.
  static const double optMin = 64;

  /// Answer letter badge.
  static const double optBadge = 32;

  /// Phone answer letter badge.
  static const double optBadgePhone = 30;

  /// Switch width.
  static const double switchW = 51;

  /// Switch height.
  static const double switchH = 31;

  /// Switch thumb.
  static const double switchThumb = 27;

  /// Checkbox and radio.
  static const double check = 24;

  /// QuestionNavigator flag dot (11), the accent dot at a chip's top right;
  /// the Mock session legend dot for Flagged uses it too. New in 4.1.0
  /// (D193).
  static const double flagDot = 11;

  /// Phone tab bar height.
  static const double tabbar = 64;

  /// Phone tab bar item height.
  static const double tabbarItem = 52;

  /// Floating bar height.
  static const double bar = 64;

  /// Week day width on every platform (44, so each day is a 44px target;
  /// size-week-day-phone folded in, 3.0.0).
  static const double weekDay = 44;

  /// Accuracy bar, time bar and progress bar height (5). Renamed from
  /// size-bar5.
  static const double accuracyBar = 5;

  /// Accuracy bar height in topic rows (4). Renamed from size-bar5-rows.
  static const double accuracyBarCompact = 4;

  /// Default icon size. Stroke 1.8.
  static const double icon = 20;

  /// Sidebar avatar (30).
  static const double avatar = 30;

  /// Preferred minimum target on a fine pointer (mouse). Absolute minimum
  /// size-target-pointer-min.
  static const double targetPointer = 32;

  /// Absolute minimum target on a fine pointer (WCAG 2.5.8).
  static const double targetPointerMin = 24;

  /// Profile avatar in Settings (board 44, initial 19/700).
  static const double avatarLg = 44;

  /// Plan task status marker on wide screens (board 26). Phone uses
  /// size-check (24).
  static const double task = 26;

  /// Half gauge width (board 224 by 118).
  static const double gaugeW = 224;

  /// Half gauge stroke.
  static const double gaugeStroke = 14;

  /// Mock question chip (board .q 36 circle).
  static const double qnav = 36;

  /// Slider track height (phone board).
  static const double sliderTrack = 4;

  /// Slider thumb (phone board).
  static const double sliderThumb = 26;

  /// Shortest slider track beside its end labels and value. Under 17rem of
  /// row width (the labels at their text size plus this track) the labels
  /// and the value move above the track, which then takes the full row
  /// width (ruling 1). New.
  static const double sliderTrackMin = 160;

  /// Largest TabBar label size. The label is 10px at default text and stops
  /// growing at 12px, so four labels stay beside their icons at 200% text
  /// (D181). New.
  static const double tabLabelMax = 12;

  /// Minimum SelectableTile column in a .choice-grid (160px at default
  /// text). In rem, so a grid drops to one column at large text instead of
  /// overflowing (ruling 2). New: was 160px. (10rem: scale by the text
  /// scaler at the use site.)
  static const double tileMin = 160;

  /// Mock time bar width (phone board 120 by 5).
  static const double timerBar = 120;

  /// Study-day tile height (onboarding .dy).
  static const double tileDay = 76;

  /// Select box minimum height (onboarding .sb).
  static const double select = 56;

  /// Date picker day cell height (onboarding .dd).
  static const double dateCell = 46;

  /// Date picker month cell height (onboarding .mo).
  static const double monthCell = 42;

  /// Phone wheel picker row and selection band (board).
  static const double wheelRow = 36;

  /// Minimum height of a multi-line field (boards draw 92).
  static const double textarea = 92;

  /// Plot height of a chart at every width; the chart reflows sideways and
  /// its text never scales. New, no board (ruling 3).
  static const double chartH = 220;

  /// Minimum width of one chart point or bar column; the chart shows the
  /// most recent points that fit (ruling 7). New. (2.75rem: scale by the
  /// text scaler at the use site.)
  static const double chartCol = 44;

  /// ProgressRing value stroke (24 and 34 rings, task partial ring). New
  /// (R3-O22: was a literal).
  static const double ringStroke = 2.4;

  /// ReaderTopBar progress thread (RD_FocusMotion: 3px). New (ruling 2).
  static const double thread = 3;

  /// SearchOverlay field row (SD_Search: 60 high). New (ruling 9).
  static const double searchField = 60;

  /// Tooltip maximum width. New (R3-O10).
  static const double tooltipMax = 240;
}
