import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partnex/core/theme/app_colors.dart';

void main() {
  test('Export Partnex Logo Direct Canvas', () async {
    const double w = 1024;
    const double h = 1024;
    
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));
    
    final primaryColor = AppColors.trustBlue;
    final secondaryColor = AppColors.slate900;
    
    // ----------- EXACT PAINT LOGIC FROM _DataFlowSymbolPainter ----------- //
    
    final Paint pillarPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;
      
    final Paint linePaintUser = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
    
    // 1. Draw the Navy Pillar
    final RRect pillar = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.1, h * 0.1, w * 0.28, h * 0.9),
      Radius.circular(w * 0.09), // fully rounded ends
    );
    canvas.drawRRect(pillar, pillarPaint);

    // 2. Inner sideways "U"
    final Path innerU = Path();
    innerU.moveTo(w * 0.38, h * 0.32);
    innerU.lineTo(w * 0.60, h * 0.32);
    // Arc down to h * 0.48
    innerU.arcToPoint(Offset(w * 0.60, h * 0.48), radius: Radius.circular(w * 0.2));
    innerU.lineTo(w * 0.38, h * 0.48);
    canvas.drawPath(innerU, linePaintUser);
    
    // 3. Outer sideways "U"
    final Path outerU = Path();
    outerU.moveTo(w * 0.38, h * 0.16);
    outerU.lineTo(w * 0.65, h * 0.16);
    // Arc down to h * 0.64
    outerU.arcToPoint(Offset(w * 0.65, h * 0.64), radius: Radius.circular(w * 0.4));
    outerU.lineTo(w * 0.38, h * 0.64);
    canvas.drawPath(outerU, linePaintUser);
    
    // --------------------------------------------------------------------- //

    final picture = recorder.endRecording();
    // Use the same pixel ration logic
    final image = await picture.toImage(w.toInt(), h.toInt()); 
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final file = File('assets/images/partnex_logo_icon_only.png');
    if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
    await file.writeAsBytes(pngBytes);
    
    print('Saved perfect vector export to \${file.path}');
  });
}
