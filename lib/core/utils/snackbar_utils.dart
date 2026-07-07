import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

String? _lastMessage;
DateTime? _lastShownTime;

void showGlobalSnackBar(String message, {bool isError = false}) {
  if (message.isEmpty) return;
  
  final now = DateTime.now();
  if (_lastMessage == message &&
      _lastShownTime != null &&
      now.difference(_lastShownTime!) < const Duration(milliseconds: 1500)) {
    return; // Suppress duplicate snackbar within 1.5 seconds
  }
  
  _lastMessage = message;
  _lastShownTime = now;
  
  scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}
