/// The age group stored on this device, as a typed value.
///
/// Restricted by default: only [adult] and [unset] are free of the limits.
/// `child` and any value this build does not recognize are restricted at least
/// as strictly as `minor`, so an unexpected value can never open a door.
enum AgeGroup {
  /// No age was recorded on this device.
  unset,

  /// 18 or older.
  adult,

  /// 13 to 17. A guardian confirms through the emailed link.
  minor,

  /// Under 13. A parent or guardian holds the account. Only the server sets it.
  child,

  /// A stored value this build does not know. Treated as restricted.
  unrecognized;

  /// Reads the stored text. `null` is [unset]; unknown text is [unrecognized].
  static AgeGroup parse(String? stored) => switch (stored) {
        null => AgeGroup.unset,
        'adult' => AgeGroup.adult,
        'minor' => AgeGroup.minor,
        'child' => AgeGroup.child,
        _ => AgeGroup.unrecognized,
      };

  /// Under every limit that applies below 18: no usage sharing, no share
  /// cards, and the purchase box.
  bool get isRestricted => this != unset && this != adult;

  /// A child account. Its own limits come on top of [isRestricted].
  bool get isChild => this == child;

  /// The 13 to 17 guardian-link flow (waiting page, contact form). A child is
  /// held by a parent through setup and never enters it. An unrecognized value
  /// does, because it must be at least as strict as `minor`.
  bool get entersTeenGuardianFlow => this == minor || this == unrecognized;

  /// The parent or guardian box on a purchase.
  bool get needsPurchaseAttestation => isRestricted;

  /// "I'm 18 now" is for a known minor only. A child is never switched by the
  /// account itself.
  bool get canSelfSwitchToAdult => this == minor;
}
