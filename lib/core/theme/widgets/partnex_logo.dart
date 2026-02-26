import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partnest/core/theme/app_colors.dart';

/// A modern, flexible logo widget for the Partnex brand.
/// Concept A: "Connected Growth"
class PartnexLogo extends StatelessWidget {
  /// Defines the overall size of the logo. Both the mark and text will scale relative to this.
  final double size;

  /// Whether to display the brand name next to the symbol.
  final bool showText;

  /// Optional override color for the text and primary symbol color.
  /// Defaults to [AppColors.neutralBlack] for text and [AppColors.trustBlue] for the accent.
  final Color? textColor;

  const PartnexLogo({
    Key? key,
    this.size = 40.0,
    this.showText = true,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // The "Connected Growth" Symbol
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _PartnexSymbolPainter(
              primaryColor: AppColors.trustBlue,
              secondaryColor: AppColors.slate900,
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.25),
          // The "Partnex" Typography
          Text(
            'Partnex',
            style: GoogleFonts.inter(
              fontSize: size * 0.85,
              fontWeight: FontWeight.w800,
              letterSpacing: -size * 0.03, // Tighter tracking for modern tech feel
              color: textColor ?? AppColors.slate900,
              height: 1.0,
            ),
          ),
          // A subtle period/dot to indicate tech/digital presence
          Text(
            '.',
            style: GoogleFonts.inter(
              fontSize: size * 0.85,
              fontWeight: FontWeight.w900,
              color: AppColors.trustBlue,
              height: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}

class _PartnexSymbolPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _PartnexSymbolPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // We will draw two interlocking stylized rounded shapes pointing up and right.
    // Represents Partnership (two elements) and Growth (upward right trajectory).
    
    final Paint secondaryPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;
      
    final Paint primaryPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // First element (The base / Partner A) - darker slate
    final Path path1 = Path();
    path1.moveTo(w * 0.2, h * 0.8);
    path1.lineTo(w * 0.5, h * 0.5);
    path1.arcToPoint(Offset(w * 0.7, h * 0.5), radius: Radius.circular(w * 0.15));
    path1.lineTo(w * 0.4, h * 0.8);
    path1.arcToPoint(Offset(w * 0.2, h * 0.8), radius: Radius.circular(w * 0.15));
    path1.close();

    // Secondary Element (The growth / Partner B) - Trust Blue
    final Path path2 = Path();
    path2.moveTo(w * 0.45, h * 0.6);
    path2.lineTo(w * 0.75, h * 0.3);
    path2.arcToPoint(Offset(w * 0.95, h * 0.3), radius: Radius.circular(w * 0.15));
    path2.lineTo(w * 0.65, h * 0.6);
    path2.arcToPoint(Offset(w * 0.45, h * 0.6), radius: Radius.circular(w * 0.15));
    path2.close();
    
    // Combining them into a modern P-like or upward growth abstract
    // Actually, let's make it more geometric and recognizable as an upward chart arrow intersecting with a 'P' loop.
    
    // Let's redefine geometric shapes for a cleaner, material-style logo
    
    // Clear canvas
    canvas.save();
    
    // Shape 1: Vertical rounded pillar (represents foundation / structure)
    final RRect pillar = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.15, h * 0.2, w * 0.4, h * 0.9),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(pillar, secondaryPaint);

    // Shape 2: An upward pointing curved swoosh/polygon starting from the pillar (represents 'P' loop and growth)
    final Path growthPath = Path();
    growthPath.moveTo(w * 0.27, h * 0.5);
    // Curve up and right
    growthPath.quadraticBezierTo(w * 0.5, h * 0.2, w * 0.85, h * 0.15);
    // Outer rounded corner top right
    growthPath.arcToPoint(Offset(w * 0.95, h * 0.25), radius: Radius.circular(w * 0.1));
    // Back down forming the bottom of the 'P' loop
    growthPath.quadraticBezierTo(w * 0.65, h * 0.65, w * 0.4, h * 0.55);
    growthPath.close();

    // We add a slight gradient to the growth path for that polished tech feel
    final Paint gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          primaryColor.withOpacity(0.8),
          primaryColor,
        ],
      ).createShader(Rect.fromLTRB(w * 0.25, h * 0.1, w * 0.95, h * 0.65))
      ..style = PaintingStyle.fill;

    canvas.drawPath(growthPath, gradientPaint);
    
    // Add a small connecting dot to emphasize "nodes" and "networks"
    canvas.drawCircle(Offset(w * 0.27, h * 0.25), w * 0.12, primaryPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
