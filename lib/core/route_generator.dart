import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_push_notification/core/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/error_page.dart';
import '../pages/home_page.dart';
import '../pages/notification_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case Routes.kHomeScreen:
        return MaterialPageRoute(builder: (context) => const HomePage());

      case Routes.kNotificationScreen:
        return MaterialPageRoute(
            builder: (context) => NotificationPage(
                  message: args as RemoteMessage,
                ));
      default:
        return MaterialPageRoute(builder: (context) => const ErrorPage());
    }
  }
}
