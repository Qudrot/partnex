/// Partnex Design System - Enums and Constants
/// 
/// This file defines all enumerations and constant values used throughout
/// the Partnex application for type-safe design system usage.
class AppEnums {
  // ═══════════════════════════════════════════════════════════════════════════
  // SCORE TIERS - Credibility score classifications
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Score tier classification
  enum ScoreTier {
    strong,    // 75+
    good,      // 60-74
    moderate,  // 40-59
    weak,      // <40
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // RISK TIERS - Risk level classifications
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Risk tier classification
  enum RiskTier {
    low,       // Positive
    moderate,  // Caution
    high,      // Critical
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // BADGE VARIANTS - Badge style variations
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Badge variant styles
  enum BadgeVariant {
    brand,     // Primary blue
    positive,  // Success green
    caution,   // Warning orange
    critical,  // Error red
    info,      // Info cyan
    gray,      // Neutral gray
    dark,      // Dark background
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // BADGE SIZES - Badge size variations
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Badge size variants
  enum BadgeSize {
    small,     // 11px text, compact padding
    medium,    // 12px text, standard padding
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON VARIANTS - Button style variations
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Button variant styles
  enum ButtonVariant {
    primary,   // Solid blue background
    positive,  // Solid green background
    outline,   // Transparent with border
    ghost,     // Light background
    danger,    // Light red background with red border
    dark,      // Solid dark background
    ghostDark, // Transparent with light border (for dark backgrounds)
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON SIZES - Button size variations
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Button size variants
  enum ButtonSize {
    small,     // 8px 14px padding, 13px text
    medium,    // 13px 20px padding, 15px text
    large,     // 15px 20px padding, 16px text
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CARD VARIANTS - Card style variations
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Card variant styles
  enum CardVariant {
    elevated,  // White background with border
    filled,    // Light background
    outlined,  // Transparent with border
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // ICON TYPES - Icon identifiers for accessibility pairing
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Icon types used throughout the design system
  enum IconType {
    check,       // ✓ - Success/positive
    xmark,       // ✕ - Error/critical
    triangle,    // ⚠ - Warning/caution
    arrowUp,     // ↑ - Positive trend
    arrowDown,   // ↓ - Negative trend
    arrowLeft,   // ← - Back/previous
    arrowRight,  // → - Forward/next
    chevUp,      // ⌃ - Collapse
    chevDown,    // ⌄ - Expand
    info,        // ℹ - Information
    bell,        // 🔔 - Notifications
    star,        // ★ - Favorite/saved
    file,        // 📄 - Document
    folder,      // 📁 - Folder
    search,      // 🔍 - Search
    upload,      // ⬆ - Upload
    download,    // ⬇ - Download
    settings,    // ⚙ - Settings
    user,        // 👤 - User/profile
    logout,      // ⬅ - Logout
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // DOCUMENT TIERS - Document importance classification
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Document tier classification
  enum DocumentTier {
    critical,   // Required for score calculation
    high,       // High-value documents
    optional,   // Optional documents
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS - Standard animation timing
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Standard animation durations in milliseconds
  static const int animationDurationFast = 150;
  static const int animationDurationNormal = 300;
  static const int animationDurationSlow = 500;
  static const int animationDurationVerySlow = 1400;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // SHADOW ELEVATIONS - Shadow depth levels
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Shadow elevation levels
  enum ShadowElevation {
    none,      // No shadow
    sm,        // Small shadow (4px blur)
    md,        // Medium shadow (8px blur)
    lg,        // Large shadow (12px blur)
    xl,        // Extra large shadow (16px blur)
    xxl,       // 2x large shadow (24px blur)
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // BREAKPOINT HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Screen size classification
  enum ScreenSize {
    mobile,    // < 480px
    tablet,    // 480px - 768px
    desktop,   // > 768px
  }
}

/// Score tier information with icon and color pairing
class ScoreTierInfo {
  final String label;
  final String icon;
  final int minScore;
  final int maxScore;
  
  const ScoreTierInfo({
    required this.label,
    required this.icon,
    required this.minScore,
    required this.maxScore,
  });
}

/// Risk tier information with icon and color pairing
class RiskTierInfo {
  final String label;
  final String icon;
  final String level;
  
  const RiskTierInfo({
    required this.label,
    required this.icon,
    required this.level,
  });
}

/// Document tier information
class DocumentTierInfo {
  final String label;
  final String description;
  final int pointValue;
  
  const DocumentTierInfo({
    required this.label,
    required this.description,
    required this.pointValue,
  });
}
