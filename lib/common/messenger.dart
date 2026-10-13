import 'package:flutter/material.dart';

/// App-wide messenger so controllers can show a banner without a context
/// (used for push notifications that arrive while the app is open).
final GlobalKey<ScaffoldMessengerState> rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showAppBanner(String title, String body, {VoidCallback? onOpen}) {
  final messenger = rootMessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: Duration(seconds: onOpen == null ? 5 : 8),
        action: onOpen == null ? null : SnackBarAction(label: 'Open', onPressed: onOpen),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(body),
            ],
          ],
        ),
      ),
    );
}
