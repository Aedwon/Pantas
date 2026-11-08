// GENERATED, do not edit.
// Source: design/system/tokens.json
// Generator: tool/design_system/generate_tokens.dart
// Regenerate: dart run tool/design_system/generate_tokens.dart

import 'package:flutter/material.dart';

/// Every text style of the design system. Sizes are rem x 16
/// logical px; letter spacing is em x size. No color: apply it
/// at the use site with `copyWith(color: ...)`.
abstract final class PantasType {
  /// Hero number in a ring or results. Tabular figures. Use instead of h2
  /// only where a board needs a hero. (48/700)
  static const webDisplay = TextStyle(
    fontFamily: 'Geist',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: -1.44,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Page title. One per page. (38/700)
  static const webH1 = TextStyle(
    fontFamily: 'Geist',
    fontSize: 38,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.912,
  );

  /// Section title. (26/700)
  static const webH2 = TextStyle(
    fontFamily: 'Geist',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.468,
  );

  /// Card and dialog title. (20/700)
  static const webH3 = TextStyle(
    fontFamily: 'Geist',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.24,
  );

  /// Call-to-action card title (Home assessment card, board 22px). Metrics
  /// follow web-h3. New. (22/700)
  static const webH3Lg = TextStyle(
    fontFamily: 'Geist',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.264,
  );

  /// Small title: notice title, selectable tile name. New (R2-O01).
  /// (16/600)
  static const webTitleSm = TextStyle(
    fontFamily: 'Geist',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Line under a page title. Secondary color. (17/400)
  static const webLead = TextStyle(
    fontFamily: 'Geist',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// Default text. Primary color. (16/400)
  static const webBody = TextStyle(
    fontFamily: 'Geist',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// Supporting text. Secondary color. (15/400)
  static const webSub = TextStyle(
    fontFamily: 'Geist',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// Captions and fine print. Secondary color. (13/400)
  static const webSmall = TextStyle(
    fontFamily: 'Geist',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// Field label above a field (patterns 13/600). Also the question-chip
  /// number and the exam-chip name (weight 700). New (R2-O01). (13/600)
  static const webFieldLabel = TextStyle(
    fontFamily: 'Geist',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Sidebar account name (board 14/600) and segmented control label
  /// (web-seg 14/600/1.25 merged in, R2-O22). (14/600)
  static const webLabel = TextStyle(
    fontFamily: 'Geist',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Sidebar account plan line (board 12). Secondary color. New. (12/400)
  static const webCaption = TextStyle(
    fontFamily: 'Geist',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  /// Small label above a group. Uppercase, secondary color. Set
  /// text-transform in the component. (13/600)
  static const webEyebrow = TextStyle(
    fontFamily: 'Geist',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.26,
  );

  /// Large stat. Tabular figures. (40/700)
  static const webBigNumeral = TextStyle(
    fontFamily: 'Geist',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Unit after a hero number (gauge "%", board 22/600). Secondary color.
  /// New. (22/600)
  static const webStatUnit = TextStyle(
    fontFamily: 'Geist',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1,
  );

  /// Question stem in focus mode. Scales with the lesson text scale
  /// (--reader-scale, R2-O02). (27/600)
  static const webQuestion = TextStyle(
    fontFamily: 'Geist',
    fontSize: 27,
    fontWeight: FontWeight.w600,
    height: 1.38,
    letterSpacing: -0.432,
  );

  /// Reader body in the 680px column. Color reader-body. Scales with the
  /// lesson text scale (--reader-scale, R2-O02). (18/400)
  static const webReaderBody = TextStyle(
    fontFamily: 'Geist',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.7,
  );

  /// Text inside a reader block (note, common mistake, example). Scales
  /// with the lesson text scale (--reader-scale, R2-O02). New (R2-O01; the
  /// block drew 16/1.6). (16/400)
  static const webReaderBlock = TextStyle(
    fontFamily: 'Geist',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  /// Explanation card body on wide screens (board 17/1.55). Color
  /// reader-body. Scales with the lesson text scale (--reader-scale,
  /// R2-O02). New (R2-O01). (17/400)
  static const webExplanation = TextStyle(
    fontFamily: 'Geist',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  /// Sidebar item. Active item is 600. (15/500)
  static const webNav = TextStyle(
    fontFamily: 'Geist',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  /// Button label. Title Case. (16/600)
  static const webButton = TextStyle(
    fontFamily: 'Geist',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// Large button label. (17/600)
  static const webButtonLg = TextStyle(
    fontFamily: 'Geist',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// Key hint on its own; week-day letter; date-picker weekday. (11/600)
  static const webKeyHintSm = TextStyle(
    fontFamily: 'Geist',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Tag label and the key hint inside a primary button (web-key-hint
  /// 12/600/1.2 merged in, R2-O22). (12/600)
  static const webTag = TextStyle(
    fontFamily: 'Geist',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Pro mark. (11/700)
  static const webPro = TextStyle(
    fontFamily: 'Geist',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.22,
  );

  /// Row title, link tile and back link (web-back 17/400/1.25 merged in,
  /// R2-O22). (17/400)
  static const webRowTitle = TextStyle(
    fontFamily: 'Geist',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  /// Settings row title and pane row value (boards 16). New. (16/400)
  static const webRowTitleSettings = TextStyle(
    fontFamily: 'Geist',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  /// Row subtitle. Secondary color. (14/400)
  static const webRowSub = TextStyle(
    fontFamily: 'Geist',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  /// Row value. Secondary color. (15/400)
  static const webRowValue = TextStyle(
    fontFamily: 'Geist',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  /// StatRow value (16/600; empty is the 400 state). R3-O09. New. (16/600)
  static const webStatValue = TextStyle(
    fontFamily: 'Geist',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// ExamChip exam name (13/700). R3-O09: was web-field-label with a 700
  /// override. New. (13/700)
  static const webChipName = TextStyle(
    fontFamily: 'Geist',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  /// Single glyph or short number in a box: avatar initial, calendar day in
  /// the ExamChip (14/700/1). R3-O09. New. (14/700)
  static const webGlyph = TextStyle(
    fontFamily: 'Geist',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  /// SearchOverlay query text (SD_Search draws 19px). Ruling 9. New.
  /// (19/400)
  static const webSearchInput = TextStyle(
    fontFamily: 'Geist',
    fontSize: 19,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  /// Mock timer digits. Tabular figures. New (R2-O01). (17/700)
  static const webTimer = TextStyle(
    fontFamily: 'Geist',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Answer option text. Scales with the lesson text scale (--reader-scale,
  /// R2-O02). (18/400)
  static const webOption = TextStyle(
    fontFamily: 'Geist',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Text link with an arrow. (15/600)
  static const webLink = TextStyle(
    fontFamily: 'Geist',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Tab root title. (34/700)
  static const phoneLargeTitle = TextStyle(
    fontFamily: 'Geist',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.748,
  );

  /// Pushed screen heading. (28/700)
  static const phoneTitle1 = TextStyle(
    fontFamily: 'Geist',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.616,
  );

  /// Card headline. (22/700)
  static const phoneTitle2 = TextStyle(
    fontFamily: 'Geist',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: -0.264,
  );

  /// Dialog and sheet title. (20/700)
  static const phoneTitle3 = TextStyle(
    fontFamily: 'Geist',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: -0.24,
  );

  /// Question stem. Scales with the lesson text scale (--reader-scale,
  /// R2-O02). (21/600)
  static const phoneQuestion = TextStyle(
    fontFamily: 'Geist',
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.252,
  );

  /// Button label and emphasized row. (17/600)
  static const phoneHeadline = TextStyle(
    fontFamily: 'Geist',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.204,
  );

  /// Default text. The most used style. (17/400)
  static const phoneBody = TextStyle(
    fontFamily: 'Geist',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: -0.204,
  );

  /// Answer option text on the phone (phone-body metrics). Scales with the
  /// lesson text scale, which phone-body does not (ruling 4, R3-A02). New.
  /// (17/400)
  static const phoneOption = TextStyle(
    fontFamily: 'Geist',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: -0.204,
  );

  /// Lesson text. Color reader-body. Scales with the lesson text scale
  /// (--reader-scale, R2-O02). (17/400)
  static const phoneReaderBody = TextStyle(
    fontFamily: 'Geist',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.55,
    letterSpacing: -0.204,
  );

  /// Helper copy and dialog body. (16/400)
  static const phoneCallout = TextStyle(
    fontFamily: 'Geist',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  /// Card subtitle and secondary value (board 15/500). Code subhead is
  /// 15/400: use phone-explanation for regular 15px text. (15/500)
  static const phoneSubhead = TextStyle(
    fontFamily: 'Geist',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  /// Phone explanation text under the options (board 15/1.5). New. (15/400)
  static const phoneExplanation = TextStyle(
    fontFamily: 'Geist',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Row caption and section footer. Secondary color. (13/400)
  static const phoneFootnote = TextStyle(
    fontFamily: 'Geist',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  /// Phone label above an explanation, emphasized caption (board 13/500).
  /// New. (13/500)
  static const phoneFootnoteStrong = TextStyle(
    fontFamily: 'Geist',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  /// Group header. Uppercase, secondary color. (13/600)
  static const phoneSectionHeader = TextStyle(
    fontFamily: 'Geist',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.26,
  );

  /// Caption. (12/400)
  static const phoneCaption = TextStyle(
    fontFamily: 'Geist',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  /// Tab label (active 600, inactive 500) and week day. (10/600)
  static const phoneCaptionSmall = TextStyle(
    fontFamily: 'Geist',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  /// TabBar label at rest (10/500); the current tab is the 600 state
  /// (R3-O09: was phone-caption-small with a rest weight override). New.
  /// (10/500)
  static const phoneTabLabel = TextStyle(
    fontFamily: 'Geist',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  /// Wheel picker row (20/400 in a 36px row; the selected row is the 500
  /// state). R3-O09: was phone-title-3 with weight and line-height
  /// overrides. New. (20/400)
  static const phoneWheel = TextStyle(
    fontFamily: 'Geist',
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1,
  );

  /// Display numeral, small. (44/700)
  static const phoneDisplayS = TextStyle(
    fontFamily: 'Geist',
    fontSize: 44,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -1.32,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Display numeral, medium. (60/700)
  static const phoneDisplayM = TextStyle(
    fontFamily: 'Geist',
    fontSize: 60,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: -1.8,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Display numeral, large: session score. Tracking -0.022em as drawn
  /// (board 88/700/1.12/-0.022); the smaller numerals use -0.03em. (88/700)
  static const phoneDisplayL = TextStyle(
    fontFamily: 'Geist',
    fontSize: 88,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -1.936,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Display math on its own line: 1.6em of the reader body (about 29px at
  /// 18px; boards draw 30). Centered, scrolls sideways. New (R2-O03).
  /// (28.8/400)
  static const mathDisplay = TextStyle(
    fontFamily: 'Source Serif 4',
    fontSize: 28.8,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
}
