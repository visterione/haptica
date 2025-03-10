// lib/presentation/navigation/app_router.dart
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/settings_page.dart';
import '../pages/profile_page.dart';
import '../pages/help_page.dart';
import '../pages/speech_to_text_page.dart';  // Додано імпорт нової сторінки

class AppRouter {
  static const String home = '/home';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String help = '/help';
  static const String speechToText = '/speech-to-text';  // Додано новий маршрут

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
      settings: (context) => const SettingsPage(),
      profile: (context) => const ProfilePage(),
      help: (context) => const HelpPage(),
      speechToText: (context) => const SpeechToTextPage(),  // Додано нову сторінку
    };
  }
}