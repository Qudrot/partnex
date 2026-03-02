import 'package:flutter/material.dart';

class UiService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<dynamic> navigateTo(Widget page) {
    return navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => page));
  }

  Future<dynamic> replaceWith(Widget page) {
    return navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) => page));
  }

  Future<dynamic> clearAndNavigateTo(Widget page) {
    return navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  void goBack() {
    return navigatorKey.currentState!.pop();
  }

  void showSnackBar(String message, {bool isError = false}) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<dynamic> showCustomDialog(Widget dialog) {
    return showDialog(
      context: navigatorKey.currentState!.overlay!.context,
      builder: (_) => dialog,
    );
  }

  Future<dynamic> showBottomSheet(Widget sheet, BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }
}

final uiService = UiService();
