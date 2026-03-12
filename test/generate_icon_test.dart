import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const int size = 1024;
  final image = img.Image(width: size, height: size);

  // Colors
  final img.Color white = img.ColorRgb8(255, 255, 255);
  final img.Color trustBlue = img.ColorRgb8(0, 102, 204);
  final img.Color slate900 = img.ColorRgb8(15, 23, 42);

  // Background
  img.fill(image, color: white);

  final int padding = (size * 0.15).toInt();
  final int innerSize = size - (padding * 2);

  // Draw Concept 1 (Data Flow P) for launcher icon
  
  // 1. Draw the Navy Pillar
  final int pillarX1 = padding + (innerSize * 0.10).toInt();
  final int pillarY1 = padding + (innerSize * 0.10).toInt();
  final int pillarX2 = padding + (innerSize * 0.28).toInt();
  final int pillarY2 = padding + (innerSize * 0.90).toInt();
  img.fillRect(image, x1: pillarX1, y1: pillarY1, x2: pillarX2, y2: pillarY2, color: slate900, radius: 40);

  // 2. Draw the Data Flow "P" loop lines
  // We recreate the stroke-based paths by drawing filled rounded rectangles / arcs.
  // Since `image` package has limited stroke/arc thickness support, we draw solid blocks and carve them.
  
  final int uThickness = (innerSize * 0.08).toInt();
  
  // Inner U
  final int innerUx1 = padding + (innerSize * 0.38).toInt();
  final int innerUy1 = padding + (innerSize * 0.32).toInt() - (uThickness ~/ 2);
  final int innerUx2 = padding + (innerSize * 0.60).toInt();
  final int innerUy2 = padding + (innerSize * 0.48).toInt() + (uThickness ~/ 2);
  
  img.fillRect(image, x1: innerUx1, y1: innerUy1, x2: innerUx2, y2: innerUy2, color: trustBlue, radius: uThickness);
  // Cutout inner U to make it a stroke
  img.fillRect(image, 
    x1: innerUx1, 
    y1: innerUy1 + uThickness, 
    x2: innerUx2 - uThickness, 
    y2: innerUy2 - uThickness, 
    color: white, radius: uThickness ~/ 2
  );
  
  // Outer U
  final int outerUx1 = padding + (innerSize * 0.38).toInt();
  final int outerUy1 = padding + (innerSize * 0.16).toInt() - (uThickness ~/ 2);
  final int outerUx2 = padding + (innerSize * 0.65).toInt();
  final int outerUy2 = padding + (innerSize * 0.64).toInt() + (uThickness ~/ 2);
  
  img.fillRect(image, x1: outerUx1, y1: outerUy1, x2: outerUx2, y2: outerUy2, color: trustBlue, radius: uThickness * 2);
  // Cutout outer U to make it a stroke
  img.fillRect(image, 
    x1: outerUx1, 
    y1: outerUy1 + uThickness, 
    x2: outerUx2 - uThickness, 
    y2: outerUy2 - uThickness, 
    color: white, radius: uThickness * 2 - uThickness
  );

  // Save the image
  final png = img.encodePng(image);
  File('assets/images/partnex_icon.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(png);

  // print('Concept 1 Icon created successfully!');
}
