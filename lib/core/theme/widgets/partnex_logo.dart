import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

enum PartnexLogoVariant {
  /// Both the symbol and the wordmark are shown.
  brandCombo,
  
  /// Only the "P" symbol is shown.
  iconOnly,

  /// Only the "Partnex" wordmark is shown.
  wordmarkOnly,
}

/// A modern, flexible logo widget for the Partnex brand.
/// Implements "Concept 1: The Data Flow P" based on user design.
class PartnexLogo extends StatelessWidget {
  /// Defines the overall size/height of the logo. Both the mark and text will scale relative to this.
  final double size;

  /// The variant of the logo to display. Defaults to [PartnexLogoVariant.brandCombo].
  final PartnexLogoVariant variant;

  /// Optional override color for the "Part" text.
  /// Defaults to [AppColors.slate900].
  final Color? textPrimaryColor;

  /// Optional override color for the "nex" text.
  /// Defaults to [AppColors.trustBlue].
  final Color? textSecondaryColor;

  const PartnexLogo({
    Key? key,
    this.size = 40.0,
    this.variant = PartnexLogoVariant.brandCombo,
    this.textPrimaryColor,
    this.textSecondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (variant == PartnexLogoVariant.iconOnly) {
      return _buildSymbol(size);
    }

    if (variant == PartnexLogoVariant.wordmarkOnly) {
      return _buildWordmark(size);
    }

    // Default to brandCombo
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSymbol(size),
        SizedBox(width: size * 0.003), // Spacing between symbol and wordmark
        _buildWordmark(size),
      ],
    );
  }

  Widget _buildSymbol(double renderSize) {
    return SizedBox(
      width: renderSize,
      height: renderSize,
      child: CustomPaint(
        painter: _DataFlowSymbolPainter(
          primaryColor: AppColors.trustBlue,
          secondaryColor: AppColors.slate900, // Or Deep Navy #0F172A
        ),
      ),
    );
  }

  Widget _buildWordmark(double renderSize) {
    final tPrimary = textPrimaryColor ?? AppColors.slate900;
    final tSecondary = textSecondaryColor ?? AppColors.slate900;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Partnex',
            style: AppTypography.textTheme.displayLarge?.copyWith(
              fontSize: renderSize * 0.85,
              fontWeight: FontWeight.w700,
              color: tPrimary,
              height: 1.0,
              letterSpacing: -renderSize * 0.02,
            ),
          ),
          // TextSpan(
          //   text: 'nex',
          //   style: AppTypography.textTheme.displayLarge?.copyWith(
          //     fontSize: renderSize * 0.85,
          //     fontWeight: FontWeight.w500,
          //     color: tSecondary,
          //     height: 1.0,
          //     letterSpacing: -renderSize * 0.02,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _DataFlowSymbolPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _DataFlowSymbolPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    // Clear canvas
    canvas.save();
    
    // As per Concept 1 "Data Flow P" based on user image:
    // Left vertical pillar is a solid dark navy bar.
    // The right loop is formed by *four* horizontal rounded lines of Trust Blue that wrap around.
    
    final Paint pillarPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;
      
    final Paint linePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.11 // Thickness of the blue lines
      ..strokeCap = StrokeCap.round; // Rounded ends
    
    // 1. Draw the Navy Pillar
    // The pillar is positioned on the left, takes up about 15-20% width.
    final RRect pillar = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.1, h * 0.1, w * 0.28, h * 0.9),
      Radius.circular(w * 0.09), // fully rounded ends
    );
    canvas.drawRRect(pillar, pillarPaint);

    // 2. Draw the Data Flow "P" loop lines
    // Based on the user image: There are 4 horizontal blue lines that start from slightly right of the pillar,
    // extend to the right, curve around via a semicircle, and come back.
    // In the image, they form an open 'D' or 'P' loop shape. 
    // Top 2 lines form the top of the curve, bottom 2 form the bottom of the curve...
    // Actually looking closely at the user image: it's a series of 4 parallel U-shapes/curves stacked.
    
    final double lineXStart = w * 0.35; // Start just right of the pillar
    final double curveOuterX = w * 0.9; // How far right they bulge
    
    // We have 4 bands. Let's calculate their Y positions.
    // Total vertical space for the loop is roughly h * 0.1 to h * 0.7
    final double yPadding = h * 0.12;
    
    // Heights for the 4 bands
    final double y1 = h * 0.15;
    final double y2 = h * 0.30;
    final double y3 = h * 0.45;
    final double y4 = h * 0.60;
    
    // The image shows the lines actually wrapping around continuously, 
    // almost like a single ribbon or concentric arcs.
    // Let's draw 4 concentric semi-elipses/arcs connecting top points to bottom points.
    // Wait, the user image shows 4 straight horizontal lines originating from the left,
    // then curving rightward and merging/terminating in a sharp curve.
    // Let's use 3 concentric arcs for a cleaner "P" shape, matching the provided concept 1 image.
    
    // Let's refine based on the exact image shared:
    // It has a single dark blue vertical pill.
    // Then 4 cyan horizontal lines that extend right and curve down to meet 4 lower horizontal lines.
    // Essentially 4 "U" shapes turned 90 degrees clockwise.
    
    // Line 1 (Outer Top) extends to Line 4 (Outer Bottom) -> Wait, that's 4 distinct U's?
    // No, it's concentric. Top line curves to become bottom line. 
    // So 2 concentric 'U' shapes?
    // Let's trace it: 
    // Top-most line (1) curves around to become bottom-most line (4) ... No, bottom-most line is separate.
    // Looking at the AI generated "Concept 1" vs the User provided image:
    // The user provided image shows a dark pillar on the left.
    // Then an inner "U" (sideways) and an outer "U" (sideways), making 4 horizontal segments total.
    
    final Paint linePaintUser = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
      
    // Inner sideways "U"
    final Path innerU = Path();
    innerU.moveTo(w * 0.38, h * 0.32);
    innerU.lineTo(w * 0.60, h * 0.32);
    // Arc down to h * 0.48
    innerU.arcToPoint(Offset(w * 0.60, h * 0.48), radius: Radius.circular(w * 0.2));
    innerU.lineTo(w * 0.38, h * 0.48);
    canvas.drawPath(innerU, linePaintUser);
    
    // Outer sideways "U"
    final Path outerU = Path();
    outerU.moveTo(w * 0.38, h * 0.16);
    outerU.lineTo(w * 0.65, h * 0.16);
    // Arc down to h * 0.64
    outerU.arcToPoint(Offset(w * 0.65, h * 0.64), radius: Radius.circular(w * 0.4));
    outerU.lineTo(w * 0.38, h * 0.64);
    canvas.drawPath(outerU, linePaintUser);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
