// GENERATED, do not edit.
// Source: design/system/tokens.json
// Generator: tool/design_system/generate_tokens.dart
// Regenerate: dart run tool/design_system/generate_tokens.dart

import 'package:flutter/material.dart';

/// Every color role of the design system, light and dark.
///
/// Roles are instance fields: read them from the theme with
/// `context.colors`. Primitives are static constants for the
/// generator and tests only; components use roles.
@immutable
class PantasColors extends ThemeExtension<PantasColors> {
  const PantasColors({
    required this.bgPage,
    required this.surfaceCard,
    required this.surfaceModal,
    required this.surfaceInset,
    required this.surfaceHover,
    required this.surfaceModalHover,
    required this.fill,
    required this.fillSkeleton,
    required this.surfaceSegmentOn,
    required this.edgeCard,
    required this.edgeBar,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnFill,
    required this.textOnTintSecondary,
    required this.textDisabled,
    required this.iconMuted,
    required this.iconChevron,
    required this.divider,
    required this.dividerStrong,
    required this.borderControl,
    required this.accent,
    required this.accentFill,
    required this.accentFillHover,
    required this.accentHover,
    required this.accentTint,
    required this.accentTintHover,
    required this.accentTintText,
    required this.onAccent,
    required this.kbdOnFill,
    required this.accentBar,
    required this.danger,
    required this.dangerText,
    required this.dangerTextHover,
    required this.dangerFill,
    required this.dangerFillHover,
    required this.dangerTint,
    required this.dangerBar,
    required this.dangerMuted,
    required this.onDanger,
    required this.warningText,
    required this.warningTint,
    required this.warningTintText,
    required this.pro,
    required this.onPro,
    required this.switchOff,
    required this.switchThumb,
    required this.toastBg,
    required this.toastText,
    required this.toastAction,
    required this.toastActionHover,
    required this.scrim,
    required this.scrimSearch,
    required this.liquidStart,
    required this.liquidEnd,
    required this.heroStart,
    required this.heroMid,
    required this.heroEnd,
    required this.topicDoneEnd,
    required this.shareEnd,
    required this.onHero,
    required this.onHeroSecondary,
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
    required this.figureBg,
    required this.figureReaderBg,
    required this.figureViewerBg,
    required this.figureOnViewer,
    required this.figureScrim,
    required this.figureCaption,
    required this.readerBody,
    required this.readerStrong,
    required this.readerDeep,
    required this.readerNoteText,
    required this.readerMistake,
    required this.readerMistakeTint,
    required this.readerMistakeText,
  });

  /// Page background behind every screen and the sidebar. Text:
  /// text-primary, text-secondary. (PantasColors.background)
  final Color bgPage;

  /// Cards, grouped lists, dialogs, popovers, fields, floating bars, the
  /// tab bar. Text: text-primary, text-secondary. In dark, pair with
  /// edge-card. (PantasColors.surface)
  final Color surfaceCard;

  /// Dialog and sheet surface. Light equals the card. Dark is one step up
  /// (#2A2A2A) so a dialog separates from the dimmed cards behind the
  /// scrim. Fields inside keep surface-card. Text: text-primary,
  /// text-secondary (5.7:1). New, no dark board (usage gap 24).
  final Color surfaceModal;

  /// Card footer band and indented rows inside a card, always with a
  /// divider rule above. Dark equals the card, as the approved dark board
  /// draws it. CHANGE (dark): #2A2A2A to the card value. Text:
  /// text-primary, text-secondary. (PantasColors.pickerBackground)
  final Color surfaceInset;

  /// Hover well of rows, white buttons and popover items. Text:
  /// text-primary, text-secondary. (WebTokens.rowHover)
  final Color surfaceHover;

  /// Hover and press well inside a Dialog or Sheet. Light equals
  /// surface-hover; dark is white at 6% over surface-modal (about #363636
  /// on #2A2A2A, 1.2:1; an alpha literal, because no new gray clears the
  /// 2.0 CIEDE2000 rule between #303030 and #3A3A3C), because surface-hover
  /// equals surface-modal in dark (R3-O02). The bundle sets it as
  /// surface-hover inside .dialog and .sheet. New.
  final Color surfaceModalHover;

  /// Segmented track, progress track, disabled button fill, gray tag,
  /// neutral button. Text: text-on-fill. CHANGE (dark): #2A2A2A to #303033
  /// so it differs from surface-hover. (PantasColors.fill)
  final Color fill;

  /// Skeleton blocks only. Light shares the divider gray; dark is one clear
  /// step above the card and the hover well (1.5:1 on the card). CHANGE
  /// (dark): #2C2C2C to #3D3D3D (R2-O20); light #E6E6EA folds into #E3E3E8
  /// (R2-O21, invisible). (PantasColors.skeleton) Equal to switch-off by
  /// coincidence, not an alias (R3-O13).
  final Color fillSkeleton;

  /// Selected segment thumb. Text: text-primary. (PantasColors.segmentOn)
  final Color surfaceSegmentOn;

  /// 1px inset edge on cards and grouped lists. Transparent in light,
  /// visible in dark. Dark #2C2C2C folds into #2A2A2A (R2-O21, invisible).
  /// (PantasColors.cardEdge)
  final Color edgeCard;

  /// 1px inset ring of floating bars and the tab bar; elev-bar adds the
  /// drop. Light is black at 6%. (webFloatingEdge)
  final Color edgeBar;

  /// Body text, titles, row labels. On bg-page, surface-card,
  /// surface-inset, surface-hover, accent-bar, danger-bar, fill.
  /// (PantasColors.label)
  final Color textPrimary;

  /// Secondary text, lead lines, row subtitles and values, eyebrows,
  /// placeholders, hints, past dates, dimmed content. On bg-page,
  /// surface-card, surface-inset, surface-hover. Not on fill (text-on-fill)
  /// or accent-tint (text-on-tint-secondary). (PantasColors.secondaryLabel)
  final Color textSecondary;

  /// Secondary text on fill: gray tag, unselected segment labels. 5.1:1
  /// light, 5.2:1 dark. (PantasColors.onFillLabel)
  final Color textOnFill;

  /// Secondary text on accent-tint: the subtitle and value of a selected
  /// row, the subtitle of a selected tile. 4.6:1 light, 5.4:1 dark.
  final Color textOnTintSecondary;

  /// Labels of disabled controls only, on fill or surface-card. Exempt from
  /// 4.5:1 because the control is disabled. Never for readable content. One
  /// step below text-secondary in both themes. CHANGE (dark): #949494 to
  /// #6B6B6B. (PantasColors.disabledActionLabel, WebTokens.disabledText)
  final Color textDisabled;

  /// Inactive nav and tab icons, ghost icons, search glyph. 3:1 on bg-page
  /// and surface-card. (nav icon stroke)
  final Color iconMuted;

  /// Row chevrons. 3:1 on white and surface-hover; on accent-tint use
  /// accent-tint-text. Light #8F8F93 folds into #8E8E93 (R2-O21,
  /// invisible). (PantasColors.chevron)
  final Color iconChevron;

  /// Hairlines, row separators, notice ring, card footer rule, progress
  /// ring tracks. Decorative only: never the boundary of a control.
  /// (PantasColors.separator)
  final Color divider;

  /// Key-hint ring, sheet grabber, half-day dot, question chip ring, hover
  /// ring on options and tiles. Decorative only. (WebTokens.strongDivider)
  final Color dividerStrong;

  /// Boundary of every control a learner must find: fields, search, white
  /// buttons, unchecked checkbox and radio, switch off ring, answer letter
  /// badge, not-started task marker, select box. 3.4:1 on white, 3.2:1 on
  /// bg-page; dark 5.1:1. Hover: text-secondary.
  /// (PantasColors.controlOutline)
  final Color borderControl;

  /// Teal text, links, icons, selected rings, focus ring, progress fills,
  /// accent-tone ghost buttons. On bg-page, surface-card, surface-hover,
  /// accent-bar. (PantasColors.accent)
  final Color accent;

  /// Filled teal: primary button, switch on, selected badge, checkbox on,
  /// Today disc, done marker. Text on it: on-accent.
  /// (PantasColors.accentFill)
  final Color accentFill;

  /// Hover fill of primary, switch on and checkbox on. Dark value is
  /// derived in code (no board value). (WebTokens.accentHover) Dark #0E7967
  /// folds into #0B7A68 (R2-O21, invisible).
  final Color accentFillHover;

  /// Hover color of teal text: links, accent ghost labels, tonal label.
  /// Dark is the lighter tint text because a dark teal fails on dark
  /// grounds. (WebTokens.tintText)
  final Color accentHover;

  /// Tonal button, tag, selected row, correct-answer wash, active tab item.
  /// Text on it: accent-tint-text, text-on-tint-secondary.
  /// (PantasColors.accentTint)
  final Color accentTint;

  /// Hover fill of the tonal button; the label switches to accent-hover.
  /// Dark value is chosen (code has none). (WebTokens.secondaryHover)
  final Color accentTintHover;

  /// Teal text and icons on accent-tint, including the active tab item.
  /// 4.5:1 light, 8.1:1 dark. (PantasColors.accentTintText)
  final Color accentTintText;

  /// Text and marks on accent-fill. (PantasColors.onAccent)
  final Color onAccent;

  /// Key-hint chip inside a primary or critical button: black at 16% under
  /// on-accent text (6.9:1 light, 6.0:1 dark, D10). Was a literal in the
  /// bundle. New (R2-O24).
  final Color kbdOnFill;

  /// Floating bar background after a right answer. Text: text-primary.
  /// (PantasColors.floatingRight)
  final Color accentBar;

  /// Red rings, borders and badges: wrong answer ring, invalid field ring,
  /// red outline button. Red marks only a destructive action or something
  /// the learner got wrong or entered wrong. Not for text in dark
  /// (danger-text). (PantasColors.destructive)
  final Color danger;

  /// Red text and icons for wrong, invalid or destructive. On surface-card,
  /// bg-page, danger-tint, danger-bar. (PantasColors.wrongText)
  final Color dangerText;

  /// Hover color of red ghost and outlined labels. Dark #F0807A holds 4.9:1
  /// over its 8% wash on surface-modal and 5.6:1 on the card (R3-A07;
  /// CHANGE from danger-text, which fell to 4.1:1 in a dark dialog).
  /// (WebTokens.dangerTextHover)
  final Color dangerTextHover;

  /// Filled destructive button and wrong-answer badge. Text on it:
  /// on-danger. (WebTokens.dangerFill)
  final Color dangerFill;

  /// Hover fill of the destructive button. (WebTokens.dangerHover)
  final Color dangerFillHover;

  /// Wrong-answer wash only. An invalid field keeps surface-card. Text:
  /// danger-text or text-primary. (PantasColors.wrongTint)
  final Color dangerTint;

  /// Floating bar background after a wrong answer. Text: text-primary.
  /// (PantasColors.floatingWrong)
  final Color dangerBar;

  /// Light red of wrong answers in the UPCAT mock finale (scan and red
  /// ball). Graphic only. New: the finale drew #F4AFAF with no token.
  final Color dangerMuted;

  /// Text and marks on danger-fill. (PantasColors.onDestructive)
  final Color onDanger;

  /// Orange text and icons for a heads-up: timer under five minutes,
  /// Unread, warning notice icon. Always with a word or icon. CHANGE
  /// (dark): #D9A400 to #F0A35A (7.9:1), so gold marks only Pro.
  /// (PantasColors.warningText)
  final Color warningText;

  /// Background of the orange tag and the warning notice band (board .tago
  /// #FFF1E5). Dark value chosen. Text: warning-tint-text. New role.
  final Color warningTint;

  /// Text on warning-tint. Light is warning-text as the board draws it
  /// (4.7:1); dark chosen (8.8:1). New role.
  final Color warningTintText;

  /// Gold fill of the Pro mark. Always with on-pro text. Never a lone gold
  /// icon on white (2.2:1). (PantasColors.pro)
  final Color pro;

  /// Text on the Pro mark. 7.4:1 on pro. New.
  final Color onPro;

  /// Off track of a switch, always with a 1.5px border-control ring. (css
  /// .sw) Equal to fill-skeleton by coincidence, not an alias (R3-O13).
  final Color switchOff;

  /// Switch thumb, both themes. (PantasColors.switchThumb)
  final Color switchThumb;

  /// Toast background. Light is ink; dark is a raised gray with a 1px edge
  /// in elev-toast so it separates from the dark page. CHANGE (dark):
  /// #1D1D1F (1.1:1 on the page) to #3A3A3C. (PantasColors.toastBackground)
  final Color toastBg;

  /// Toast message text. (PantasColors.onToast)
  final Color toastText;

  /// Toast action link (Undo). 10.1:1 light, 6.8:1 dark.
  /// (PantasColors.toastAction)
  final Color toastAction;

  /// Hover well of the toast action: white at 10% over toast-bg. Was a
  /// literal in the bundle. New (R2-O24).
  final Color toastActionHover;

  /// Overlay behind dialogs, sheets and drawers. Light is ink at 32%; dark
  /// is black at 48%. CHANGE (dark): 28% to 48% so a dialog separates from
  /// the dark page. (WebRootModal literals)
  final Color scrim;

  /// Lighter scrim behind the SearchOverlay, so the page stays readable
  /// under the results (SD_Search boards: ink at 22%). Dark is black at
  /// 40%. New (ruling 9).
  final Color scrimSearch;

  /// Start of the liquid gauge and exam-switch gradient.
  /// (PantasColors.liquidStart)
  final Color liquidStart;

  /// End of the liquid gauge gradient. (PantasColors.liquidEnd)
  final Color liquidEnd;

  /// Start of the teal gradient (Pro hero on the phone, topic-done card,
  /// share card). ST_ProPMA draws #0E8C77, folded into #0E8B76 (D129). New
  /// (ruling 10).
  final Color heroStart;

  /// Middle stop of the phone Pro hero gradient (40%). New (ruling 10).
  final Color heroMid;

  /// End of the phone Pro hero gradient (ST_ProPMA #075548). New (ruling
  /// 10).
  final Color heroEnd;

  /// End of the topic-done card gradient (RD_TopicDone, RD_TopicShort
  /// #075C4E). New (ruling 10).
  final Color topicDoneEnd;

  /// End of the share-card gradient (L_Share, WR_*: #064C40 folded into
  /// #0A4D42, 0.6 CIEDE2000). Sharing is deferred; the token documents the
  /// approved value. New (ruling 10).
  final Color shareEnd;

  /// Text on a teal gradient. Titles 3:1 or better on the start (large
  /// text); body text sits on the middle and end stops (5.3:1 and up). New
  /// (ruling 10).
  final Color onHero;

  /// Icons and secondary text on a teal gradient (ST_ProPMA #BFF0E4). 3.4:1
  /// on the start (icons), 4.2:1 on the middle stop. New (ruling 10).
  final Color onHeroSecondary;

  /// Accuracy step 1: below 45%. Lighter (light) or dimmer (dark) means
  /// lower accuracy. 3.0:1 and 3.0:1 on surface-card, light and dark. The
  /// number is always printed beside it. CHANGE: new values so every step
  /// holds 3:1.
  final Color chart1;

  /// Accuracy step 2: 45 to 54%. Lighter (light) or dimmer (dark) means
  /// lower accuracy. 3.5:1 and 3.5:1 on surface-card, light and dark. The
  /// number is always printed beside it. CHANGE: new values so every step
  /// holds 3:1.
  final Color chart2;

  /// Accuracy step 3: 55 to 64%. Lighter (light) or dimmer (dark) means
  /// lower accuracy. 4.0:1 and 4.6:1 on surface-card, light and dark. The
  /// number is always printed beside it. CHANGE: new values so every step
  /// holds 3:1.
  final Color chart3;

  /// Accuracy step 4: 65 to 74%. Lighter (light) or dimmer (dark) means
  /// lower accuracy. 4.6:1 and 6.0:1 on surface-card, light and dark. The
  /// number is always printed beside it. CHANGE: new values so every step
  /// holds 3:1.
  final Color chart4;

  /// Accuracy step 5: 75% and up. Lighter (light) or dimmer (dark) means
  /// lower accuracy. 5.3:1 and 7.6:1 on surface-card, light and dark. The
  /// number is always printed beside it. CHANGE: new values so every step
  /// holds 3:1. Aliases accent on purpose: the top step is the brand teal
  /// (R3-O13).
  final Color chart5;

  /// Backing for question figures. Stays white in dark.
  /// (PantasColors.figureBackground)
  final Color figureBg;

  /// Backing for reader illustrations, which keep their printed background
  /// in both themes. (PantasColors.readerFigureBackground)
  final Color figureReaderBg;

  /// Flutter figure viewer stage (black). The web viewer uses figure-scrim
  /// over the page. The Flutter viewer reads it (R4-O11).
  /// (PantasColors.figureViewerBackground)
  final Color figureViewerBg;

  /// Controls on the figure viewer. (PantasColors.onFigureViewer)
  final Color figureOnViewer;

  /// Scrim over the page behind the figure viewer. (WebTokens.figureScrim)
  final Color figureScrim;

  /// Caption text on the figure viewer (on figure-scrim).
  /// (WebTokens.figureCaption)
  final Color figureCaption;

  /// Lesson body text, one step below reader-strong. On surface-card and
  /// bg-page. (PantasColors.readerBody)
  final Color readerBody;

  /// Bold and display math in lessons. (PantasColors.readerStrong)
  final Color readerStrong;

  /// Solution panel inside a lesson example card. (PantasColors.readerDeep)
  final Color readerDeep;

  /// Text of reader note cards on accent-tint.
  /// (PantasColors.readerNoteText)
  final Color readerNoteText;

  /// Icon and rule of the reader's common-mistake card (Traps to Watch
  /// For). Red is allowed: it marks what learners get wrong. Renamed from
  /// reader-warn. (PantasColors.readerWarn)
  final Color readerMistake;

  /// Background of the common-mistake card. Renamed from reader-warn-tint.
  /// (PantasColors.readerWarnTint)
  final Color readerMistakeTint;

  /// Text of the common-mistake card. Renamed from reader-warn-text.
  /// (PantasColors.readerWarnText)
  final Color readerMistakeText;

  static const amber41 = Color(0xFFFFF1E5);
  static const amber188 = Color(0xFFF2C27A);
  static const amber268 = Color(0xFFF0A35A);
  static const amber541 = Color(0xFFB25000);
  static const amber830 = Color(0xFF33281A);
  static const gold296 = Color(0xFFD9A400);
  static const gray0 = Color(0xFFFFFFFF);
  static const gray14 = Color(0xFFFBFBFC);
  static const gray18 = Color(0xFFFAFAF7);
  static const gray27 = Color(0xFFF7F7F9);
  static const gray34 = Color(0xFFF5F5F7);
  static const gray35 = Color(0xFFF5F5F5);
  static const gray62 = Color(0xFFEDEDF0);
  static const gray96 = Color(0xFFE3E3E8);
  static const gray160 = Color(0xFFD1D1D6);
  static const gray189 = Color(0xFFC9C9CD);
  static const gray288 = Color(0xFFAEAEB2);
  static const gray330 = Color(0xFFA3A3A3);
  static const gray387 = Color(0xFF949494);
  static const gray408 = Color(0xFF8E8E93);
  static const gray424 = Color(0xFF8A8A8E);
  static const gray534 = Color(0xFF6E6E73);
  static const gray548 = Color(0xFF6B6B6B);
  static const gray579 = Color(0xFF636366);
  static const gray685 = Color(0xFF4A4A4A);
  static const gray742 = Color(0xFF3D3D3D);
  static const gray744 = Color(0xFF3C3C43);
  static const gray755 = Color(0xFF3A3A3C);
  static const gray800 = Color(0xFF303033);
  static const gray801 = Color(0xFF303030);
  static const gray829 = Color(0xFF2A2A2A);
  static const gray882 = Color(0xFF1F1F1F);
  static const gray892 = Color(0xFF1D1D1F);
  static const gray912 = Color(0xFF191919);
  static const gray932 = Color(0xFF151515);
  static const gray948 = Color(0xFF111114);
  static const gray1000 = Color(0xFF000000);
  static const red32 = Color(0xFFFFF3F4);
  static const red52 = Color(0xFFFDECEE);
  static const red120 = Color(0xFFF4D6D4);
  static const red221 = Color(0xFFF4AFAF);
  static const red397 = Color(0xFFE0706B);
  static const red340 = Color(0xFFF0807A);
  static const red516 = Color(0xFFC44A46);
  static const red551 = Color(0xFFD70015);
  static const red562 = Color(0xFFB2423E);
  static const red590 = Color(0xFFC1121F);
  static const red599 = Color(0xFFA33C38);
  static const red617 = Color(0xFFB80012);
  static const red740 = Color(0xFF7A1420);
  static const red759 = Color(0xFF5A2C2A);
  static const red854 = Color(0xFF33201F);
  static const red868 = Color(0xFF2E1E1D);
  static const teal34 = Color(0xFFEFF7F5);
  static const teal59 = Color(0xFFE4F1EE);
  static const teal88 = Color(0xFFBFF0E4);
  static const teal66 = Color(0xFFD7F2EA);
  static const teal86 = Color(0xFFD6EBE6);
  static const teal194 = Color(0xFF7FD8C6);
  static const teal281 = Color(0xFF4CC3AC);
  static const teal359 = Color(0xFF44AC97);
  static const teal385 = Color(0xFF52A294);
  static const teal426 = Color(0xFF409889);
  static const teal438 = Color(0xFF3C9583);
  static const teal454 = Color(0xFF14937D);
  static const teal466 = Color(0xFF2E8E7E);
  static const teal483 = Color(0xFF0E8B76);
  static const teal504 = Color(0xFF0F8571);
  static const teal505 = Color(0xFF1D8473);
  static const teal517 = Color(0xFF337F70);
  static const teal544 = Color(0xFF0B7A68);
  static const gray550 = Color(0xFF5E6E6A);
  static const teal554 = Color(0xFF2E7566);
  static const teal603 = Color(0xFF086A5A);
  static const teal655 = Color(0xFF075C4E);
  static const teal682 = Color(0xFF075548);
  static const teal712 = Color(0xFF0A4D42);
  static const teal771 = Color(0xFF1E3C35);
  static const teal810 = Color(0xFF18332D);

  static const light = PantasColors(
    bgPage: gray34,
    surfaceCard: gray0,
    surfaceModal: gray0,
    surfaceInset: gray14,
    surfaceHover: gray27,
    surfaceModalHover: gray27,
    fill: gray62,
    fillSkeleton: gray96,
    surfaceSegmentOn: gray0,
    edgeCard: Color(0x00000000),
    edgeBar: Color(0x0F000000),
    textPrimary: gray892,
    textSecondary: gray534,
    textOnFill: gray579,
    textOnTintSecondary: gray550,
    textDisabled: gray288,
    iconMuted: gray424,
    iconChevron: gray408,
    divider: gray96,
    dividerStrong: gray160,
    borderControl: gray424,
    accent: teal544,
    accentFill: teal544,
    accentFillHover: teal603,
    accentHover: teal603,
    accentTint: teal59,
    accentTintHover: teal86,
    accentTintText: teal544,
    onAccent: gray0,
    kbdOnFill: Color(0x29000000),
    accentBar: teal34,
    danger: red551,
    dangerText: red551,
    dangerTextHover: red617,
    dangerFill: red551,
    dangerFillHover: red617,
    dangerTint: red52,
    dangerBar: red32,
    dangerMuted: red221,
    onDanger: gray0,
    warningText: amber541,
    warningTint: amber41,
    warningTintText: amber541,
    pro: gold296,
    onPro: gray892,
    switchOff: gray96,
    switchThumb: gray0,
    toastBg: gray892,
    toastText: gray0,
    toastAction: teal194,
    toastActionHover: Color(0x1AFFFFFF),
    scrim: Color(0x521D1D1F),
    scrimSearch: Color(0x381D1D1F),
    liquidStart: teal454,
    liquidEnd: teal544,
    heroStart: teal483,
    heroMid: teal544,
    heroEnd: teal682,
    topicDoneEnd: teal655,
    shareEnd: teal712,
    onHero: gray0,
    onHeroSecondary: teal88,
    chart1: teal385,
    chart2: teal426,
    chart3: teal466,
    chart4: teal505,
    chart5: teal544,
    figureBg: gray0,
    figureReaderBg: gray18,
    figureViewerBg: gray1000,
    figureOnViewer: gray0,
    figureScrim: Color(0xE00A0A0C),
    figureCaption: gray160,
    readerBody: gray744,
    readerStrong: gray948,
    readerDeep: gray34,
    readerNoteText: teal712,
    readerMistake: red590,
    readerMistakeTint: red52,
    readerMistakeText: red740,
  );

  static const dark = PantasColors(
    bgPage: gray932,
    surfaceCard: gray882,
    surfaceModal: gray829,
    surfaceInset: gray882,
    surfaceHover: gray829,
    surfaceModalHover: Color(0x0FFFFFFF),
    fill: gray800,
    fillSkeleton: gray742,
    surfaceSegmentOn: gray685,
    edgeCard: gray829,
    edgeBar: gray801,
    textPrimary: gray35,
    textSecondary: gray330,
    textOnFill: gray330,
    textOnTintSecondary: gray330,
    textDisabled: gray548,
    iconMuted: gray387,
    iconChevron: gray387,
    divider: gray801,
    dividerStrong: gray742,
    borderControl: gray408,
    accent: teal281,
    accentFill: teal504,
    accentFillHover: teal544,
    accentHover: teal194,
    accentTint: teal810,
    accentTintHover: teal771,
    accentTintText: teal194,
    onAccent: gray0,
    kbdOnFill: Color(0x29000000),
    accentBar: teal810,
    danger: red516,
    dangerText: red397,
    dangerTextHover: red340,
    dangerFill: red562,
    dangerFillHover: red599,
    dangerTint: red854,
    dangerBar: red868,
    dangerMuted: red759,
    onDanger: gray0,
    warningText: amber268,
    warningTint: amber830,
    warningTintText: amber188,
    pro: gold296,
    onPro: gray892,
    switchOff: gray742,
    switchThumb: gray0,
    toastBg: gray755,
    toastText: gray0,
    toastAction: teal194,
    toastActionHover: Color(0x1AFFFFFF),
    scrim: Color(0x7A000000),
    scrimSearch: Color(0x66000000),
    liquidStart: teal454,
    liquidEnd: teal544,
    heroStart: teal483,
    heroMid: teal544,
    heroEnd: teal682,
    topicDoneEnd: teal655,
    shareEnd: teal712,
    onHero: gray0,
    onHeroSecondary: teal88,
    chart1: teal554,
    chart2: teal517,
    chart3: teal438,
    chart4: teal359,
    chart5: teal281,
    figureBg: gray0,
    figureReaderBg: gray18,
    figureViewerBg: gray1000,
    figureOnViewer: gray0,
    figureScrim: Color(0xE00A0A0C),
    figureCaption: gray160,
    readerBody: gray189,
    readerStrong: gray0,
    readerDeep: gray912,
    readerNoteText: teal66,
    readerMistake: red397,
    readerMistakeTint: red868,
    readerMistakeText: red120,
  );

  @override
  PantasColors copyWith({
    Color? bgPage,
    Color? surfaceCard,
    Color? surfaceModal,
    Color? surfaceInset,
    Color? surfaceHover,
    Color? surfaceModalHover,
    Color? fill,
    Color? fillSkeleton,
    Color? surfaceSegmentOn,
    Color? edgeCard,
    Color? edgeBar,
    Color? textPrimary,
    Color? textSecondary,
    Color? textOnFill,
    Color? textOnTintSecondary,
    Color? textDisabled,
    Color? iconMuted,
    Color? iconChevron,
    Color? divider,
    Color? dividerStrong,
    Color? borderControl,
    Color? accent,
    Color? accentFill,
    Color? accentFillHover,
    Color? accentHover,
    Color? accentTint,
    Color? accentTintHover,
    Color? accentTintText,
    Color? onAccent,
    Color? kbdOnFill,
    Color? accentBar,
    Color? danger,
    Color? dangerText,
    Color? dangerTextHover,
    Color? dangerFill,
    Color? dangerFillHover,
    Color? dangerTint,
    Color? dangerBar,
    Color? dangerMuted,
    Color? onDanger,
    Color? warningText,
    Color? warningTint,
    Color? warningTintText,
    Color? pro,
    Color? onPro,
    Color? switchOff,
    Color? switchThumb,
    Color? toastBg,
    Color? toastText,
    Color? toastAction,
    Color? toastActionHover,
    Color? scrim,
    Color? scrimSearch,
    Color? liquidStart,
    Color? liquidEnd,
    Color? heroStart,
    Color? heroMid,
    Color? heroEnd,
    Color? topicDoneEnd,
    Color? shareEnd,
    Color? onHero,
    Color? onHeroSecondary,
    Color? chart1,
    Color? chart2,
    Color? chart3,
    Color? chart4,
    Color? chart5,
    Color? figureBg,
    Color? figureReaderBg,
    Color? figureViewerBg,
    Color? figureOnViewer,
    Color? figureScrim,
    Color? figureCaption,
    Color? readerBody,
    Color? readerStrong,
    Color? readerDeep,
    Color? readerNoteText,
    Color? readerMistake,
    Color? readerMistakeTint,
    Color? readerMistakeText,
  }) =>
      PantasColors(
        bgPage: bgPage ?? this.bgPage,
        surfaceCard: surfaceCard ?? this.surfaceCard,
        surfaceModal: surfaceModal ?? this.surfaceModal,
        surfaceInset: surfaceInset ?? this.surfaceInset,
        surfaceHover: surfaceHover ?? this.surfaceHover,
        surfaceModalHover: surfaceModalHover ?? this.surfaceModalHover,
        fill: fill ?? this.fill,
        fillSkeleton: fillSkeleton ?? this.fillSkeleton,
        surfaceSegmentOn: surfaceSegmentOn ?? this.surfaceSegmentOn,
        edgeCard: edgeCard ?? this.edgeCard,
        edgeBar: edgeBar ?? this.edgeBar,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textOnFill: textOnFill ?? this.textOnFill,
        textOnTintSecondary: textOnTintSecondary ?? this.textOnTintSecondary,
        textDisabled: textDisabled ?? this.textDisabled,
        iconMuted: iconMuted ?? this.iconMuted,
        iconChevron: iconChevron ?? this.iconChevron,
        divider: divider ?? this.divider,
        dividerStrong: dividerStrong ?? this.dividerStrong,
        borderControl: borderControl ?? this.borderControl,
        accent: accent ?? this.accent,
        accentFill: accentFill ?? this.accentFill,
        accentFillHover: accentFillHover ?? this.accentFillHover,
        accentHover: accentHover ?? this.accentHover,
        accentTint: accentTint ?? this.accentTint,
        accentTintHover: accentTintHover ?? this.accentTintHover,
        accentTintText: accentTintText ?? this.accentTintText,
        onAccent: onAccent ?? this.onAccent,
        kbdOnFill: kbdOnFill ?? this.kbdOnFill,
        accentBar: accentBar ?? this.accentBar,
        danger: danger ?? this.danger,
        dangerText: dangerText ?? this.dangerText,
        dangerTextHover: dangerTextHover ?? this.dangerTextHover,
        dangerFill: dangerFill ?? this.dangerFill,
        dangerFillHover: dangerFillHover ?? this.dangerFillHover,
        dangerTint: dangerTint ?? this.dangerTint,
        dangerBar: dangerBar ?? this.dangerBar,
        dangerMuted: dangerMuted ?? this.dangerMuted,
        onDanger: onDanger ?? this.onDanger,
        warningText: warningText ?? this.warningText,
        warningTint: warningTint ?? this.warningTint,
        warningTintText: warningTintText ?? this.warningTintText,
        pro: pro ?? this.pro,
        onPro: onPro ?? this.onPro,
        switchOff: switchOff ?? this.switchOff,
        switchThumb: switchThumb ?? this.switchThumb,
        toastBg: toastBg ?? this.toastBg,
        toastText: toastText ?? this.toastText,
        toastAction: toastAction ?? this.toastAction,
        toastActionHover: toastActionHover ?? this.toastActionHover,
        scrim: scrim ?? this.scrim,
        scrimSearch: scrimSearch ?? this.scrimSearch,
        liquidStart: liquidStart ?? this.liquidStart,
        liquidEnd: liquidEnd ?? this.liquidEnd,
        heroStart: heroStart ?? this.heroStart,
        heroMid: heroMid ?? this.heroMid,
        heroEnd: heroEnd ?? this.heroEnd,
        topicDoneEnd: topicDoneEnd ?? this.topicDoneEnd,
        shareEnd: shareEnd ?? this.shareEnd,
        onHero: onHero ?? this.onHero,
        onHeroSecondary: onHeroSecondary ?? this.onHeroSecondary,
        chart1: chart1 ?? this.chart1,
        chart2: chart2 ?? this.chart2,
        chart3: chart3 ?? this.chart3,
        chart4: chart4 ?? this.chart4,
        chart5: chart5 ?? this.chart5,
        figureBg: figureBg ?? this.figureBg,
        figureReaderBg: figureReaderBg ?? this.figureReaderBg,
        figureViewerBg: figureViewerBg ?? this.figureViewerBg,
        figureOnViewer: figureOnViewer ?? this.figureOnViewer,
        figureScrim: figureScrim ?? this.figureScrim,
        figureCaption: figureCaption ?? this.figureCaption,
        readerBody: readerBody ?? this.readerBody,
        readerStrong: readerStrong ?? this.readerStrong,
        readerDeep: readerDeep ?? this.readerDeep,
        readerNoteText: readerNoteText ?? this.readerNoteText,
        readerMistake: readerMistake ?? this.readerMistake,
        readerMistakeTint: readerMistakeTint ?? this.readerMistakeTint,
        readerMistakeText: readerMistakeText ?? this.readerMistakeText,
      );

  @override
  PantasColors lerp(ThemeExtension<PantasColors>? other, double t) {
    if (other is! PantasColors) return this;
    return PantasColors(
      bgPage: Color.lerp(bgPage, other.bgPage, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceModal: Color.lerp(surfaceModal, other.surfaceModal, t)!,
      surfaceInset: Color.lerp(surfaceInset, other.surfaceInset, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      surfaceModalHover:
          Color.lerp(surfaceModalHover, other.surfaceModalHover, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      fillSkeleton: Color.lerp(fillSkeleton, other.fillSkeleton, t)!,
      surfaceSegmentOn:
          Color.lerp(surfaceSegmentOn, other.surfaceSegmentOn, t)!,
      edgeCard: Color.lerp(edgeCard, other.edgeCard, t)!,
      edgeBar: Color.lerp(edgeBar, other.edgeBar, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textOnFill: Color.lerp(textOnFill, other.textOnFill, t)!,
      textOnTintSecondary:
          Color.lerp(textOnTintSecondary, other.textOnTintSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t)!,
      iconChevron: Color.lerp(iconChevron, other.iconChevron, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      dividerStrong: Color.lerp(dividerStrong, other.dividerStrong, t)!,
      borderControl: Color.lerp(borderControl, other.borderControl, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentFill: Color.lerp(accentFill, other.accentFill, t)!,
      accentFillHover: Color.lerp(accentFillHover, other.accentFillHover, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      accentTintHover: Color.lerp(accentTintHover, other.accentTintHover, t)!,
      accentTintText: Color.lerp(accentTintText, other.accentTintText, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      kbdOnFill: Color.lerp(kbdOnFill, other.kbdOnFill, t)!,
      accentBar: Color.lerp(accentBar, other.accentBar, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerText: Color.lerp(dangerText, other.dangerText, t)!,
      dangerTextHover: Color.lerp(dangerTextHover, other.dangerTextHover, t)!,
      dangerFill: Color.lerp(dangerFill, other.dangerFill, t)!,
      dangerFillHover: Color.lerp(dangerFillHover, other.dangerFillHover, t)!,
      dangerTint: Color.lerp(dangerTint, other.dangerTint, t)!,
      dangerBar: Color.lerp(dangerBar, other.dangerBar, t)!,
      dangerMuted: Color.lerp(dangerMuted, other.dangerMuted, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      warningTint: Color.lerp(warningTint, other.warningTint, t)!,
      warningTintText: Color.lerp(warningTintText, other.warningTintText, t)!,
      pro: Color.lerp(pro, other.pro, t)!,
      onPro: Color.lerp(onPro, other.onPro, t)!,
      switchOff: Color.lerp(switchOff, other.switchOff, t)!,
      switchThumb: Color.lerp(switchThumb, other.switchThumb, t)!,
      toastBg: Color.lerp(toastBg, other.toastBg, t)!,
      toastText: Color.lerp(toastText, other.toastText, t)!,
      toastAction: Color.lerp(toastAction, other.toastAction, t)!,
      toastActionHover:
          Color.lerp(toastActionHover, other.toastActionHover, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      scrimSearch: Color.lerp(scrimSearch, other.scrimSearch, t)!,
      liquidStart: Color.lerp(liquidStart, other.liquidStart, t)!,
      liquidEnd: Color.lerp(liquidEnd, other.liquidEnd, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroMid: Color.lerp(heroMid, other.heroMid, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      topicDoneEnd: Color.lerp(topicDoneEnd, other.topicDoneEnd, t)!,
      shareEnd: Color.lerp(shareEnd, other.shareEnd, t)!,
      onHero: Color.lerp(onHero, other.onHero, t)!,
      onHeroSecondary: Color.lerp(onHeroSecondary, other.onHeroSecondary, t)!,
      chart1: Color.lerp(chart1, other.chart1, t)!,
      chart2: Color.lerp(chart2, other.chart2, t)!,
      chart3: Color.lerp(chart3, other.chart3, t)!,
      chart4: Color.lerp(chart4, other.chart4, t)!,
      chart5: Color.lerp(chart5, other.chart5, t)!,
      figureBg: Color.lerp(figureBg, other.figureBg, t)!,
      figureReaderBg: Color.lerp(figureReaderBg, other.figureReaderBg, t)!,
      figureViewerBg: Color.lerp(figureViewerBg, other.figureViewerBg, t)!,
      figureOnViewer: Color.lerp(figureOnViewer, other.figureOnViewer, t)!,
      figureScrim: Color.lerp(figureScrim, other.figureScrim, t)!,
      figureCaption: Color.lerp(figureCaption, other.figureCaption, t)!,
      readerBody: Color.lerp(readerBody, other.readerBody, t)!,
      readerStrong: Color.lerp(readerStrong, other.readerStrong, t)!,
      readerDeep: Color.lerp(readerDeep, other.readerDeep, t)!,
      readerNoteText: Color.lerp(readerNoteText, other.readerNoteText, t)!,
      readerMistake: Color.lerp(readerMistake, other.readerMistake, t)!,
      readerMistakeTint:
          Color.lerp(readerMistakeTint, other.readerMistakeTint, t)!,
      readerMistakeText:
          Color.lerp(readerMistakeText, other.readerMistakeText, t)!,
    );
  }
}
