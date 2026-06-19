# Platform foundations: the things a shipped app has that a feature set does not

**Date:** 3 August 2026
**Status:** Written to Aedwon's instruction of 3 August, "for other things, do what you
recommend as a fix".
**Why it exists:** the plan audit found four Firebase packages declared in `pubspec.yaml` and
imported by **zero** files in `lib/`, no error boundary anywhere, no way to force an update,
localization scaffolding that is declared and unbuilt, and no accessibility rules for an
identity built entirely out of typography. None of it appears in any spec.

This spec describes the destination. It assumes nothing in the tree survives.

---

## Section 1: What is declared and never wired

Verified against the tree on 3 August. `grep -rl "package:<name>" lib/` returns nothing for
all four.

| Package | In pubspec | Files in `lib/` importing it | Consequence today |
|---|---|---|---|
| `firebase_crashlytics` | yes | **0** | No crash is ever reported |
| `firebase_analytics` | yes | **0** | No event is ever recorded |
| `firebase_app_check` | yes | **0** | Firestore and Functions accept any client |
| `firebase_remote_config` | yes | **0** | No kill switch, no version gate |

**A fifth, worse one, found the same day:** `purchases_flutter` is in `pubspec.yaml` and
imported by **0** files in `lib/`. The only implementation of `RevenueCatGateway` is
`DisabledRevenueCatGateway`, whose `purchase()` and `restorePurchases()` both return
`Entitlement.free()`. **The app cannot take money.** That belongs to the paywall rebuild and
is recorded here only so the count of unwired packages is honest.

## Section 2: Crash reporting

**Crashlytics is initialized in `bootstrap`, before anything can throw.**

**Three collectors, because Flutter throws in three places and missing one is the usual
mistake:**

1. `FlutterError.onError` for errors inside the widget framework.
2. `PlatformDispatcher.instance.onError` for errors outside it.
3. A guarded zone around `runApp` for asynchronous errors that escape both.

**None of these exist in `lib/` today.** An uncaught exception currently shows a student the
framework error screen and nobody is ever told.

**The switch governs it, honestly.** Settings' "Help improve the app" is the student's
consent, and consent that does nothing is worse than no switch at all.

| Switch | Crash reports | Analytics |
|---|---|---|
| On | Collected | Collected |
| Off | **Not collected** | **Not collected** |
| Before the student has answered | **Not collected** | **Not collected** |

**Off by default until answered.** RA10173 makes this the safe reading, and the Settings spec
already writes the switch with a crash-report lede, so the copy exists.

**A crash report carries no answer, no score, no name and no email.** It carries the stack,
the build, the device and the route. That constraint is a promise the About page's lede makes
and it must be true.

## Section 3: Analytics, and the discipline it needs

**Analytics exists to answer questions you have already written down.** Without that rule it
becomes a landfill of events nobody reads, and it costs a privacy disclosure to keep.

**The questions this app needs answered at launch**, and nothing beyond them:

| Question | The event that answers it |
|---|---|
| Do students finish onboarding? | Onboarding step reached, onboarding completed |
| Do they come back? | Session started, with its origin |
| Does anyone reach the paywall? | Paywall shown, with what triggered it |
| Does anyone buy? | Purchase started, purchase completed, purchase failed |
| Which surfaces are dead? | Tab opened, per tab |
| Does the mock work at all? | Mock started, mock completed, mock abandoned |

**Six questions, and every event traces to one.** An event that answers no question on this
list does not get added.

**No event carries a question's text, a student's answer, a score, a name, an email or a
free-text field.** Counts and identifiers only.

**Analytics is never a source for a figure shown to a student.** The never-invent-a-figure
rule already bans it, and this is where the temptation would arrive.

## Section 4: App Check

**Enabled and enforced in dev and prod**, with Play Integrity on release builds and the debug
provider on dev.

`docs/OPERATIONS.md` has carried a checkbox for this since May, unticked and unbuilt. Without
it, `getProContent`, `exportData`, `deleteAccount` and every Firestore rule are protected by
authentication alone, which any client holding the config can present.

**It rolls out in monitor mode first**, then enforced, because enforcing it against a client
that is not yet attesting locks out the whole user base. That ordering is an operations item,
not a code one, and it lands in the launch checklist.

## Section 5: Force update, and the kill switch

**Remote Config holds two values and nothing else at launch:**

| Key | Meaning |
|---|---|
| `minimum_supported_build` | Below this, the app is blocked |
| `service_message` | Optional, a single line shown on Home when set |

**Why this matters more than usual here.** Entitlement arrives by webhook and content ships
in the build. A build that gets either wrong is installed on devices you cannot reach, and
without this there is no lever at all.

**The block is a full-screen stop, not a dismissible prompt.** One line, one button to the
store. It is the only modal in the app that a student cannot dismiss, and that is justified
only because the alternative is an app that is actively wrong.

**Copy:** "Pantas needs an update to keep working." Button: "Update". Grade-5-simple, no em
dashes, no version numbers, no changelog.

**Fail open.** If Remote Config cannot be reached, the app runs. A version gate that blocks
the app when the network is down would violate Section 1 of the offline spec and would be a
self-inflicted outage.

## Section 6: Localization scaffolding

**English UI for v1. Filipino rolls out in later versions.** Aedwon's ruling, 3 August. The
only non-English string today is the "Magandang [time of day]" greeting.

**Because Filipino is coming, the scaffolding is finished rather than removed.** `pubspec.yaml`
already sets `generate: true` and depends on `flutter_localizations`, and there is no
`l10n.yaml`, no `lib/l10n/` and no `.arb` file. Half-built is the worst of the three states.

**What v1 builds:** `l10n.yaml`, one `app_en.arb`, and the greeting moved into it. **Nothing
else is extracted.** Extracting several hundred strings for a single locale is work with no
reader, and it would collide with every unexecuted UI plan in the queue.

**The greeting is a live constraint on the Home masthead**, built by
`plans/2026-08-02-home-03-masthead-and-band.md`.

## Section 7: Accessibility

**The identity is the risk.** Ink and Rule is hairline rules, two typefaces, tight vertical
rhythm and meaning carried by weight. Every one of those is a thing that breaks under large
text, and this app has two files in `lib/` that touch `Semantics` or text scaling.

**Four rules, and they are testable:**

1. **The app is readable at 200% text scale.** Every screen, no clipping, no overlap, no text
   truncated to an ellipsis where the full string carries meaning. Rules and rhythm may
   stretch; nothing may be cut.
2. **Every tap target is at least 44 by 44.** `settings-01` already establishes the pattern
   of a smaller visual box inside a larger tappable one. That pattern generalizes and is the
   answer everywhere the identity wants a 38-tall row.
3. **Color is never the only carrier.** This is already the identity's rule, stated as a
   design principle, and it becomes an accessibility requirement here. Severity is rust, then
   amber, then plain ink, and it must also be readable as a word or a position.
4. **Every control has a semantics label.** The three icons in `ThemeControl` are the whole
   icon budget of the application and they are exactly the controls with no text to read.

**Contrast is checked against the paper background in both themes**, not against white.

**Play runs a pre-launch report on every upload and it checks tap targets, contrast and
labels.** Failing it is not a rejection, but it is a written record that the app is
inaccessible, on the store listing's own dashboard.

## Section 8: Support, feedback and the review prompt

**The feedback row needs a destination.** `plans/2026-08-03-settings-06-about-and-the-pushed-pages.md`
builds the row and points it nowhere.

**Decided 3 August: it opens a community group, not a mail composer.** Aedwon's reasoning, and
it is sound for this market: Facebook is ubiquitous in the Philippines, so a group is where
students already are, and it consolidates feedback and discussion in one place instead of
scattering both across a hundred one-to-one threads. A Discord server is the alternative he is
weighing; the row does not care which, it opens a URL.

**What this changes, and it is not nothing:**

1. **The row opens an external link.** That needs `url_launcher`, which is not in
   `pubspec.yaml`. It is the same dependency the force-update button needs, so it is one
   decision covering both.
2. **The prefill disappears.** A group post carries no build number and no device model, so
   the "what version are you on" question moves to whoever answers in the group. Nothing is
   collected and nothing is sent, which makes this the more private option of the two.
3. **Play still requires a developer contact email on the listing**, separately from anything
   in the app. A group does not satisfy that. It stays on the launch checklist as Aedwon's.
4. **A group is a moderation commitment**, and a public one is a place where a student can
   post something identifying about themselves. Raised, not an objection: it is the normal
   cost of the format and he has chosen it knowingly.

**The row's copy names the destination plainly**, because sending a student out of the app
without saying where is worse than not offering it. No form, no third-party SDK, no in-app
ticketing.

**The review prompt.** Not in any spec, and it is the main lever on store ranking.

**It is asked once, and only after something went well.** Never on launch, never on a
paywall, never after a failure. The honest moment is **after a finished mock or a completed
session where the student did well**, because that is when the question is a real one and not
an interruption.

**Never ask a student who has just seen the paywall.** Ranking bought by asking at a moment of
friction is a worse deal than it looks.

## Section 9: The error boundary is the cheapest item here

One guarded zone, three collectors, and a replacement for the framework's red error screen
that says one line in the app's voice instead of a stack trace.

**It costs a few dozen lines and it is the difference between hearing about a defect and not.**
It is listed last because it is small, and it should be built first.

## Section 10: Evidentiary tier

Nothing in this spec prints a figure to a student. Analytics counts are for Aedwon and never
travel back into the app. `minimum_supported_build` is compared, never displayed.

## Deferred, with reasons

- **Performance tracing.** Firebase Performance is not in `pubspec.yaml` and adding a package
  to measure a problem nobody has reported is the wrong order. The first-run seed timing in
  the content spec is the one measurement that is actually owed.
- **A/B testing through Remote Config.** Two keys, no experiments, until there is a question
  worth splitting traffic over.
- **In-app ticketing and a help center.** A mail intent is the correct size for one person
  supporting a launch.
- **Deep links beyond the notification payload.** Nothing outside the app links into it yet.
