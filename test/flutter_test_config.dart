import 'dart:async';
import 'dart:io';
import 'package:golden_toolkit/golden_toolkit.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  HttpOverrides.global = _TestHttpOverrides();
  await loadAppFonts();
  return testMain();
}
