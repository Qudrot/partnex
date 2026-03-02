import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:partnex/core/theme/widgets/partnex_logo.dart';

void main() {
  testWidgets('Export Partnex Logo Icon', (WidgetTester tester) async {
    // We will render it super large for high quality
    const double baseSize = 1024.0;

    // Helper to render and save a widget
    Future<void> saveWidgetAsPng(Widget widget, String filename, Size physicalSize) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
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

      await tester.pumpAndSettle();

      final finder = find.byType(RepaintBoundary);
      expect(finder, findsOneWidget);

      final RenderRepaintBoundary boundary = tester.renderObject(finder) as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0); 
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final file = File('assets/images/$filename');
      if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
      await file.writeAsBytes(pngBytes);
      print('Saved: \${file.path}');
    }

    // Export Icon Only (No Text, so no font-loading exceptions)
    await saveWidgetAsPng(
      const PartnexLogo(
        size: baseSize, 
        variant: PartnexLogoVariant.iconOnly
      ), 
      'partnex_logo_icon_only_exact.png',
      const Size(1024, 1024)
    );
  });
}
