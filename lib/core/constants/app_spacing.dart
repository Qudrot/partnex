/// Partnex Design System - Spacing & Sizing Constants
/// 
/// This file defines all spacing, padding, margin, and sizing values used
/// throughout the Partnex application. Following an 8px base unit system.
/// 
/// Design Philosophy:
/// - 8px base unit for consistency
/// - Scales: 4, 8, 12, 16, 20, 24, 28, 32, 40, 48, 56, 64, 80, 96
/// - Responsive adjustments for mobile, tablet, desktop
class AppSpacing {
  // ═══════════════════════════════════════════════════════════════════════════
  // BASE SPACING UNITS (8px system)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// 4px - Half unit, for micro spacing
  static const double xs = 4.0;
  
  /// 8px - Base unit, standard spacing
  static const double sm = 8.0;
  
  /// 12px - 1.5 units, small spacing
  static const double md = 12.0;
  
  /// 16px - 2 units, standard padding
  static const double lg = 16.0;
  
  /// 20px - 2.5 units, medium spacing
  static const double xl = 20.0;
  
  /// 24px - 3 units, large spacing
  static const double xxl = 24.0;
  
  /// 28px - 3.5 units, extra large spacing
  static const double xxxl = 28.0;
  
  /// 32px - 4 units, section spacing
  static const double huge = 32.0;
  
  /// 40px - 5 units, large section spacing
  static const double massive = 40.0;
  
  /// 48px - 6 units, hero spacing
  static const double enormous = 48.0;
  
  /// 56px - 7 units
  static const double gigantic = 56.0;
  
  /// 64px - 8 units
  static const double colossal = 64.0;
  
  /// 80px - 10 units
  static const double titanium = 80.0;
  
  /// 96px - 12 units
  static const double platinum = 96.0;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // COMPONENT SPACING - Specific to UI components
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Gap between icon and text in buttons/badges
  static const double iconTextGap = 6.0;
  
  /// Gap between items in lists
  static const double listItemGap = 8.0;
  
  /// Gap between form fields
  static const double formFieldGap = 12.0;
  
  /// Padding inside buttons
  static const double buttonPaddingSmall = 8.0;
  static const double buttonPaddingMedium = 13.0;
  static const double buttonPaddingLarge = 15.0;
  
  /// Padding inside cards
  static const double cardPadding = 16.0;
  
  /// Padding inside badges
  static const double badgePaddingSmall = 8.0;
  static const double badgePaddingMedium = 11.0;
  
  /// Padding inside labels
  static const double labelPadding = 6.0;
  
  /// Gap between tabs
  static const double tabGap = 10.0;
  
  /// Padding for top/bottom bars
  static const double barPadding = 12.0;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS - Corner rounding
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// 4px - Subtle rounding for small elements
  static const double radiusSm = 4.0;
  
  /// 8px - Standard rounding for buttons
  static const double radiusMd = 8.0;
  
  /// 10px - Rounding for cards and containers
  static const double radiusLg = 10.0;
  
  /// 12px - Rounding for larger containers
  static const double radiusXl = 12.0;
  
  /// 14px - Rounding for main cards
  static const double radiusXxl = 14.0;
  
  /// 20px - Rounding for badges and pills
  static const double radiusPill = 20.0;
  
  /// 50% - Full circle for avatars
  static const double radiusCircle = 50.0;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // COMPONENT SIZING
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Avatar sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  
  /// Icon sizes
  static const double iconTiny = 9.0;
  static const double iconSmall = 12.0;
  static const double iconMedium = 15.0;
  static const double iconLarge = 20.0;
  static const double iconXlarge = 24.0;
  
  /// Button sizes
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;
  
  /// Input field height
  static const double inputHeight = 40.0;
  
  /// Divider height
  static const double dividerHeight = 1.0;
  static const double dividerThick = 2.0;
  
  /// Badge sizes
  static const double badgeHeightSmall = 20.0;
  static const double badgeHeightMedium = 28.0;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // RESPONSIVE BREAKPOINTS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Mobile breakpoint (< 480px)
  static const double breakpointMobile = 480.0;
  
  /// Tablet breakpoint (480px - 768px)
  static const double breakpointTablet = 768.0;
  
  /// Desktop breakpoint (> 768px)
  static const double breakpointDesktop = 1024.0;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // SCREEN PADDING - Outer padding for different screen sizes
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Mobile screen padding
  static const double screenPaddingMobile = 16.0;
  
  /// Tablet screen padding
  static const double screenPaddingTablet = 24.0;
  
  /// Desktop screen padding
  static const double screenPaddingDesktop = 32.0;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CONTENT WIDTHS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Maximum content width for desktop
  static const double maxContentWidth = 1280.0;
  
  /// Standard card width
  static const double cardWidth = 360.0;
  
  /// Wide card width
  static const double cardWidthWide = 480.0;
}
