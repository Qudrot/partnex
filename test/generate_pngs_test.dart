import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const int iconSize = 1024;
  
  // Colors
  final img.Color white = img.ColorRgb8(255, 255, 255);
  final img.Color trustBlue = img.ColorRgb8(0, 102, 204);
  final img.Color slate900 = img.ColorRgb8(15, 23, 42);
  final img.Color transparent = img.ColorRgba8(0, 0, 0, 0);

  // --- 1. Generate Icon Only Variant ---
  final img.Image iconImage = img.Image(width: iconSize, height: iconSize);
  img.fill(iconImage, color: transparent);

  void drawIconDataFlow(img.Image canvas, int startX, int startY, int size) {
    final int padding = (size * 0.15).toInt();
    final int innerSize = size - (padding * 2);

    // Draw the Navy Pillar
    final int pillarX1 = startX + padding + (innerSize * 0.10).toInt();
    final int pillarY1 = startY + padding + (innerSize * 0.10).toInt();
    final int pillarX2 = startX + padding + (innerSize * 0.28).toInt();
    final int pillarY2 = startY + padding + (innerSize * 0.90).toInt();
    img.fillRect(canvas, x1: pillarX1, y1: pillarY1, x2: pillarX2, y2: pillarY2, color: slate900, radius: 40);

    // Draw the Loop lines
    final int UThickness = (innerSize * 0.08).toInt();

    // Inner U
    final int innerUx1 = startX + padding + (innerSize * 0.38).toInt();
    final int innerUy1 = startY + padding + (innerSize * 0.32).toInt() - (UThickness ~/ 2);
    final int innerUx2 = startX + padding + (innerSize * 0.60).toInt();
    final int innerUy2 = startY + padding + (innerSize * 0.48).toInt() + (UThickness ~/ 2);
    
    img.fillRect(canvas, x1: innerUx1, y1: innerUy1, x2: innerUx2, y2: innerUy2, color: trustBlue, radius: UThickness);
    img.fillRect(canvas, 
      x1: innerUx1, y1: innerUy1 + UThickness, x2: innerUx2 - UThickness, y2: innerUy2 - UThickness, 
      color: transparent, radius: UThickness ~/ 2
    );
    
    // Outer U
    final int outerUx1 = startX + padding + (innerSize * 0.38).toInt();
    final int outerUy1 = startY + padding + (innerSize * 0.16).toInt() - (UThickness ~/ 2);
    final int outerUx2 = startX + padding + (innerSize * 0.65).toInt();
    final int outerUy2 = startY + padding + (innerSize * 0.64).toInt() + (UThickness ~/ 2);
    
    img.fillRect(canvas, x1: outerUx1, y1: outerUy1, x2: outerUx2, y2: outerUy2, color: trustBlue, radius: UThickness * 2);
    img.fillRect(canvas, 
      x1: outerUx1, y1: outerUy1 + UThickness, x2: outerUx2 - UThickness, y2: outerUy2 - UThickness, 
      color: transparent, radius: UThickness * 2 - UThickness
    );
  }

  drawIconDataFlow(iconImage, 0, 0, iconSize);

  final iconPng = img.encodePng(iconImage);
  File('assets/images/partnex_logo_icon_only.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(iconPng);


  // --- 2. Generate Brand Combo (Icon + Wordmark) ---
  // We'll create a wider canvas.
  const int comboWidth = 4000;
  const int comboHeight = 1024;
  final img.Image comboImage = img.Image(width: comboWidth, height: comboHeight);
  img.fill(comboImage, color: transparent);

  // Draw Icon on the left
  drawIconDataFlow(comboImage, 0, 0, comboHeight);

  // Draw Text "Partnex" manually using image package built-in fonts for reliability without Flutter context.
  // The built-in fonts are bitmap fonts, they won't match exactly but will provide a safe placeholder PNG
  // if proper vector exporting is failing. Given we strictly need the colors, we will use drawString.
  
  img.drawString(
    comboImage, 
    'Part', 
    font: img.arial48, // Using largest available built-in font
    x: comboHeight + 100, 
    y: comboHeight ~/ 2 - 24, 
    color: slate900
  );
  
  img.drawString(
    comboImage, 
    'nex', 
    font: img.arial48, 
    x: comboHeight + 100 + 120, // Approximate width of "Part"
    y: comboHeight ~/ 2 - 24, 
    color: trustBlue
  );

  final comboPng = img.encodePng(comboImage);
  File('assets/images/partnex_logo_combo.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(comboPng);

  print('Exported assets/images/partnex_logo_icon_only.png');
  print('Exported assets/images/partnex_logo_combo.png');
  print('Note: Wordmark PNG uses placeholder bitmap fonts due to headless exporter limitations. The in-app logo uses exact AppTypography vectors.');
}
