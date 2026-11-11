// GENERATED, do not edit.
// Source: design/system/tokens.json
// Generator: tool/design_system/generate_tokens.dart
// Regenerate: dart run tool/design_system/generate_tokens.dart

/// A CSS flex triple: grow, shrink and basis (logical px).
///
/// The shell lays these out like CSS flex-wrap: place items at
/// their basis, wrap when they no longer fit, then share the
/// free space by `grow`.
class PantasFlex {
  const PantasFlex(this.grow, this.shrink, this.basis);

  final double grow;
  final double shrink;
  final double basis;
}

/// Page, column, bar and breakpoint measures.
abstract final class PantasLayout {
  /// Maximum width of page content, centered in the main area.
  static const double contentMax = 1080;

  /// Main area padding top.
  static const double mainPadTop = 28;

  /// Main area padding left and right.
  static const double mainPadX = 44;

  /// Main area padding bottom.
  static const double mainPadBottom = 44;

  /// Sidebar flex basis.
  static const double sidebarMin = 220;

  /// Sidebar maximum width.
  static const double sidebarMax = 244;

  /// Flex shorthand of the main area beside the sidebar (boards .main).
  static const main = PantasFlex(999, 1, 560);

  /// The one block gap: between blocks in a column and between columns
  /// (layout-cols-gap folded in, 3.0.0). CHANGE: 26 to 28 (D66).
  static const double sectionGap = 28;

  /// Phone screen gutter.
  static const double gutterPhone = 16;

  /// Desktop row side inset.
  static const double rowInset = 20;

  /// Settings row side inset.
  static const double rowInsetSettings = 16;

  /// Vertical padding inside a desktop row. Boards draw 13 (476 rows), 15
  /// and 16; 13 is kept (D179, 48px rows with a 17px title; the Settings
  /// row has a 16px title and is 47px).
  static const double rowPadY = 13;

  /// Flex shorthand of the primary column (pair 1).
  static const colPrimary = PantasFlex(1.45, 1, 480);

  /// Flex shorthand of the secondary column (pair 1).
  static const colSecondary = PantasFlex(1, 1, 340);

  /// Flex shorthand of the picker column (pair 2).
  static const colPicker = PantasFlex(1, 1, 480);

  /// Flex shorthand of the fixed side panel (pair 2).
  static const colPanel = PantasFlex(0, 1, 400);

  /// Flex shorthand of the first equal column (pair 3).
  static const colEqualA = PantasFlex(1, 1, 420);

  /// Flex shorthand of the second equal column (pair 3).
  static const colEqualB = PantasFlex(1, 1, 380);

  /// Flex shorthand of the settings list column (pair 4, about 60 ST_
  /// boards). Max width layout-col-list-max.
  static const colList = PantasFlex(1, 1, 300);

  /// Maximum width of the settings list column.
  static const double colListMax = 360;

  /// Flex shorthand of the settings detail pane (pair 4).
  static const colDetail = PantasFlex(999, 1, 460);

  /// Reader column width.
  static const double reader = 680;

  /// Reader column width with full width on.
  static const double readerWide = 800;

  /// Focus mode header height.
  static const double focusHead = 64;

  /// FocusHeader height under 600: 44px at default text, as the approved
  /// phone boards draw it, growing only with text. The phone question list
  /// sheet and its scrim start under it (R4R-O01). New.
  static const double focusHeadPhone = 44;

  /// Question column in focus mode.
  static const double qcol = 720;

  /// Question column while the explanation shows.
  static const double qcolNarrow = 600;

  /// Explanation column.
  static const double xpl = 440;

  /// Flex shorthand of the passage column beside the question in focus mode
  /// (from bp-focus-split). Maximum layout-passage-max. New, no board
  /// (R2-O09).
  static const passage = PantasFlex(1, 1, 480);

  /// Maximum width of the passage column. New, no board (R2-O09).
  static const double passageMax = 640;

  /// Dialog width.
  static const double modal = 440;

  /// Wide dialog width.
  static const double modalWide = 560;

  /// Drawer width.
  static const double drawer = 440;

  /// Floating bar maximum width.
  static const double barMax = 720;

  /// Floating bar maximum width on wide pages.
  static const double barMaxWide = 1080;

  /// Floating bar distance from the bottom edge.
  static const double barBottom = 28;

  /// Phone tab bar left and right inset.
  static const double tabbarInset = 16;

  /// Phone tab bar distance from the bottom edge.
  static const double tabbarBottom = 24;

  /// Reference phone width.
  static const double phoneFrame = 390;

  /// Below this width the quiz bar's flag moves to the question header
  /// (D71). Media queries in the bundle repeat the bp-* values; the build
  /// script checks them.
  static const double bpPhoneNarrow = 400;

  /// Tablet portrait starts here: the phone layout centered in
  /// layout-tablet-column, TabBar centered at layout-tabbar-max. Below it
  /// is phone.
  static const double bpTabletPortrait = 600;

  /// Wide starts here: desktop type scale, natural-width buttons, P2
  /// placement, hover affordances. TabBar floats centered until bp-wide.
  static const double bpTabletLandscape = 1024;

  /// Wide tier: the full sidebar from 1440; 1024 to 1439 is the compact
  /// sidebar (ruling 11). New.
  static const double bpWide = 1440;

  /// Centered page column on tablet portrait (code web_route_shell).
  static const double tabletColumn = 640;

  /// Maximum width of the TabBar when it floats centered on tablets (code
  /// WebTabletNavigation).
  static const double tabbarMax = 358;

  /// Mock question list panel width (MK_NavMotion). New: was a literal.
  static const double qpanel = 300;

  /// FocusHeader width under which the inline clock drops its bar (384px at
  /// default text, so a 390 phone keeps it at 100% text). In rem, so it
  /// applies sooner at large text (ruling 7). New.
  static const double focusHeadNarrow = 384;

  /// Slider row width under which the end labels and the value move above
  /// the track (ruling 1): the labels at their text size plus
  /// size-slider-track-min. New.
  static const double sliderNarrow = 272;

  /// WheelGroup width under which the month wheel shows the short month
  /// name (Jan, Feb) instead of the full name, so "September" never
  /// overflows its column (content width; 336px at default text, so a 358px
  /// group keeps full names at 100% and a 288px group on a 320 phone shows
  /// short names; at 150% text and above every phone shows short names).
  /// New (D190).
  static const double wheelFull = 336;

  /// Phone screen width (.phone-screen, or the .main of a .shell page below
  /// 1024, each a size container) under which the phone large title steps
  /// down to title 2 (D180). In rem, so it applies at large text: a 320
  /// phone at 150% or 200% text, a 390 phone at 200%. New.
  static const double titleNarrow = 192;

  /// SearchOverlay panel width on wide screens (SD_Search). New (ruling 9).
  static const double search = 640;

  /// SearchOverlay distance from the top of the window (SD_Search). New
  /// (ruling 9).
  static const double searchTop = 110;

  /// ReaderTopBar: scroll distance over which the lesson title fades in
  /// (HANDOFF). The app sets .is-titled. New (ruling 2).
  static const double readerTitleScroll = 90;

  /// ReaderTopBar: further scroll before the bar hides (HANDOFF). The app
  /// sets .is-hidden; scrolling up clears it. New (ruling 2).
  static const double readerHideScroll = 120;

  /// Bottom reserve above the floating TabBar: offset 24 + bar 64 + gap 16
  /// written in rem, so it grows with text (ruling 3). Plus the safe area.
  /// New.
  static const double reserveTabbar = 104;

  /// Bottom reserve above the phone quiz bar when it floats (fixed docks,
  /// previews): offset 16 + bar 64 + gap 24 in rem (ruling 3). The phone
  /// screen itself makes the bar sticky (D131). New.
  static const double reserveBarPhone = 104;

  /// Bottom reserve of the focus-mode stage above the floating bar: offset
  /// 28 + bar 64 + gap 48 (was 140px) in rem (ruling 3). New.
  static const double reserveBar = 140;

  /// Minimum gap under the phone floating bar; the bar sits at max(16px,
  /// safe-area bottom + 8px).
  static const double barBottomPhone = 16;

  /// Focus mode shows question and explanation side by side from here (600
  /// + 14 + 440 + 80). Below it the explanation opens as a 440px Drawer
  /// over the question.
  static const double bpFocusSplit = 1134;
}
