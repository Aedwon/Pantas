/// The screen 1 specimen. Every student sees these same figures.
///
/// Decided 4 August 2026: the paywall must not fill this panel with the
/// student's own numbers, because that gives away a real Pro insight in
/// order to sell Pro. These figures are authored and are marked as a sample
/// on screen, twice, both times above the figures themselves.
///
/// The panel name and both labels are the ones the tendency deck ships, so
/// the sample demonstrates a surface that exists. Only the figures are
/// authored.
class ProSpecimen {
  const ProSpecimen({
    required this.panelName,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftFigure,
    required this.rightFigure,
    required this.sentence,
  });

  final String panelName;
  final String leftLabel;
  final String rightLabel;
  final int leftFigure;
  final int rightFigure;
  final String sentence;

  int get gapFigure => leftFigure - rightFigure;
}

const proSpecimen = ProSpecimen(
  panelName: 'Under pressure',
  leftLabel: 'practicing',
  rightLabel: 'under time',
  leftFigure: 68,
  rightFigure: 54,
  sentence: 'You score 14 lower under time than when practicing. '
      'That is the biggest gap in your work.',
);
