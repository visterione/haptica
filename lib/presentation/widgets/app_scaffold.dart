// lib/presentation/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../navigation/app_router.dart';

enum AppTab {
  gestures,  // Змінено з home на gestures
  microphone,  // Змінено з help на microphone
  profile,
}

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final AppTab currentTab;
  final bool showBottomNavigation;
  final Widget? floatingActionButton; // Додано новий параметр

  const AppScaffold({
    Key? key,
    required this.body,
    required this.title,
    this.actions,
    required this.currentTab,
    this.showBottomNavigation = true,
    this.floatingActionButton, // Додано параметр в конструктор
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: showBottomNavigation
          ? BottomNavigationBar(
        currentIndex: currentTab.index,
        onTap: (index) {
          final tab = AppTab.values[index];
          if (tab != currentTab) {
            _navigateToTab(context, tab);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.gesture),
            label: 'Жести',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Мікрофон',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профіль',
          ),
        ],
      ) : null,
      floatingActionButton: floatingActionButton, // Додано FAB
    );
  }

  void _navigateToTab(BuildContext context, AppTab tab) {
    String route;
    switch (tab) {
      case AppTab.gestures:  // Змінено з home на gestures
        route = AppRouter.home;
        break;
      case AppTab.microphone:  // Змінено з help на microphone
        route = AppRouter.speechToText;  // Змінено маршрут
        break;
      case AppTab.profile:
        route = AppRouter.profile;
        break;
    }

    Navigator.pushReplacementNamed(context, route);
  }
}