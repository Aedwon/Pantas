import 'dart:async';

/// What the browser offers for adding Pantas to the device.
enum InstallPath {
  /// No way to install here, or Pantas is already installed.
  none,

  /// The browser fired its own install event and Pantas can open its dialog.
  native,

  /// iPhone Safari has no install event, so Pantas shows the three steps.
  iosInstructions,
}

/// How the browser answered its own install dialog.
enum InstallPromptResult { accepted, dismissed, unavailable }

/// The browser facts the install card depends on. A fake implements it in
/// tests. The web implementation reads the real browser.
abstract interface class InstallPlatform {
  /// True when Pantas already runs as an installed app (display-mode
  /// standalone, or the iOS standalone flag).
  bool get isStandalone;

  /// True on iPhone or iPad Safari, the only iOS browser with the steps shown.
  bool get isIosSafari;

  /// True while the browser has handed Pantas an install event to use.
  bool get hasNativePrompt;

  /// True once the browser reported that Pantas was installed (the
  /// `appinstalled` event).
  bool get installedThisSession;

  /// Fires when [hasNativePrompt] or the installed state changes.
  Stream<void> get changes;

  /// Opens the browser's own install dialog. Needs a user tap.
  Future<InstallPromptResult> promptInstall();

  /// Asks the browser to keep Pantas storage. Returns true when it will.
  Future<bool> requestPersistentStorage();

  /// Starts listening for install events. Safe to call more than once.
  void start();
}

/// Remembers, per browser, what the learner did with the install card.
abstract interface class InstallMemory {
  int get dismissals;
  DateTime? get lastDismissedAt;
  bool get installed;
  void recordDismissal(DateTime at);
  void recordInstalled();
  void clearInstalled();
}

class InMemoryInstallMemory implements InstallMemory {
  InMemoryInstallMemory({
    this.dismissals = 0,
    this.lastDismissedAt,
    this.installed = false,
  });

  @override
  int dismissals;
  @override
  DateTime? lastDismissedAt;
  @override
  bool installed;

  @override
  void recordDismissal(DateTime at) {
    dismissals += 1;
    lastDismissedAt = at;
  }

  @override
  void recordInstalled() => installed = true;

  @override
  void clearInstalled() => installed = false;
}

/// A browser or device that offers no install path at all.
class UnsupportedInstallPlatform implements InstallPlatform {
  const UnsupportedInstallPlatform();

  @override
  bool get isStandalone => false;
  @override
  bool get isIosSafari => false;
  @override
  bool get hasNativePrompt => false;
  @override
  bool get installedThisSession => false;
  @override
  Stream<void> get changes => const Stream<void>.empty();
  @override
  Future<InstallPromptResult> promptInstall() async =>
      InstallPromptResult.unavailable;
  @override
  Future<bool> requestPersistentStorage() async => false;
  @override
  void start() {}
}

/// "Not Now" hides the card for this long. A second "Not Now" stops it.
const installSnoozeDuration = Duration(days: 30);

/// The install path the browser offers right now, ignoring what the learner
/// already said. Already running installed, or already installed in this
/// browser, means none. A live browser install event always wins over the
/// remembered install, because that event only fires when Pantas is not
/// installed (the learner may have removed it).
InstallPath installPathFor(InstallPlatform platform, InstallMemory memory) {
  if (platform.isStandalone) return InstallPath.none;
  if (platform.hasNativePrompt) return InstallPath.native;
  if (memory.installed) return InstallPath.none;
  if (platform.isIosSafari) return InstallPath.iosInstructions;
  return InstallPath.none;
}

/// True while "Not Now" still hides the card.
bool installPromptSnoozed({
  required int dismissals,
  required DateTime? lastDismissedAt,
  required DateTime now,
}) {
  if (dismissals >= 2) return true;
  if (dismissals == 0 || lastDismissedAt == null) return false;
  return now.isBefore(lastDismissedAt.add(installSnoozeDuration));
}

/// The facts [isIosSafariEnvironment] reads from the browser.
class InstallEnvironment {
  const InstallEnvironment({
    required this.userAgent,
    this.platform = '',
    this.maxTouchPoints = 0,
  });

  final String userAgent;
  final String platform;
  final int maxTouchPoints;
}

final _otherIosBrowsers = RegExp(
  'CriOS|FxiOS|EdgiOS|OPiOS|OPT/|GSA/|DuckDuckGo|YaBrowser|SamsungBrowser',
);

/// iPhone, iPod or iPad running Safari itself. Other iOS browsers and in-app
/// browsers are left out because the three steps are Safari's. iPadOS reports
/// a Mac user agent, so a touch screen on a "MacIntel" platform counts as iPad.
bool isIosSafariEnvironment(InstallEnvironment env) {
  final ua = env.userAgent;
  final iPhone = ua.contains('iPhone') || ua.contains('iPod');
  final iPad = ua.contains('iPad') ||
      (env.platform == 'MacIntel' && env.maxTouchPoints > 1);
  if (!iPhone && !iPad) return false;
  if (_otherIosBrowsers.hasMatch(ua)) return false;
  return ua.contains('Safari/') && ua.contains('Version/');
}
