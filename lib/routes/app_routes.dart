import 'package:flutter/material.dart';
//import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/chatbot_page.dart';
import '../pages/renew_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    //'/login': (_) => const LoginPage(),
    '/home': (_) => const HomePage(),
    '/chatbot': (_) => const ChatbotPage(),
    '/renew': (_) => const RenewPage(),
  };
}
