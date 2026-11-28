// Findings the gate accepts, in the style of tool/checks: each one names the
// item, why, who owns it and when it was accepted. An accepted finding is
// printed and never fails the run. Add one only on the lead's ruling.
class AcceptedFinding {
  const AcceptedFinding({
    required this.id,
    required this.check,
    required this.reason,
    required this.owner,
    required this.date,
  });

  final String id;
  final String check;
  final String reason;
  final String owner;
  final String date;
}

const acceptedFindings = <AcceptedFinding>[
  AcceptedFinding(
    id: 'lessons/reading-comprehension/text-types/visual-media.md',
    check: 'upload',
    reason: "main's stale copy over the 900,000-byte document limit; prod "
        'serves the split content branch version, which passes the gate',
    owner: 'content lanes, at the next content merge to main',
    date: 'Nov 23 2026',
  ),
  AcceptedFinding(
    id: 'lessons/science/earth-science-astronomy/layers-of-the-earth.md',
    check: 'upload',
    reason: "main's stale copy over the 900,000-byte document limit; prod "
        'serves the split content branch version, which passes the gate',
    owner: 'content lanes, at the next content merge to main',
    date: 'Nov 23 2026',
  ),
];
