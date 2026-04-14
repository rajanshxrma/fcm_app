import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize({required void Function(RemoteMessage) onData}) async {
    // request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('foreground message: ${message.notification?.title}');
      onData(message);
    });

    // background tap — app was in background, user tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('opened from background: ${message.notification?.title}');
      onData(message);
    });

    // terminated state — app launched from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('launched from terminated: ${initialMessage.notification?.title}');
      onData(initialMessage);
    }
  }

  Future<String?> getToken() {
    return _messaging.getToken();
  }
}
