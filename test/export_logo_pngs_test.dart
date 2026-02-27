import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

// Import our logo definition directly from the source code we wrote
import 'package:partnex/core/theme/widgets/partnex_logo.dart';
import 'package:partnex/core/theme/app_colors.dart';

void main() {
  testWidgets('Export Partnex Logo Variants', (WidgetTester tester) async {
    // We will render it super large for high quality (e.g. 2000px wide for the combo)
    const double baseSize = 512.0; 

    // Helper to render and save a widget
    Future<void> saveWidgetAsPng(Widget widget, String filename, Size physicalSize) async {
      // 1. Pump the widget
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                fontFamily: 'Arial', // Fallback for headless tests
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          home: Scaffold(
            backgroundColor: Colors.transparent, // Export with transparent background
            body: Center(
              child: RepaintBoundary(
                child: widget,
              ),
            ),
          ),
        ),
      );

      // Wait for rendering
      await tester.pumpAndSettle();

      // 2. Find the RepaintBoundary
      final finder = find.byType(RepaintBoundary);
      expect(finder, findsOneWidget);

      // 3. Render it to an image
      final RenderRepaintBoundary boundary = tester.renderObject(finder) as RenderRepaintBoundary;
      
      // We scale it up to get high resolution output even if the logical size is smaller
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0); 
      
      // 4. Convert to PNG bytes
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // 5. Save to disk
      final file = File('assets/images/$filename');
      if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
      await file.writeAsBytes(pngBytes);
      print('Saved: \${file.path}');
    }

    // Export Brand Combo (Icon + Wordmark)
    await saveWidgetAsPng(
      const PartnexLogo(
        size: baseSize, 
        variant: PartnexLogoVariant.brandCombo
      ), 
      'partnex_logo_combo.png',
      const Size(2000, 800)
    );

    // Export Wordmark Only
    await saveWidgetAsPng(
      const PartnexLogo(
        size: baseSize, 
        variant: PartnexLogoVariant.wordmarkOnly
      ), 
      'partnex_logo_wordmark.png',
      const Size(1500, 600)
    );
    
    // Export Brand Combo (White text for dark backgrounds)
    await saveWidgetAsPng(
      const PartnexLogo(
        size: baseSize, 
        variant: PartnexLogoVariant.brandCombo,
        textPrimaryColor: Colors.white,
        textSecondaryColor: Colors.white,
      ), 
      'partnex_logo_combo_white.png',
      const Size(2000, 800)
    );
  });
}
