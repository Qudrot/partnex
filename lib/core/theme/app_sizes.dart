/// Design tokens for spacing, sizing, and border radii.
/// Use these constants instead of hardcoded numeric values across
/// all widgets to keep the UI consistent and easy to adjust globally.
class AppSpacing {
  AppSpacing._();

  /// 4 dp — extra-small gap e.g. icon + label
  static const double xs = 4.0;

  /// 8 dp — small gap e.g. between related items
  static const double sm = 8.0;

  /// 12 dp — compact mid-gap
  static const double smd = 12.0;

  /// 16 dp — standard padding / gap
  static const double md = 16.0;

  /// 20 dp — slightly larger container padding
  static const double lg = 20.0;

  /// 24 dp — section-level vertical gap / screen horizontal padding
  static const double xl = 24.0;

  /// 32 dp — large section spacer
  static const double xxl = 32.0;

  /// 40 dp — extra-large spacer
  static const double xxxl = 40.0;

  /// 48 dp — hero-level spacer
  static const double xxxxl = 48.0;

  /// 64 dp — avatar / icon container sizes
  static const double avatar = 64.0;

  /// 80 dp — large icon container / illustration sizes
  static const double icon80 = 80.0;
}

/// Design tokens for border radii.
class AppRadius {
  AppRadius._();

  /// 4 dp — subtle rounding (badges, chips)
  static const double sm = 4.0;

  /// 8 dp — standard card / input rounding
  static const double md = 8.0;

  /// 12 dp — slightly generous rounding
  static const double lg = 12.0;

  /// 16 dp — prominent rounding (bottom-sheets, feature cards)
  static const double xl = 16.0;

  /// 24 dp — pill-like rounding
  static const double xxl = 24.0;

  /// 999 dp — fully circular (avatars, FABs)
  static const double circular = 999.0;
}
